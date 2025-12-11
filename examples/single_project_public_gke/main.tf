/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


locals {
  cluster_name = "cluster-2"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = var.project
  network_name = "dev-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.244.252.0/22"
      subnet_region         = var.location
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "This subnet has a description"
    }
  ]

  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "pod-range"
        ip_cidr_range = "10.0.1.0/24"
      },
      {
        range_name    = "service-range"
        ip_cidr_range = "10.0.2.0/24"
      }
    ]

  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  version                    = "33.1"
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.project
  name                       = local.cluster_name
  region                     = "us-central1"
  zones                      = ["us-central1-b", "us-central1-c"]
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = "pod-range"
  ip_range_services          = "service-range"
  http_load_balancing        = true
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = false
  master_ipv4_cidr_block     = "172.18.0.16/28"
  remove_default_node_pool   = true
  create_service_account     = false
  master_authorized_networks = [{
    cidr_block   = "0.0.0.0/0" # Change this to be the IP from which Kubernetes Can be accessed outside of GCP Network
    display_name = "Allow All"
  }]
  node_pools = [{
    name               = "default-node-pool" # Name for the Node Pool
    machine_type       = "e2-standard-4"     # Machine Type for Kubernetes Cluster
    node_locations     = "us-central1-c"     # Region for Node Locations. Must Match VPC region to provision
    autoscaling        = true                # Enabling Auto Scaling for the Cluster
    auto_upgrade       = true                # Enabling Auto Upgrade Functionality
    initial_node_count = 1                   # Minimum Nodes required for ASM to work
    min_count          = 1                   # Minimum Node Count
    max_count          = 2                   # Maximum Node Count for Cluster
    max_pods_per_node  = 10                  # Maximum pods per node. Default is 110
  }, ]

  deletion_protection = false
}




module "cloud_deploy" {
  source        = "GoogleCloudPlatform/cloud-deploy/google"
  version       = "~> 0.3"
  pipeline_name = var.pipeline_name
  location      = var.location
  project       = var.project
  stage_targets = [{
    target_name   = "dev-1-test"
    profiles      = ["test"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = var.stage_targets[0].target_spec.project_id
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = var.stage_targets[0].target_spec.gke_cluster_sa
    }
    require_approval   = false
    exe_config_sa_name = "deployment-test-1-google"
    execution_config = {
      execution_timeout = "3600s"
      worker_pool       = null
      artifact_storage  = ""
    }
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "prod-1-test"
    profiles      = ["prod"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = var.stage_targets[1].target_spec.project_id
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = var.stage_targets[1].target_spec.gke_cluster_sa
    }
    require_approval   = true
    exe_config_sa_name = "deployment-prod-1-google"
    execution_config   = {}
    strategy           = {}
  }]
  trigger_sa_name   = var.trigger_sa_name
  trigger_sa_create = var.trigger_sa_create
  depends_on        = [module.gke]

}
