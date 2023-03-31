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
  pipeline_name = "google-pipeline-diff-gke-1-test"
  location      = "us-central1"
  project       = var.pipeline_spec[0].project
  stage_targets = [{
    target                            = "dev-3-test"
    profiles                          = ["test"]
    gke                               = var.pipeline_spec[0].stage_targets[0].gke
    gke_cluster_sa                    = var.pipeline_spec[0].stage_targets[0].gke_cluster_sa
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = null
    worker_pool                       = null
    }, {
    target                            = "prod-3-test"
    profiles                          = ["prod"]
    gke                               = var.pipeline_spec[0].stage_targets[1].gke
    gke_cluster_sa                    = var.pipeline_spec[0].stage_targets[1].gke_cluster_sa
    artifact_storage                  = null
    require_approval                  = true
    execution_configs_service_account = null
    worker_pool                       = null
  }]
  cloud_trigger_sa = "trigger-sa-3-test"
}
