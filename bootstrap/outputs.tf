output "workspace_ids" {
  description = "map of workspace name -> id"
  value       = { for k, w in tfe_workspace.stack : k => w.id }
}

output "variable_set_id" {
  description = "id of the shared AWS credential variable set"
  value       = tfe_variable_set.aws.id
}
