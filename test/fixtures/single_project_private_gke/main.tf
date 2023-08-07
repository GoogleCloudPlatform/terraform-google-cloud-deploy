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

module "single_project_private_cluster" {
  source = "../../../examples/single_project_private_gke"

  pipeline_name = "google-pipeline-same-gke-2-test"
  location      = "us-central1"
  project       = var.project_id["ci-cloud-deploy-test"]
  stage_targets = [{
    target_name   = "dev-2-test"
    profiles      = ["test"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = var.project_id["ci-cloud-deploy-test"]
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = var.gke_sa[var.project_id["ci-cloud-deploy-test"]]
    }
    require_approval   = false
    exe_config_sa_name = "deployment-test-2-google"
    execution_config = {
      execution_timeout = "3600s"
      worker_pool       = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1/workerPools/worker-pool"
      artifact_storage  = ""
    }
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "prod-2-test"
    profiles      = ["prod"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = var.project_id["ci-cloud-deploy-test"]
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = var.gke_sa[var.project_id["ci-cloud-deploy-test"]]
    }
    require_approval   = false
    exe_config_sa_name = "deployment-prod-2-google"
    execution_config = {
      worker_pool = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1/workerPools/worker-pool"
    }
    strategy = {}
  }]
  trigger_sa_name   = "trigger-sa-2-test"
  trigger_sa_create = true
}


