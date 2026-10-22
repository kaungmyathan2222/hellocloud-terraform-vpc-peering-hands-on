data "terraform_remote_state" "hc-frontend-network" {
  backend = "remote"
  config = {
    organization = "genie"
    workspaces = {
      name = "hc-frontend-network"
    }
  }
}


data "terraform_remote_state" "hc-backend-network" {
  backend = "remote"
  config = {
    organization = "genie"
    workspaces = {
      name = "hc-backend-network"
    }
  }
}

data "aws_caller_identity" "current" {

}

resource "aws_vpc_peering_connection" "frontend_to_backend" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = data.terraform_remote_state.hc-backend-network.outputs.vpc_id
  vpc_id        = data.terraform_remote_state.hc-frontend-network.outputs.vpc_id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between hc-frontend-netwrok and hc-backend-netwrok"
  }
}

resource "aws_route" "hc-frontend-to-hc-backend-02-01" {
  route_table_id            = data.terraform_remote_state.hc-frontend-network.outputs.private_rt_ids["02"]
  destination_cidr_block    = data.terraform_remote_state.hc-backend-network.outputs.private_subnet_cidrs["02"]
  vpc_peering_connection_id = aws_vpc_peering_connection.frontend_to_backend.id
}

resource "aws_route" "hc-frontend-to-hc-backend-02-02" {
  route_table_id            = data.terraform_remote_state.hc-frontend-network.outputs.private_rt_ids["03"]
  destination_cidr_block    = data.terraform_remote_state.hc-backend-network.outputs.private_subnet_cidrs["03"]
  vpc_peering_connection_id = aws_vpc_peering_connection.frontend_to_backend.id
}


resource "aws_route" "hc-backend-to-hc-frontend-03-01" {
  route_table_id            = data.terraform_remote_state.hc-backend-network.outputs.private_rt_ids["02"]
  destination_cidr_block    = data.terraform_remote_state.hc-frontend-network.outputs.private_subnet_cidrs["02"]
  vpc_peering_connection_id = aws_vpc_peering_connection.frontend_to_backend.id
}

resource "aws_route" "hc-backend-to-hc-frontend-03-02" {
  route_table_id            = data.terraform_remote_state.hc-backend-network.outputs.private_rt_ids["03"]
  destination_cidr_block    = data.terraform_remote_state.hc-frontend-network.outputs.private_subnet_cidrs["03"]
  vpc_peering_connection_id = aws_vpc_peering_connection.frontend_to_backend.id
}
