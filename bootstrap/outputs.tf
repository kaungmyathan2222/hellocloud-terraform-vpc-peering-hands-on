output "workspace_ids" {
  description = "map of workspace name -> id"
  value       = { for k, w in tfe_workspace.stack : k => w.id }
}

output "run_triggers" {
  description = "consumer workspace <- producer workspace"
  value       = sort(keys(local.run_triggers))
}
