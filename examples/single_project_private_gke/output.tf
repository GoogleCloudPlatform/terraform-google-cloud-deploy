output "cloud_trigger_service_account" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy[i].cloud_trigger_sa]
  description = "List of Cloud Build Trigger Service Account"
}

output "cloud_deploy_service_account" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy[i].deployment_sa]
  description = "List of Deploy target Execution Service Account"
}

output "delivery_pipeline_and_target" {
  value       = [for i in var.pipeline_spec[*].pipeline_name : module.cloud_deploy[i].delivery_pipeline_and_target]
  description = "List of Delivery Pipeline and respective Target"
}

