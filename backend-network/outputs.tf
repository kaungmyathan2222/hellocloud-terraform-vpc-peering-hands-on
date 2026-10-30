output "vpc_id" {
  description = "hc-backend-vpc id modified for testing purpose."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "hc-backend-vpc cidr block"
  value       = var.vpc_cidr
}

output "public_subnets" {
  description = "map of backend public subnet name -> subnet id"
  value       = local.public_subnets
}

output "private_subnets" {
  description = "map of backend private subnet name -> subnet id"
  value       = local.private_subnets
}

output "igw_id" {
  description = "backend internet gateway id"
  value       = aws_internet_gateway.main.id
}

output "nat_gw_id" {
  description = "backend regional nat gateway id"
  value       = aws_nat_gateway.main.id
}

output "public_rt_id" {
  description = "backend public route table id"
  value       = aws_route_table.public-rtb.id
}

output "private_rt_ids" {
  description = "map of backend private route table ids (per-AZ: 01, 02, 03)"
  value = {
    "01" = aws_route_table.private-rtb-01.id
    "02" = aws_route_table.private-rtb-02.id
    "03" = aws_route_table.private-rtb-03.id
  }
}

output "peering_target" {
  description = "supernet info for cross-vpc peering consumers"
  value = {
    region = var.region
    cidr   = var.vpc_cidr
  }
}

output "private_subnet_cidrs" {
  description = "map of backend private subnet cidr blocks by ordinal (01-03)"
  value = {
    "01" = aws_subnet.private-subnet-01.cidr_block
    "02" = aws_subnet.private-subnet-02.cidr_block
    "03" = aws_subnet.private-subnet-03.cidr_block
  }
}

output "public_subnet_cidrs" {
  description = "map of backend public subnet cidr blocks by ordinal (01-03)"
  value = {
    "01" = aws_subnet.public-subnet-01.cidr_block
    "02" = aws_subnet.public-subnet-02.cidr_block
    "03" = aws_subnet.public-subnet-03.cidr_block
  }
}
