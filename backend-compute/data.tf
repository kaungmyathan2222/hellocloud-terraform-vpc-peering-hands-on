data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "genie"

    workspaces = {
      name = "hc-backend-network"
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "genie"

    workspaces = {
      name = "hc-backend-security"
    }
  }
}

data "aws_key_pair" "my-hellocloud-keypair" {
  key_name           = "my-aws-hellocloud-keypair"
  include_public_key = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"] # Use the official alias directly

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
