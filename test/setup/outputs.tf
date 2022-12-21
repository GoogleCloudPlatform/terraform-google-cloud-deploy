output "project_id" {
  value = {for i in toset(local.projects): i => module.project[i].project_id } 
}
output "gke_sa" {
  value = { for i in toset(local.projects): module.project[i].project_id => data.google_compute_default_service_account.default[i].email }
}
