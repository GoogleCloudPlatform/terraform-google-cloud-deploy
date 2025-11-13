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

module "cloud_deploy" {
  source  = "GoogleCloudPlatform/cloud-deploy/google"
  version = "~> 0.3"

  pipeline_name = var.pipeline_name
  location      = var.location
  project       = var.project
  stage_targets = [{
    target_name   = "dev-4-test"
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
    exe_config_sa_name = "deployment-test-4-google"
    execution_config = {
      execution_timeout = "3600s"
      worker_pool       = var.stage_targets[0].execution_config.worker_pool
      artifact_storage  = ""
    }
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "prod-4-test"
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
    exe_config_sa_name = "deployment-prod-4-google"
    execution_config = {
      worker_pool = var.stage_targets[1].execution_config.worker_pool
    }
    strategy = {}
  }]
  trigger_sa_name   = var.trigger_sa_name
  trigger_sa_create = var.trigger_sa_create

}
