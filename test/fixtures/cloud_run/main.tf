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


module "cloud_deploy_run" {
  source = "../../../examples/cloud_run"

  pipeline_name = "google-pipeline-run"
  location      = "us-central1"
  project       = var.project_id["ci-cloud-deploy-test"]
  stage_targets = [{
    target_name   = "google-run-1"
    profiles      = ["run1"]
    target_create = true
    target_type   = "run"
    target_spec = {
      project_id     = var.project_id["ci-cloud-deploy-test"]
      location       = "us-central1"
      run_service_sa = var.gke_sa[var.project_id["ci-cloud-deploy-test"]]
    }
    require_approval   = false
    exe_config_sa_name = "deployment-run-1-google"
    execution_config   = {}
    strategy = {
      standard = { verify = true }
    }
    }, {
    target_name   = "google-run-2"
    profiles      = ["run2"]
    target_create = true
    target_type   = "run"
    target_spec = {
      project_id     = var.project_id["ci-cloud-deploy-prod"]
      location       = "us-central1"
      run_service_sa = var.gke_sa[var.project_id["ci-cloud-deploy-prod"]]
    }
    require_approval   = true
    exe_config_sa_name = "deployment-run-2-google"
    execution_config   = {}
    strategy           = {}
  }]
  trigger_sa_name   = "run-trigger"
  trigger_sa_create = true
}


