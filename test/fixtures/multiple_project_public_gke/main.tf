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


module "multiple_project_public_cluster" {
  source = "../../../examples/multiple_project_public_gke"

  pipeline_name = "google-pipeline-diff-gke-1-test"
  location      = "us-central1"
  project       = var.project_id["ci-cloud-deploy-test"]
  stage_targets = [{
    target_name   = "dev-3-test"
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
    exe_config_sa_name = "deployment-test-3-google"
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
    target_name   = "prod-3-test"
    profiles      = ["prod"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = var.project_id["ci-cloud-deploy-prod"]
      location         = "us-central-1"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = var.gke_sa[var.project_id["ci-cloud-deploy-prod"]]
    }
    require_approval   = true
    exe_config_sa_name = "deployment-prod-3-google"
    execution_config   = {}
    strategy           = {}
  }]
  trigger_sa_name   = "trigger-sa-3-test"
  trigger_sa_create = true
}


