data "google_project" "project" {
  project_id = var.project
}


locals {


  trigger_sa = compact([var.cloud_trigger_sa == null ? "" : join("=>", [var.project, var.cloud_trigger_sa])])

  target_sa = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account != null ? join("=>", [element(split("/", j.gke), 1), j.execution_configs_service_account, var.project]) : ""])))
  

  default_execution_sa_binding  = compact(distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account == null ? join("=>", [var.project, "default_sa", element(split("/", j.gke), 1)]) : ""])))
  
 
  default_cloud_build_sa_binding = compact([var.cloud_trigger_sa == null ? join("=>", ["default_sa", var.project]) : ""])
 

  cloud_deploy_targets = distinct([for j in var.stage_targets : { ecsa             = j.execution_configs_service_account != null ? join("@", [j.execution_configs_service_account, element(split("/", j.gke), 1)]) : null
    target           = j.target
    location         = var.location
    project          = var.project
    gke              = j.gke
    require_approval = j.require_approval
    artifact_storage = j.artifact_storage
    worker_pool      = j.worker_pool
  }])


  gke_cluster_sa = compact(distinct(flatten([for j in var.stage_targets : [for h in j.gke_cluster_sa : join("=>", [var.project, h])]])))

  service_accounts_actas_binding = distinct(flatten([for j in var.stage_targets : j.execution_configs_service_account != null ? var.cloud_trigger_sa != null ? join("=>", [var.project, var.cloud_trigger_sa, element(split("/", j.gke), 1), j.execution_configs_service_account]) : join("=>", [var.project, "default_sa", element(split("/", j.gke), 1), j.execution_configs_service_account]) : var.cloud_trigger_sa != null ? join("=>", [var.project, var.cloud_trigger_sa, "default_sa"]) : join("=>", [var.project, "default_sa1", "default_sa"])]))
  
  
  service_agent_binding = compact(distinct(flatten([for j in var.stage_targets : var.project == element(split("/", j.gke), 1) ? "" : j.execution_configs_service_account == null ? "" : join("=>", [var.project, element(split("/", j.gke), 1), j.execution_configs_service_account])])))

  pipeline = [{
    pipe = var.pipeline_name
    loc  = var.location
    pro  = var.project
  targets = var.stage_targets }]


}

resource "google_clouddeploy_delivery_pipeline" "delivery_pipeline" {
  depends_on = [module.trigger_service_account, module.deployment_service_accounts]
  for_each   = { for pip in local.pipeline : "${pip.pro}-${pip.loc}-${pip.pipe}" => pip }
  location   = each.value.loc
  name       = each.value.pipe
  project    = each.value.pro
  serial_pipeline {
    dynamic "stages" {
      for_each = each.value.targets
      content {
        profiles  = stages.value["profiles"]
        target_id = stages.value["target"]
      }
    }
  }
}


resource "google_clouddeploy_target" "target" {
  depends_on = [module.trigger_service_account, module.deployment_service_accounts]
  for_each   = { for tar in local.cloud_deploy_targets : "${tar.project}-${tar.location}-${tar.target}" => tar }
  location   = each.value.location
  name       = each.value.target
  gke {
    cluster = each.value.gke
  }
  require_approval = each.value.require_approval
  project          = each.value.project
  execution_configs {
    usages           = ["RENDER", "DEPLOY"]
    service_account  = each.value.ecsa == null ? "" : "${each.value.ecsa}.iam.gserviceaccount.com"
    worker_pool      = each.value.worker_pool
    artifact_storage = each.value.artifact_storage == null ? "" : each.value.artifact_storage
  }
}


module "trigger_service_account" {
  for_each     = toset(local.trigger_sa)
  source       = "terraform-google-modules/service-accounts/google"
  version      = "~> 3.0"
  project_id   = element(split("=>", each.value), 0)
  names        = [element(split("=>", each.value), 1)]
  display_name = "TF_managed_${element(split("=>", each.value), 1)}"
  project_roles = [
    "${element(split("=>", each.value), 0)}=>roles/cloudbuild.builds.editor",
    "${element(split("=>", each.value), 0)}=>roles/cloudbuild.builds.builder",
    "${element(split("=>", each.value), 0)}=>roles/clouddeploy.developer",
    "${element(split("=>", each.value), 0)}=>roles/clouddeploy.releaser",
    "${element(split("=>", each.value), 0)}=>roles/clouddeploy.jobRunner",
    "${element(split("=>", each.value), 0)}=>roles/storage.objectAdmin"
  ]
}

module "deployment_service_accounts" {
  for_each      = toset(local.target_sa)
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 3.0"
  project_id    = element(split("=>", each.value), 0)
  names         = [element(split("=>", each.value), 1)]
  display_name  = "TF_managed_${element(split("=>", each.value), 1)}"
  project_roles = ["${element(split("=>", each.value), 0)}=>roles/container.developer",
                   "${element(split("=>", each.value), 2)}=>roles/storage.objectAdmin",
                   "${element(split("=>", each.value), 2)}=>roles/logging.logWriter"
                  ]
}

module "default_execution_member_roles" {
  depends_on              = [module.deployment_service_accounts, data.google_project.project]
  for_each                = toset(local.default_execution_sa_binding)
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  prefix                  = "serviceAccount"
  project_id              = element(split("=>", each.value), 2)
  project_roles           = ["roles/container.developer"]
}

module "default_cloud_build_member_roles" {
  depends_on              = [module.deployment_service_accounts, data.google_project.project]
  for_each                = toset(local.default_cloud_build_sa_binding)
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  prefix                  = "serviceAccount"
  project_id              = element(split("=>", each.value), 1)
  project_roles           = ["roles/cloudbuild.builds.editor", "roles/cloudbuild.builds.builder", "roles/clouddeploy.developer", "roles/clouddeploy.releaser", "roles/clouddeploy.jobRunner", "roles/storage.objectAdmin"]
}


resource "google_service_account_iam_member" "triger_sa_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.service_accounts_actas_binding)
  service_account_id = element(split("=>", each.value), 2) != "default_sa" ? "projects/${element(split("=>", each.value), 2)}/serviceAccounts/${element(split("=>", each.value), 3)}@${element(split("=>", each.value), 2)}.iam.gserviceaccount.com" : "projects/${element(split("=>", each.value), 0)}/serviceAccounts/${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = element(split("=>", each.value), 1) != "default_sa" ? element(split("=>", each.value), 1) != "default_sa1" ? "serviceAccount:${element(split("=>", each.value), 1)}@${element(split("=>", each.value), 0)}.iam.gserviceaccount.com" : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com" : "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_build_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.service_agent_binding)
  service_account_id = "projects/${element(split("=>", each.value), 1)}/serviceAccounts/${element(split("=>", each.value), 2)}@${element(split("=>", each.value), 1)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "cloud_deploy_service_agent_actas_deploy_sa" {
  depends_on         = [module.deployment_service_accounts, module.trigger_service_account, data.google_project.project]
  for_each           = toset(local.service_agent_binding)
  service_account_id = "projects/${element(split("=>", each.value), 1)}/serviceAccounts/${element(split("=>", each.value), 2)}@${element(split("=>", each.value), 1)}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "binding_gke_sa_to_storage_source" {
  for_each = toset(local.gke_cluster_sa)
  project  = element(split("=>", each.value), 0)
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${element(split("=>", each.value), 1)}"

}


