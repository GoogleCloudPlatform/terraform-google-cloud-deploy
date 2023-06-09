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
  source        = "../../"
  pipeline_name = "google-pipeline-diff-gke-2-test"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source" #var.pipeline_spec[0].project
  stage_targets = [{
    target_name   = "dev-4-test"
    profiles      = ["test"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = "gdc-clouddeploy-dev"
      location         = "us-central1-c"
      gke_cluster_name = "private-cluster-2"
      gke_cluster_sa   = "548710651430-compute@developer.gserviceaccount.com"
    }
    require_approval   = false
    exe_config_sa_name = "deployment-gke"
    execution_config = {
      worker_pool = "projects/gdc-clouddeploy-source/locations/us-central1/workerPools/worker-pool1"
    }
    strategy = {
      standard = {
        verify = true
      }
    }
  }]
  /*
{
    target                            = "prod-4-test"
    profiles                          = ["prod"]
    gke                               = var.pipeline_spec[0].stage_targets[1].gke
    gke_cluster_sa                    = var.pipeline_spec[0].stage_targets[1].gke_cluster_sa
    artifact_storage                  = null
    require_approval                  = true
    execution_configs_service_account = null
    worker_pool                       = var.pipeline_spec[0].stage_targets[1].worker_pool
  }]

*/

  trigger_sa_name = "trigger-sa-4-test"
}
