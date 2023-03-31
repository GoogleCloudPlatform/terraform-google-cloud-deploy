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
  cluster_name = element(split("/", var.pipeline_spec[0].stage_targets[0].gke), 5)
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"

  project_id   = var.pipeline_spec[0].project
  network_name = "dev-vpc"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.244.252.0/22"
      subnet_region         = var.pipeline_spec[0].location
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
  version                    = "25.0.0"
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = var.pipeline_spec[0].project
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
}

data "google_compute_default_service_account" "default" {
  project = var.pipeline_spec[0].project
}

module "cloud_deploy" {
  source        = "../../"
  pipeline_name = "google-pipeline-same-gke-1-test"
  location      = var.pipeline_spec[0].location
  project       = var.pipeline_spec[0].project
  stage_targets = [{
    target                            = "dev-1-test"
    profiles                          = ["test"]
    gke                               = "projects/${var.pipeline_spec[0].project}/locations/${var.pipeline_spec[0].location}/clusters/${local.cluster_name}"
    gke_cluster_sa                    = [data.google_compute_default_service_account.default.email]
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = null
    worker_pool                       = null
    }, {
    target                            = "prod-1-test"
    profiles                          = ["prod"]
    gke                               = "projects/${var.pipeline_spec[0].project}/locations/${var.pipeline_spec[0].location}/clusters/${local.cluster_name}"
    gke_cluster_sa                    = [data.google_compute_default_service_account.default.email]
    artifact_storage                  = null
    require_approval                  = true
    execution_configs_service_account = "deployment-prod-1-google-test"
    worker_pool                       = null
  }]
  cloud_trigger_sa = "trigger-sa-1-test"
  depends_on       = [module.gke]

}
