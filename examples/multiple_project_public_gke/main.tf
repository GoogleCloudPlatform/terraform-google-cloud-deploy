module "cloud_deploy" {

  source           = "../../"
  for_each         = { for i in var.pipeline_spec : i.pipeline_name => i }
  pipeline_name    = each.key
  location         = each.value.location
  project          = each.value.project
  stage_targets    = each.value.stage_targets
  cloud_trigger_sa = each.value.cloud_trigger_sa
}
