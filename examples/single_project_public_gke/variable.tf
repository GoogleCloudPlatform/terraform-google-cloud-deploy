variable "pipeline_spec" {
  type = list(object({
    pipeline_name = string
    location      = string
    project       = string
    stage_targets = list(object({
      target                            = string
      profiles                          = list(string)
      gke                               = string
      gke_cluster_sa                    = list(string)
      artifact_storage                  = string
      require_approval                  = bool
      execution_configs_service_account = string
      worker_pool                       = string
    }))
    cloud_trigger_sa = string
  }))

  description = "List of object specifications for Delivery Pipeline"
}

