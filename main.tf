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
  for_each = toset(distinct(concat([for project in local.target_sa_run : project.project],[var.project])))
  project_id = each.value
}

locals {

  tmp_list_target_sa_gke = [for target in var.stage_targets : target.target_create && contains(keys(target.target_spec), "gke") ? { project = target.target_spec.gke.project_id, exe_sa = target.execution_configs_service_account } : {}]

  target_sa_gke = setsubtract(distinct(local.tmp_list_target_sa_gke), [{}])

  tmp_list_target_sa_run = [for target in var.stage_targets : target.target_create && contains(keys(target.target_spec), "run") ? { project = target.target_spec.run.project_id, exe_sa = target.execution_configs_service_account } : {}]

  target_sa_run = setsubtract(distinct(local.tmp_list_target_sa_run), [{}])

  extract_target_sa_gke = [for sa in setsubtract(local.target_sa_gke, local.target_sa_run) : { project = sa.project, exe_sa = sa.exe_sa, type = "gke" }]

  extract_target_sa_run = [for sa in setsubtract(local.target_sa_run, local.target_sa_gke) : { project = sa.project, exe_sa = sa.exe_sa, type = "run" }]

  intersected_target_sa = [for sa in setintersection(local.target_sa_gke, local.target_sa_run) : { project = sa.project, exe_sa = sa.exe_sa, type = "both" }]

  target_sa = concat(local.extract_target_sa_gke, local.extract_target_sa_run, local.intersected_target_sa)


  exe_sa_actas_run_svc_sa = setsubtract(distinct(flatten([for target in var.stage_targets : target.target_create && contains(keys(target.target_spec), "run") ? contains(keys(target.target_spec.run), "run_service_sa") ? [for sa in compact(split(",", target.target_spec.run.run_service_sa)) : { project = target.target_spec.run.project_id, exe_sa = target.execution_configs_service_account, run_sa = sa }] : [{}] : [{}]])), [{}])


  tmp_list_gke_cluster_sa = [for target in var.stage_targets : target.target_create && contains(keys(target.target_spec), "gke") ? [for gke_sa in split(",", target.target_spec.gke.gke_cluster_sa) : gke_sa] : [""]]

  gke_cluster_sa = compact(distinct(flatten(local.tmp_list_gke_cluster_sa)))


  tri_sa_actas_exe_sa = setsubtract(distinct([for target in var.stage_targets : contains(keys(target.target_spec), "gke") ? { project = target.target_spec.gke.project_id, exe_sa = target.execution_configs_service_account } : contains(keys(target.target_spec), "run") ? { project = target.target_spec.run.project_id, exe_sa = target.execution_configs_service_account } : {}]), [{}])



  service_agent_binding = setsubtract([for agent_bind in local.target_sa : agent_bind.project != var.project ? agent_bind : {}], [{}])




  stage_targets = flatten([for target in var.stage_targets : [ for i in target.target_create ? [1] : [] : target ]])

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
        target_id = stages.value["target_name"]
        dynamic "strategy" {
          for_each = contains(keys(stages.value.strategy), "standard") ? stages.value.strategy.standard.verify == true ? [1] : [] : []
          content {
            standard {
              verify = stages.value.strategy.standard.verify
            }
          }
        }
      }
    }
  }
}

resource "google_clouddeploy_target" "target" {
  depends_on = [module.trigger_service_account, module.deployment_service_accounts]
  for_each   = { for target in local.stage_targets : target.target_name => target }
  location   = var.location
  name       = each.value.target_name
  dynamic "gke" {
    for_each = contains(keys(each.value.target_spec), "gke") ? [1] : []
    content {
      cluster = "projects/${each.value.target_spec.gke.project_id}/locations/${each.value.target_spec.gke.location}/clusters/${each.value.target_spec.gke.gke_cluster_name}"
    }
  }

  dynamic "run" {
    for_each = contains(keys(each.value.target_spec), "run") ? [1] : []
    content {
      location = "projects/${each.value.target_spec.run.project_id}/locations/${each.value.target_spec.run.location}"
    }
  }
  require_approval = each.value.require_approval
  project          = var.project
  execution_configs {
    usages           = ["RENDER", "DEPLOY", "VERIFY"]
    service_account  = contains(keys(each.value.target_spec), "gke") ? module.deployment_service_accounts[join("=>", [each.value.target_spec.gke.project_id, each.value.execution_configs_service_account])].email : module.deployment_service_accounts[join("=>", [each.value.target_spec.run.project_id, each.value.execution_configs_service_account])].email
    worker_pool      = each.value.worker_pool
    artifact_storage = each.value.artifact_storage != null ? each.value.artifact_storage : ""
  }
}

module "trigger_service_account" {
  count        = var.trigger_sa_create ? 1 : 0
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 4.0"
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
  for_each      = { for i in local.target_sa : "${i.project}=>${i.exe_sa}" => i }
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 4.0"
  project_id    = each.value.project
  names         = [each.value.exe_sa]
  display_name  = "TF_managed_${each.value.exe_sa}"
  project_roles = each.value.type == "gke" ? ["${each.value.project}=>roles/container.developer", "${var.project}=>roles/storage.objectAdmin", "${var.project}=>roles/logging.logWriter", "${each.value.project}=>roles/logging.logWriter"] : each.value.type == "run" ? ["${each.value.project}=>roles/run.developer", "${var.project}=>roles/storage.objectAdmin", "${var.project}=>roles/logging.logWriter", "${each.value.project}=>roles/logging.logWriter"] : ["${each.value.project}=>roles/run.developer", "${each.value.project}=>roles/container.developer", "${var.project}=>roles/storage.objectAdmin", "${var.project}=>roles/logging.logWriter", "${each.value.project}=>roles/logging.logWriter"]
}


resource "google_service_account_iam_member" "tri_sa_actas_exe_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account]
  for_each           = { for i in local.tri_sa_actas_exe_sa : "${i.project}=>${i.exe_sa}" => i }
  service_account_id = "projects/${each.value.project}/serviceAccounts/${each.value.exe_sa}@${each.value.project}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.cloud_trigger_sa}@${var.project}.iam.gserviceaccount.com"
}


resource "google_service_account_iam_member" "exe_sa_actas_run_svc_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account]
  for_each           = { for i in local.exe_sa_actas_run_svc_sa : "${i.exe_sa}=>${i.project}=>${i.run_sa}" => i }
  service_account_id = "projects/${each.value.project}/serviceAccounts/${each.value.run_sa}"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${each.value.exe_sa}@${each.value.project}.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_build_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = { for i in local.service_agent_binding : "${i.project}=>${i.exe_sa}" => i }
  service_account_id = "projects/${each.value.project}/serviceAccounts/${each.value.exe_sa}@${each.value.project}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project[var.project].number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_deploy_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = { for i in local.service_agent_binding : "${i.project}=>${i.exe_sa}" => i }
  service_account_id = "projects/${each.value.project}/serviceAccounts/${each.value.exe_sa}@${each.value.project}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.project[var.project].number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_run_service_agent_binding_storage_viewer" {
  for_each           = toset(distinct(setsubtract([for i in local.target_sa_run: i.project],[var.project])))
  project            = var.project
  role               = "roles/storage.objectViewer"
  member             = "serviceAccount:service-${data.google_project.project[each.value].number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "binding_target_sa_to_storage_source" {
  for_each = toset(local.gke_cluster_sa)
  project  = var.project
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${each.value}"

}




