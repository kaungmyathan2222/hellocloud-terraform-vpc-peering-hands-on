data "tfe_project" "lab" {
  name         = var.project_name
  organization = var.organization
}

locals {
  # workspace name -> directory in this repo
  stacks = {
    "hc-frontend-network"  = "frontend-network"
    "hc-backend-network"   = "backend-network"
    "hc-frontend-security" = "frontend-security"
    "hc-backend-security"  = "backend-security"
    "hc-peering"           = "peering"
    "hc-frontend-compute"  = "frontend-compute"
    "hc-backend-compute"   = "backend-compute"
  }

  # producer -> who may read its outputs via terraform_remote_state.
  # Mirrors the dependency tree: network -> security -> peering, compute off each side.
  state_consumers = {
    "hc-frontend-network"  = ["hc-frontend-security", "hc-frontend-compute", "hc-peering"]
    "hc-backend-network"   = ["hc-backend-security", "hc-backend-compute", "hc-peering"]
    "hc-frontend-security" = ["hc-frontend-compute", "hc-peering"]
    "hc-backend-security"  = ["hc-backend-compute", "hc-peering"]
    "hc-peering"           = []
    "hc-frontend-compute"  = []
    "hc-backend-compute"   = []
  }

  aws_env_vars = merge(
    { AWS_DEFAULT_REGION = var.region },
    var.aws_access_key_id == null ? {} : { AWS_ACCESS_KEY_ID = var.aws_access_key_id },
    var.aws_secret_access_key == null ? {} : { AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key },
  )
}

resource "tfe_workspace" "stack" {
  for_each = local.stacks

  name              = each.key
  organization      = var.organization
  project_id        = data.tfe_project.lab.id
  working_directory = each.value

  # No vcs_repo block: GitHub Actions drives applies through the CLI, and a
  # VCS-connected workspace refuses CLI applies.
  queue_all_runs     = false
  auto_apply         = false
  allow_destroy_plan = true

  description = "Lab stack: ${each.value}"
}

resource "tfe_workspace_settings" "stack" {
  for_each = tfe_workspace.stack

  workspace_id   = each.value.id
  execution_mode = "remote"

  # Only the listed workspaces may read this one's outputs.
  global_remote_state = false
  remote_state_consumer_ids = [
    for name in local.state_consumers[each.key] : tfe_workspace.stack[name].id
  ]
}

resource "tfe_variable_set" "aws" {
  name         = "aws-credentials"
  description  = "AWS env credentials shared by every lab workspace"
  organization = var.organization
}

resource "tfe_project_variable_set" "aws" {
  variable_set_id = tfe_variable_set.aws.id
  project_id      = data.tfe_project.lab.id
}

resource "tfe_variable" "aws" {
  for_each = local.aws_env_vars

  key             = each.key
  value           = each.value
  category        = "env"
  sensitive       = each.key != "AWS_DEFAULT_REGION"
  variable_set_id = tfe_variable_set.aws.id
}
