data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "genie"

    workspaces = {
      name = "hc-frontend-network"
    }
  }
}

data "terraform_remote_state" "backend_security" {
  backend = "remote"

  config = {
    organization = "genie"

    workspaces = {
      name = "hc-backend-security"
    }
  }
}

resource "aws_security_group" "pub_sgp_01" {
  name   = "pub-sgp-01"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "${var.project}-pub-sgp-01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_pub_sgp_01" {
  security_group_id = aws_security_group.pub_sgp_01.id
  cidr_ipv4         = var.my_ip
  from_port         = 8
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_pub_sgp_01" {
  security_group_id = aws_security_group.pub_sgp_01.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_pub_sgp_01" {
  security_group_id = aws_security_group.pub_sgp_01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_security_group" "pri_sgp_01" {
  name   = "pri-sgp-01"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "${var.project}-pri-sgp-01"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_pri_sgp_01" {
  security_group_id            = aws_security_group.pri_sgp_01.id
  referenced_security_group_id = aws_security_group.pub_sgp_01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_pri_sgp_01" {
  security_group_id            = aws_security_group.pri_sgp_01.id
  referenced_security_group_id = aws_security_group.pub_sgp_01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_pri_sgp_01" {
  security_group_id = aws_security_group.pri_sgp_01.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "pri_sgp_02" {
  name   = "pri-sgp-02"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "${var.project}-pri-sgp-02"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = aws_security_group.pri_sgp_01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = aws_security_group.pri_sgp_01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_backend_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-02"]
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_backend_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-02"]
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_icmp_ipv4_to_backend_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-02"]
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_ipv4_to_backend_pri_sgp_02" {
  security_group_id            = aws_security_group.pri_sgp_02.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-02"]
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_security_group" "pri_sgp_03" {
  name   = "pri-sgp-03"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "${var.project}-pri-sgp-03"
  }
}



resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = aws_security_group.pri_sgp_01.id
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = aws_security_group.pri_sgp_01.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_icmp_ipv4_backend_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-03"]
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_backend_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-03"]
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_icmp_ipv4_to_backend_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-03"]
  from_port                    = 8
  ip_protocol                  = "icmp"
  to_port                      = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_ipv4_to_backend_pri_sgp_03" {
  security_group_id            = aws_security_group.pri_sgp_03.id
  referenced_security_group_id = data.terraform_remote_state.backend_security.outputs.security_group_ids["private-03"]
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

# VPC resolver (.2 of the VPC CIDR) — the -02/-03 tiers have no allow-all egress,
# so peer-hostname lookups need this explicitly once peer DNS resolution is on.
resource "aws_vpc_security_group_egress_rule" "allow_dns_udp_ipv4_pri_sgp_02" {
  security_group_id = aws_security_group.pri_sgp_02.id
  cidr_ipv4         = "${cidrhost(data.terraform_remote_state.network.outputs.vpc_cidr, 2)}/32"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}

resource "aws_vpc_security_group_egress_rule" "allow_dns_udp_ipv4_pri_sgp_03" {
  security_group_id = aws_security_group.pri_sgp_03.id
  cidr_ipv4         = "${cidrhost(data.terraform_remote_state.network.outputs.vpc_cidr, 2)}/32"
  from_port         = 53
  ip_protocol       = "udp"
  to_port           = 53
}
