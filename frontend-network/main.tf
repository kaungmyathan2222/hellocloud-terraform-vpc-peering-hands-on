resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_subnet" "public-subnet-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidrs[0]
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-public-subnet-01"
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidrs[1]
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-public-subnet-02"
  }
}

resource "aws_subnet" "public-subnet-03" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidrs[2]
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.project}-public-subnet-03"
  }
}

resource "aws_subnet" "private-subnet-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidrs[0]
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-private-subnet-01"
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidrs[1]
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-private-subnet-02"
  }
}

resource "aws_subnet" "private-subnet-03" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidrs[2]
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.project}-private-subnet-03"
  }
}

locals {
  public_subnets = {
    "public-subnet-01" = aws_subnet.public-subnet-01.id
    "public-subnet-02" = aws_subnet.public-subnet-02.id
    "public-subnet-03" = aws_subnet.public-subnet-03.id
  }
  private_subnets = {
    "private-subnet-01" = aws_subnet.private-subnet-01.id
    "private-subnet-02" = aws_subnet.private-subnet-02.id
    "private-subnet-03" = aws_subnet.private-subnet-03.id
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-public-rtb"
  }
}

resource "aws_route_table_association" "public-rtb-association" {
  for_each       = local.public_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_nat_gateway" "main" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"
  depends_on        = [aws_internet_gateway.main]
  tags = {
    Name = "${var.project}-nat-gateway"
  }
}


resource "aws_route_table" "private-rtb-01" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${var.project}-private-rtb"
  }
}

resource "aws_route_table_association" "private-rtb-association" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.private-rtb-01.id
}

resource "aws_route_table" "private-rtb-02" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-private-rtb-02"
  }
}

resource "aws_route_table_association" "private-rtb-association-02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.private-rtb-02.id
}

resource "aws_route_table" "private-rtb-03" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project}-private-rtb-03"
  }
}

resource "aws_route_table_association" "private-rtb-association-03" {
  subnet_id      = aws_subnet.private-subnet-03.id
  route_table_id = aws_route_table.private-rtb-03.id
}
