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

    pipeline_name                = "google-pipeline-same-gke-1"
    location                     = "us-central1"
    project                      = "gdc-clouddeploy-source"
    stage_targets = [{
      target                            = "google-test-1"
      profiles                          = ["test"]
      gke                               = "projects/gdc-clouddeploy-source/locations/us-central1-c/clusters/cluster-1"
      gke_cluster_sa                    = ["14346266701-compute@developer.gserviceaccount.com"]
      artifact_storage                  = null
      require_approval                  = false
      execution_configs_service_account = "deployment-test-1-google"
      worker_pool                       = null
      }, {
      target                            = "google-prod-1"
      profiles                          = ["prod"]
      gke                               = "projects/gdc-clouddeploy-source/locations/us-central1-c/clusters/cluster-1"
      gke_cluster_sa                    = ["14346266701-compute@developer.gserviceaccount.com"]
      artifact_storage                  = null
      require_approval                  = true
      execution_configs_service_account = "deployment-prod-1-google"
      worker_pool                       = null
    }]
    cloud_trigger_sa = "cd-trigger-1"
}
```



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_trigger\_sa | Name of the Trigger service account | `string` | n/a | yes |
| location | Location of the Pipeline | `string` | n/a | yes |
| pipeline\_name | Name of the Delivery Pipeline | `string` | n/a | yes |
| project | Project Name | `string` | n/a | yes |
| stage\_targets | List of object specifications for Deploy Targets | <pre>list(object({<br>    target                            = string<br>    profiles                          = list(string)<br>    gke                               = string<br>    gke_cluster_sa                    = list(string)<br>    artifact_storage                  = string<br>    require_approval                  = bool<br>    execution_configs_service_account = string<br>    worker_pool                       = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_trigger\_sa | List of Cloud Build Trigger Service Account |
| delivery\_pipeline\_and\_target | List of Delivery Pipeline and respective Target |
| deployment\_sa | List of Deploy target Execution Service Account |

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
