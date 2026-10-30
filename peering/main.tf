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

data "terraform_remote_state" "hc-frontend-security" {
  backend = "remote"
  config = {
    organization = "genie"
    workspaces = {
      name = "hc-frontend-security"
    }
  }
}

data "terraform_remote_state" "hc-backend-security" {
  backend = "remote"
  config = {
    organization = "genie"
    workspaces = {
      name = "hc-backend-security"
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

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

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

# ---------------------------------------------------------------------------
# Cross-VPC SG portals
#
# These live here, not in the security stacks, because a peer-group reference is
# only meaningful while the PCX exists — and because security-to-security reads
# would make the two security workspaces mutually dependent (neither could apply
# first on a clean slate). Same-ordinal pairs only, matching the route layout.
# ---------------------------------------------------------------------------

locals {
  fe_sgs = data.terraform_remote_state.hc-frontend-security.outputs.security_group_ids
  be_sgs = data.terraform_remote_state.hc-backend-security.outputs.security_group_ids

  # one entry per security group that gets a portal; peer = the group on the far side
  portals = {
    "fe-02" = { sg = local.fe_sgs["private-02"], peer = local.be_sgs["private-02"] }
    "fe-03" = { sg = local.fe_sgs["private-03"], peer = local.be_sgs["private-03"] }
    "be-02" = { sg = local.be_sgs["private-02"], peer = local.fe_sgs["private-02"] }
    "be-03" = { sg = local.be_sgs["private-03"], peer = local.fe_sgs["private-03"] }
  }
}

resource "aws_vpc_security_group_ingress_rule" "portal_icmp" {
  for_each   = local.portals
  depends_on = [aws_vpc_peering_connection.frontend_to_backend]

  security_group_id            = each.value.sg
  referenced_security_group_id = each.value.peer
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "portal_ssh" {
  for_each   = local.portals
  depends_on = [aws_vpc_peering_connection.frontend_to_backend]

  security_group_id            = each.value.sg
  referenced_security_group_id = each.value.peer
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "portal_icmp" {
  for_each   = local.portals
  depends_on = [aws_vpc_peering_connection.frontend_to_backend]

  security_group_id            = each.value.sg
  referenced_security_group_id = each.value.peer
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_egress_rule" "portal_ssh" {
  for_each   = local.portals
  depends_on = [aws_vpc_peering_connection.frontend_to_backend]

  security_group_id            = each.value.sg
  referenced_security_group_id = each.value.peer
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}
