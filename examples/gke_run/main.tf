module "cloud_deploy" {
  source = "../../"

  pipeline_name = "google-pipeline-same-gke-1"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source"
  stage_targets = [{
    target_name   = "google-test-1"
    profiles      = ["test"]
    target_create = true
    target_spec = { gke = {
      project_id       = "gdc-clouddeploy-dev"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-1"
      gke_cluster_sa   = "548710651430-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-1-google"
    worker_pool                       = null
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "google-prod-1"
    profiles      = ["prod"]
    target_create = true
    target_spec = { gke = {
      project_id       = "gdc-clouddeploy-dev"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-1"
      gke_cluster_sa   = "548710651430-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-1-google"
    worker_pool                       = null
    strategy                          = {}
    }, {
    target_name   = "google-run-1"
    profiles      = ["run1"]
    target_create = true
    target_spec = { run = {
      project_id     = "gdc-clouddeploy-source"
      location       = "us-central1"
      run_service_sa = "14346266701-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-run-1-google"
    worker_pool                       = null
    strategy                          = {}
    }, {
    target_name   = "google-run-2"
    profiles      = ["run2"]
    target_create = true
    target_spec = { run = {
      project_id     = "gdc-clouddeploy-dev"
      location       = "us-central1"
      run_service_sa = ""
    } }
    artifact_storage                  = null
    require_approval                  = true
    execution_configs_service_account = "deployment-run-2-google"
    worker_pool                       = null
    strategy                          = {}
  }]
  cloud_trigger_sa  = "cd-trigger-1"
  trigger_sa_create = true
}


module "cloud_deploy_resuse" {
  source = "../../"

  pipeline_name = "google-pipeline-same-gke-2"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source"
  stage_targets = [{
    target_name   = "google-test-1"
    profiles      = ["test"]
    target_create = false
    target_spec = { gke = {
      project_id       = "gdc-clouddeploy-dev"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-1"
      gke_cluster_sa   = "548710651430-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-1-google"
    worker_pool                       = null
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "google-prod-1"
    profiles      = ["prod"]
    target_create = false
    target_spec = { gke = {
      project_id       = "gdc-clouddeploy-dev"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-1"
      gke_cluster_sa   = "548710651430-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-1-google"
    worker_pool                       = null
    strategy                          = {}
    }
  ]
  cloud_trigger_sa  = "cd-trigger-1"
  trigger_sa_create = false
}


module "cloud_deploy_resuse2" {
  source = "../../"

  pipeline_name = "google-pipeline-same-gke-3"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source"
  stage_targets = [{
    target_name   = "google-run-1"
    profiles      = ["run1"]
    target_create = false
    target_spec = { run = {
      project_id     = "gdc-clouddeploy-source"
      location       = "us-central1"
      run_service_sa = "14346266701-compute@developer.gserviceaccount.com"
      }
    }
    artifact_storage                  = null
    require_approval                  = false
    execution_configs_service_account = "deployment-run-1-google"
    worker_pool                       = null
    strategy                          = {}
    }, {
    target_name   = "google-run-2"
    profiles      = ["run2"]
    target_create = false
    target_spec = { run = {
      project_id     = "gdc-clouddeploy-dev"
      location       = "us-central1"
      run_service_sa = ""
    } }
    artifact_storage                  = null
    require_approval                  = true
    execution_configs_service_account = "deployment-run-2-google"
    worker_pool                       = null
    strategy                          = {}
  }]
  cloud_trigger_sa  = "cd-trigger-1"
  trigger_sa_create = false
}

