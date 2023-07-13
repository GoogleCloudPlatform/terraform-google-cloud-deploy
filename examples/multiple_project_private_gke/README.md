# Multiple\_Project\_Private\_Gke

This example is to create delivery pipelines, deploy targets, and their respective service accounts.

## Assumptions and Prerequisites

This example assumes that below mentioned prerequisites are in place before consuming the example.

VPC and VPN creation (https://cloud.google.com/architecture/accessing-private-gke-clusters-with-cloud-build-private-pools)

Edit the Organization Policy "iam.disableCrossProjectServiceAccountUsage" to "not enforce" in all the target project.

Private GKE cluster creation in the target project.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pipeline_spec"></a> [pipeline\_spec](#input\_pipeline\_spec) | List of object specifications for Delivery Pipeline | <pre>list(object({<br>    pipeline_name = string<br>    location      = string<br>    project       = string<br>    stage_targets = list(object({<br>      target                            = string<br>      profiles                          = list(string)<br>      gke                               = string<br>      gke_cluster_sa                    = list(string)<br>      artifact_storage                  = string<br>      require_approval                  = bool<br>      execution_configs_service_account = string<br>      worker_pool                       = string<br>    }))<br>    cloud_trigger_sa = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_deploy_service_account"></a> [cloud\_deploy\_service\_account](#output\_cloud\_deploy\_service\_account) | List of Deploy target Execution Service Account |
| <a name="output_cloud_trigger_service_account"></a> [cloud\_trigger\_service\_account](#output\_cloud\_trigger\_service\_account) | List of Cloud Build Trigger Service Account |
| <a name="output_delivery_pipeline_and_target"></a> [delivery\_pipeline\_and\_target](#output\_delivery\_pipeline\_and\_target) | List of Delivery Pipeline and respective Target |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | n/a | `string` | n/a | yes |
| pipeline\_name | n/a | `string` | n/a | yes |
| project | n/a | `string` | n/a | yes |
| stage\_targets | n/a | <pre>list(object({<br>    target_name        = string<br>    profiles           = list(string)<br>    target_create      = bool<br>    target_type        = string<br>    target_spec        = map(string)<br>    require_approval   = bool<br>    exe_config_sa_name = string<br>    execution_config   = map(string)<br>    strategy           = any<br>  }))</pre> | n/a | yes |
| trigger\_sa\_create | n/a | `bool` | n/a | yes |
| trigger\_sa\_name | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_deploy\_service\_account | List of Deploy target Execution Service Account |
| cloud\_trigger\_service\_account | List of Cloud Build Trigger Service Account |
| delivery\_pipeline\_and\_target | List of Delivery Pipeline and respective Target |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

