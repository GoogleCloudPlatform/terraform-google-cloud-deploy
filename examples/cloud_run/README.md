# Cloud Run Targets

This examples create a cloud run target for the cloud deploy pipeline

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

