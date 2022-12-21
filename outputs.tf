output "cloud_trigger_sa" {
  value = [for i in local.trigger_sa : module.trigger_service_account[i].email]
  description = "List of Cloud Build Trigger Service Account"
}

output "deployment_sa" {
  value = [for i in local.target_sa : module.deployment_service_accounts[i].email]
  description = "List of Deploy target Execution Service Account"
}


output "delivery_pipeline_and_target" {
  value = {google_clouddeploy_delivery_pipeline.delivery_pipeline["${var.project}-${var.location}-${var.pipeline_name}"].id = flatten([for j in var.stage_targets[*].target : google_clouddeploy_target.target["${var.project}-${var.location}-${j}"].id])}
  description = "List of Delivery Pipeline and respective Target"
}
