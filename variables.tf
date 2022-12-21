variable "stage_targets" {
  type = list(object({
      target                            = string
      profiles                          = list(string)
      gke                               = string
      gke_cluster_sa                    = list(string)
      artifact_storage                  = string
      require_approval                  = bool
      execution_configs_service_account = string
      worker_pool                       = string
  }))
  description = "List of object specifications for Deploy Targets"
}

variable "pipeline_name" {
  type = string
  description = "Name of the Delivery Pipeline"
}

variable "location" {
  type = string
  description = "Location of the Pipeline"
}

variable "project" {
  type = string
  description = "Project Name"
}

variable "cloud_trigger_sa" {
  type = string
  description = "Name of the Trigger service account"
}
