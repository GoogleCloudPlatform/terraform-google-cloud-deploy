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

output "trigger_sa" {
  value       = module.trigger_service_account[*].email
  description = "List of Cloud Build Trigger Service Account"
}

output "execution_sa" {
  value       = [for sa in local.target_sa : module.execution_service_accounts["${sa.project}=>${sa.exe_sa}"].email]
  description = "List of Deploy target Execution Service Account"
}


output "delivery_pipeline_and_target" {
  value       = { (google_clouddeploy_delivery_pipeline.delivery_pipeline.id) = flatten([for target in local.stage_targets : google_clouddeploy_target.target[target.target_name].id]) }
  description = "List of Delivery Pipeline and respective Target"
}
