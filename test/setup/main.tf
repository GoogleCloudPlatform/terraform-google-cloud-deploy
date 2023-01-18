/**
 * Copyright 2021 Google LLC
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

locals {
  projects = ["ci-cloud-deploy-test", "ci-cloud-deploy-prod"]

}

module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 11.0"
  for_each          = toset(local.projects)
  name              = each.value
  random_project_id = "true"
  org_id            = var.org_id
  folder_id         = var.folder_id
  billing_account   = var.billing_account

  activate_apis = [
    "orgpolicy.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "clouddeploy.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "secretmanager.googleapis.com",
    "sourcerepo.googleapis.com",
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
  activate_api_identities = [
    {
      api = "cloudbuild.googleapis.com"
      roles = [
        "roles/storage.admin",
        "roles/artifactregistry.admin",
        "roles/cloudbuild.builds.builder",
        "roles/source.writer",
      ]
    },
  ]
}

data "google_compute_default_service_account" "default" {
  depends_on = [module.project]
  for_each   = toset(local.projects)
  project    = module.project[each.value].project_id

}
/*
resource "google_cloudbuild_trigger" "filename-trigger" {
  depends_on = [module.project]
  location = "us-central1"

  trigger_template {
    branch_name = "main"
    repo_name   = "my-repo"
  }

  substitutions = {
    _FOO = "bar"
    _BAZ = "qux"
  }

  filename = "cloudbuild.yaml"
}

*/


data "google_cloudbuild_trigger" "name" {
  project    = module.project["ci-cloud-deploy-test"].project_id
  trigger_id = "123"
  location   = "global"
}

data "google_project" "project" {
  project_id = module.project["ci-cloud-deploy-test"].project_id
}


resource "google_project_iam_member" "cloudbuild_service_agent_role" {
  depends_on = [data.google_cloudbuild_trigger.name]
  project    = module.project["ci-cloud-deploy-test"].project_id
  role       = "roles/cloudbuild.serviceAgent"
  member     = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

