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

output "delivery_pipeline_and_target" {
  value = module.cloud_deploy_run.delivery_pipeline_and_target
}

output "cloud_trigger_service_account" {
  value = module.cloud_deploy_run.cloud_trigger_service_account
}

output "cloud_deploy_service_account" {
  value = module.cloud_deploy_run.cloud_deploy_service_account
}

output "project_id" {
  value = var.project_id["ci-cloud-deploy-test"]
}

output "target_project_id" {
  value = var.project_id["ci-cloud-deploy-prod"]
}
