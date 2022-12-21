
module "multiple_project_private_cluster" {

source = "../../../examples/multiple_project_private_gke"
pipeline_spec = [
  {
    pipeline_name = "google-pipeline-diff-gke-2-test"
    location      = "us-central1"
    project       = var.project_id["cloud-deploy-testing"]
    stage_targets = [{
      target                            = "dev-4-test"
      profiles                          = ["test"]
      gke                               = "projects/${var.project_id["cloud-deploy-production"]}/locations/us-central1-c/clusters/cluster-2"
      gke_cluster_sa                    = [var.gke_sa[var.project_id["cloud-deploy-production"]]]
      artifact_storage                  = null
      require_approval                  = false
      execution_configs_service_account = null
      worker_pool                       = "projects/${var.project_id["cloud-deploy-testing"]}/locations/us-central1/workerPools/worker-pool"
      }, {
      target                            = "prod-4-test"
      profiles                          = ["prod"]
      gke                               = "projects/${var.project_id["cloud-deploy-production"]}/locations/us-central1-c/clusters/cluster-2"
      gke_cluster_sa                    = [var.gke_sa[var.project_id["cloud-deploy-production"]]]
      artifact_storage                  = null
      require_approval                  = true
      execution_configs_service_account = "deployment-prod-4-google-test"
      worker_pool                       = "projects/${var.project_id["cloud-deploy-testing"]}/locations/us-central1/workerPools/worker-pool"
    }]
    cloud_trigger_sa = "trigger-sa-4-test"
  }
]

}
