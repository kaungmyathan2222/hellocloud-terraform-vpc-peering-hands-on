resource "aws_instance" "frontend_public_instance01" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my-hellocloud-keypair.key_name
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnets["public-subnet-01"]
  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_ids["public-01"]]
  tags = {
    Name = "${var.project}-public-instance"
  }
}

resource "aws_instance" "frontend_private_instance01" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my-hellocloud-keypair.key_name
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnets["private-subnet-01"]
  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_ids["private-01"]]
  tags = {
    Name = "${var.project}-private-instance-01"
  }
}

resource "aws_instance" "frontend_private_instance02" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my-hellocloud-keypair.key_name
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnets["private-subnet-02"]
  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_ids["private-02"]]
  tags = {
    Name = "${var.project}-private-instance-02"
  }
}

resource "aws_instance" "frontend_private_instance03" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = data.aws_key_pair.my-hellocloud-keypair.key_name
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnets["private-subnet-03"]
  vpc_security_group_ids = [data.terraform_remote_state.security.outputs.security_group_ids["private-03"]]
  tags = {
    Name = "${var.project}-private-instance-03"
  }
}
