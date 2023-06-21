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
  source = "../../"

  pipeline_name = "google-pipeline-same-gke-3"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source"
  stage_targets = [{
    target_name   = "google-run-1"
    profiles      = ["run1"]
    target_create = true
    target_type   = "run"
    target_spec = {
      project_id     = "gdc-clouddeploy-source"
      location       = "us-central1"
      run_service_sa = "123142937233-compute@developer.gserviceaccount.com,service-account@gdc-clouddeploy-source.com"
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
      project_id     = "gdc-clouddeploy-dev"
      location       = "us-central1"
      run_service_sa = "548710651430-compute@developer.gserviceaccount.com,service-account@gdc-clouddeploy-dev.com"
    }
    require_approval   = false
    exe_config_sa_name = "deployment-run-2-google"
    execution_config   = {}
    strategy           = {}
  }]
  trigger_sa_name   = "cd-trigger-1"
  trigger_sa_create = false
}

