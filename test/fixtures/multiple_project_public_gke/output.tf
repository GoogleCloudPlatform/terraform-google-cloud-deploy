output "delivery_pipeline_and_target" {
  value = module.multiple_project_public_cluster.delivery_pipeline_and_target
}

output "cloud_trigger_service_account" {
  value = module.multiple_project_public_cluster.cloud_deploy_service_account
}

output "cloud_deploy_service_account" {
  value = module.multiple_project_public_cluster.delivery_pipeline_and_target
}

output "project_id" {
  value = var.project_id["ci-cloud-deploy-test"]
}

output "target_project_id" {
  value = var.project_id["ci-cloud-deploy-prod"]
}
