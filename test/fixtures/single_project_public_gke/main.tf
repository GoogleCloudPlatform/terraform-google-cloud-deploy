
module "single_project_public_cluster" {

source = "../../../examples/single_project_public_gke"
pipeline_spec = [
  {
    pipeline_name = "google-pipeline-same-gke-1-test"
    location      = "us-central1"
    project       = var.project_id["ci-cloud-deploy-test"]
    stage_targets = [{
      target                            = "dev-1-test"
      profiles                          = ["test"]
      gke                               = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1-c/clusters/cluster-2"
      gke_cluster_sa                    = [var.gke_sa[var.project_id["ci-cloud-deploy-test"]]]
      artifact_storage                  = null
      require_approval                  = false
      execution_configs_service_account = null
      worker_pool                       = null
      }, {
      target                            = "prod-1-test"
      profiles                          = ["prod"]
      gke                               = "projects/${var.project_id["ci-cloud-deploy-test"]}/locations/us-central1-c/clusters/cluster-2"
      gke_cluster_sa                    = [var.gke_sa[var.project_id["ci-cloud-deploy-test"]]]
      artifact_storage                  = null
      require_approval                  = true
      execution_configs_service_account = "deployment-prod-1-google-test"
      worker_pool                       = null
    }]
    cloud_trigger_sa = "trigger-sa-1-test"
  }
]

}
