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

data "google_project" "project" {
  project_id = var.project
}


locals {

  non_empty_target_sa = [for j in var.stage_targets : j.execution_configs_service_account != null ? j : null]

  tmp_list_target_sa = [for j in local.non_empty_target_sa : j != null ? join("=>", [element(split("/", j.gke), 1), j.execution_configs_service_account]) : ""]

  target_sa = compact(distinct(flatten(local.tmp_list_target_sa)))


  tmp_list_default_execution_sa_binding = [for j in var.stage_targets : j.execution_configs_service_account == null ? element(split("/", j.gke), 1) : ""]

  default_execution_sa_binding = compact(distinct(flatten(local.tmp_list_default_execution_sa_binding)))


  tmp_list_gke_cluster_sa = [for j in var.stage_targets : [for gke_sa in j.gke_cluster_sa : gke_sa]]

  gke_cluster_sa = distinct(flatten(local.tmp_list_gke_cluster_sa))

  tri_sa_actas_exe_sa = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account != null && var.cloud_trigger_sa != null ? join("=>", [element(split("/", j.gke), 1), j.execution_configs_service_account]) : ""])))

  def_cloudbuild_sa_actas_exe_sa = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account != null && var.cloud_trigger_sa == null ? join("=>", [element(split("/", j.gke), 1), j.execution_configs_service_account]) : ""])))

  tri_sa_actas_def_compute_sa = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account == null && var.cloud_trigger_sa != null ? "default_compute_sa" : ""])))

  def_cloudbuild_sa_actas_def_compute_sa = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account == null && var.cloud_trigger_sa == null ? "default_compute_sa" : ""])))

  service_agent_binding = compact(distinct(flatten([for j in var.stage_targets : var.project != element(split("/", j.gke), 1) && j.execution_configs_service_account != null ? join("=>", [element(split("/", j.gke), 1), j.execution_configs_service_account]) : ""])))



}

resource "google_clouddeploy_delivery_pipeline" "delivery_pipeline" {
  depends_on = [module.trigger_service_account, module.deployment_service_accounts]
  location   = var.location
  name       = var.pipeline_name
  project    = var.project
  serial_pipeline {
    dynamic "stages" {
      for_each = var.stage_targets
      content {
        profiles  = stages.value["profiles"]
        target_id = stages.value["target"]
      }
    }
  }
}


resource "google_clouddeploy_target" "target" {
  depends_on = [module.trigger_service_account, module.deployment_service_accounts]
  for_each   = { for tar in var.stage_targets : tar.target => tar }
  location   = var.location
  name       = each.value.target
  gke {
    cluster = each.value.gke
  }
  require_approval = each.value.require_approval
  project          = var.project
  execution_configs {
    usages           = ["RENDER", "DEPLOY"]
    service_account  = each.value.execution_configs_service_account != null ? module.deployment_service_accounts[join("=>", [element(split("/", each.value.gke), 1), each.value.execution_configs_service_account])].email : ""
    worker_pool      = each.value.worker_pool
    artifact_storage = each.value.artifact_storage != null ? each.value.artifact_storage : ""
  }
}


module "trigger_service_account" {
  count        = var.cloud_trigger_sa != null ? 1 : 0
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = var.project
  names        = [var.cloud_trigger_sa]
  display_name = "TF_managed_${var.cloud_trigger_sa}"
  project_roles = [
    "${var.project}=>roles/cloudbuild.builds.editor",
    "${var.project}=>roles/cloudbuild.builds.builder",
    "${var.project}=>roles/clouddeploy.developer",
    "${var.project}=>roles/clouddeploy.releaser",
    "${var.project}=>roles/clouddeploy.jobRunner",
    "${var.project}=>roles/storage.objectAdmin"
  ]
}

module "deployment_service_accounts" {
  for_each     = toset(local.target_sa)
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = element(split("=>", each.value), 0)
  names        = [element(split("=>", each.value), 1)]
  display_name = "TF_managed_${element(split("=>", each.value), 1)}"
  project_roles = ["${element(split("=>", each.value), 0)}=>roles/container.developer",
    "${var.project}=>roles/storage.objectAdmin",
    "${var.project}=>roles/logging.logWriter",
    "${element(split("=>", each.value), 0)}=>roles/logging.logWriter"
  ]
}

module "default_execution_member_roles" {
  depends_on              = [module.deployment_service_accounts, data.google_project.project]
  for_each                = toset(local.default_execution_sa_binding)
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  version                 = "7.4.1"
  service_account_address = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  prefix                  = "serviceAccount"
  project_id              = each.value
  project_roles           = ["roles/container.developer"]
}

module "default_cloud_build_member_roles" {
  depends_on              = [module.deployment_service_accounts, data.google_project.project]
  count                   = var.cloud_trigger_sa == null ? 1 : 0
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  version                 = "7.4.1"
  service_account_address = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  prefix                  = "serviceAccount"
  project_id              = var.project
  project_roles           = ["roles/cloudbuild.builds.editor", "roles/cloudbuild.builds.builder", "roles/clouddeploy.developer", "roles/clouddeploy.releaser", "roles/clouddeploy.jobRunner", "roles/storage.objectAdmin"]
}

resource "google_service_account_iam_member" "tri_sa_actas_exe_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.tri_sa_actas_exe_sa)
  service_account_id = "projects/${element(split("=>", each.value), 0)}/serviceAccounts/${element(split("=>", each.value), 1)}@${element(split("=>", each.value), 0)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.trigger_service_account[0].email}"
}

resource "google_service_account_iam_member" "def_cloudbuild_sa_actas_exe_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.def_cloudbuild_sa_actas_exe_sa)
  service_account_id = "projects/${element(split("=>", each.value), 0)}/serviceAccounts/${element(split("=>", each.value), 1)}@${element(split("=>", each.value), 0)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "tri_sa_actas_def_compute_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.tri_sa_actas_def_compute_sa)
  service_account_id = "projects/${var.project}/serviceAccounts/${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.trigger_service_account[0].email}"
}

resource "google_service_account_iam_member" "def_cloudbuild_sa_actas_def_compute_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.def_cloudbuild_sa_actas_def_compute_sa)
  service_account_id = "projects/${var.project}/serviceAccounts/${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_build_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.service_agent_binding)
  service_account_id = "projects/${element(split("=>", each.value), 0)}/serviceAccounts/${element(split("=>", each.value), 1)}@${element(split("=>", each.value), 0)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_deploy_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.service_agent_binding)
  service_account_id = "projects/${element(split("=>", each.value), 0)}/serviceAccounts/${element(split("=>", each.value), 1)}@${element(split("=>", each.value), 0)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "binding_gke_sa_to_storage_source" {
  for_each = toset(local.gke_cluster_sa)
  project  = var.project
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${each.value}"

}


