# Cloud Deploy terraform module

This module is used  to create Google Cloud Deploy [delivery pipelines, targets](https://cloud.google.com/deploy/docs/create-pipeline-targets) and their respective service accounts.

## Prerequisites

This example needs below mentioned prerequisites are in place before consuming the example.

Target GKE clusters should be operational

Edit the Organization Policy "iam.disableCrossProjectServiceAccountUsage" to "not enforce" in all the target project in case deployment service accounts are created in different projects.

Cloud deploy manifests file repo should be connected in cloud builds trigger section

VPC and VPN creation (https://cloud.google.com/architecture/accessing-private-gke-clusters-with-cloud-build-private-pools) for private clusters

The service accounts and targets are unique across delivery pipeline.

## Sample Usage:

```hcl
module "cloud_deploy" {
  source = "terraform-google-modules/cloud-deploy/google"
  pipeline_name = "google-pipeline-same-gke-1"
  location      = "us-central1"
  project       = "gdc-clouddeploy-source"
  stage_targets = [{
    target_name   = "dev-1-test"
    profiles      = ["test"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = "gdc-clouddeploy-source"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = "14346266701-compute@developer.gserviceaccount.com"
    }
    require_approval   = false
    exe_config_sa_name = "deployment-test-1-google-test"
    execution_config = {
      execution_timeout = "3600s"
      worker_pool       = null
      artifact_storage  = ""
    }
    strategy = {
      standard = {
        verify = true
      }
    }
    }, {
    target_name   = "prod-1-test"
    profiles      = ["prod"]
    target_create = true
    target_type   = "gke"
    target_spec = {
      project_id       = "gdc-clouddeploy-source"
      location         = "us-central1-c"
      gke_cluster_name = "cluster-2"
      gke_cluster_sa   = "14346266701-compute@developer.gserviceaccount.com"
     }
    require_approval   = true
    exe_config_sa_name = "deployment-prod-1-google-test"
    execution_config   = {}
    strategy           = {}
  }]
  trigger_sa_name   = "cd-trigger-1"
  trigger_sa_create = true
}

```



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Location of the Pipeline | `string` | n/a | yes |
| pipeline\_name | Name of the Delivery Pipeline | `string` | n/a | yes |
| project | Project ID | `string` | n/a | yes |
| stage\_targets | List of object specifications for Deploy Targets | <pre>list(object({<br>    target_name        = string<br>    profiles           = list(string)<br>    target_create      = bool<br>    target_type        = string<br>    target_spec        = map(string)<br>    require_approval   = bool<br>    exe_config_sa_name = string<br>    execution_config   = map(string)<br>    strategy           = any<br>  }))</pre> | n/a | yes |
| trigger\_sa\_create | True for trigger service account creation, False to reuse existing trigger service account | `bool` | `true` | no |
| trigger\_sa\_name | Name of the Trigger service account | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| delivery\_pipeline\_and\_target | List of Delivery Pipeline and respective Target |
| execution\_sa | List of Deploy target Execution Service Account |
| trigger\_sa | List of Cloud Build Trigger Service Account |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this example.

## Software

The following dependencies must be available:

* Terraform ~> v0.13+
* Terraform Provider for GCP ~> v3.53+
* Terraform Provider for GCP Beta ~> v3.53+


## Service Account:

Add yourself to service account user roles for the created service account.

## APIs

Enable below api's

* "clouddeploy.googleapis.com"
* "container.googleapis.com".

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
