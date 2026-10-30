data "tfe_project" "lab" {
  name         = var.project_name
  organization = var.organization
}

locals {
  # workspace name -> directory in this repo, and whether a merge applies itself.
  # Network and security auto-apply; peering and compute stop at Confirm & apply
  # because they touch instances and cross-VPC routing.
  stacks = {
    "hc-frontend-network"  = { dir = "frontend-network", auto_apply = true }
    "hc-backend-network"   = { dir = "backend-network", auto_apply = true }
    "hc-frontend-security" = { dir = "frontend-security", auto_apply = true }
    "hc-backend-security"  = { dir = "backend-security", auto_apply = true }
    "hc-peering"           = { dir = "peering", auto_apply = false }
    "hc-frontend-compute"  = { dir = "frontend-compute", auto_apply = false }
    "hc-backend-compute"   = { dir = "backend-compute", auto_apply = false }
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

  # Sharing lets a consumer READ outputs; it does not make it re-plan.
  # Flatten the same graph into consumer <- producer pairs for run triggers.
  run_triggers = merge([
    for producer, consumers in local.state_consumers : {
      for c in consumers : "${c}__from__${producer}" => {
        consumer = c
        producer = producer
      }
    }
  ]...)
}

resource "tfe_workspace" "stack" {
  for_each = local.stacks

  name              = each.key
  organization      = var.organization
  project_id        = data.tfe_project.lab.id
  working_directory = each.value.dir
  description       = "Lab stack: ${each.value.dir}"

  auto_apply         = each.value.auto_apply
  allow_destroy_plan = true

  queue_all_runs        = true
  file_triggers_enabled = true

  speculative_enabled = true

  vcs_repo {
    identifier                 = var.github_repo
    branch                     = "main"
    github_app_installation_id = var.github_app_installation_id
  }
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

resource "tfe_run_trigger" "stack" {
  for_each = local.run_triggers

  workspace_id  = tfe_workspace.stack[each.value.consumer].id
  sourceable_id = tfe_workspace.stack[each.value.producer].id
}

# The aws-oidc variable set (TFC_AWS_* dynamic credentials, plus my_ip) already
# exists and is attached to this project. Left unmanaged on purpose: declaring it
# here would create a second, duplicate set.

# One-shot adoption of the two workspaces built by hand before this stack existed.
# Delete both blocks once the apply succeeds.
