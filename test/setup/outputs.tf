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

output "project_id" {
  value = { for i in toset(local.projects) : i => module.project[i].project_id }
}

output "gke_sa" {
  value = { for i in toset(local.projects) : module.project[i].project_id => data.google_compute_default_service_account.default[i].email }
}

output "role_binding" {
  value = [for object in jsondecode(data.google_project_iam_policy.policy.policy_data).bindings : object if object.role == "roles/cloudbuild.serviceAgent" || object.role == "roles/clouddeploy.serviceAgent"]
}
