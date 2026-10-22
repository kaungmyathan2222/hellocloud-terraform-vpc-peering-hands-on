output "pcx_id" {
  description = "id of the frontend <-> backend vpc peering connection"
  value       = aws_vpc_peering_connection.frontend_to_backend.id
}

output "vpc_ids" {
  description = "vpc ids participating in the peering (by side)"
  value = {
    frontend = data.terraform_remote_state.hc-frontend-network.outputs.vpc_id
    backend  = data.terraform_remote_state.hc-backend-network.outputs.vpc_id
  }
}

output "cidrs" {
  description = "supernet cidrs of the peered vpcs (by side)"
  value = {
    frontend = data.terraform_remote_state.hc-frontend-network.outputs.vpc_cidr
    backend  = data.terraform_remote_state.hc-backend-network.outputs.vpc_cidr
  }
}
