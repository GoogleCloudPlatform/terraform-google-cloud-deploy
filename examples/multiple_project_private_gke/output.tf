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

output "cloud_trigger_service_account" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy.cloud_trigger_sa]
  description = "List of Cloud Build Trigger Service Account"
}

output "cloud_deploy_service_account" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy.deployment_sa]
  description = "List of Deploy target Execution Service Account"
}

output "delivery_pipeline_and_target" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy.delivery_pipeline_and_target]
  description = "List of Delivery Pipeline and respective Target"
}

