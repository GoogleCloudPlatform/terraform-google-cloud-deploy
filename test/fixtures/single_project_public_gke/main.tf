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


module "single_project_public_cluster" {

  source = "../../../examples/single_project_public_gke"
  pipeline_spec = [
    {
      pipeline_name = "google-pipeline-same-gke-1-test"
      location      = "us-central1"
      project       = var.project_id["ci-cloud-deploy-test"]
      stage_targets = [{
        target                            = "dev-1-test"
        profiles                          = ["test"]
        gke                               = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1-c/clusters/cluster-2"
        gke_cluster_sa                    = [var.gke_sa[var.project_id["ci-cloud-deploy-test"]]]
        artifact_storage                  = null
        require_approval                  = false
        execution_configs_service_account = null
        worker_pool                       = null
        }, {
        target                            = "prod-1-test"
        profiles                          = ["prod"]
        gke                               = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1-c/clusters/cluster-2"
        gke_cluster_sa                    = [var.gke_sa[var.project_id["ci-cloud-deploy-test"]]]
        artifact_storage                  = null
        require_approval                  = true
        execution_configs_service_account = "deployment-prod-1-google-test"
        worker_pool                       = null
      }]
      cloud_trigger_sa = "trigger-sa-1-test"
    }
  ]

}
