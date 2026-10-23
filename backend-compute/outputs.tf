output "instance_ids" {
  description = "map of backend instance ids by tier"
  value = {
    "public-01"  = aws_instance.backend_public_instance01.id
    "private-01" = aws_instance.backend_private_instance01.id
    "private-02" = aws_instance.backend_private_instance02.id
    "private-03" = aws_instance.backend_private_instance03.id
  }
}

output "private_ips" {
  description = "map of backend instance private ips by tier — evidence-run targets"
  value = {
    "public-01"  = aws_instance.backend_public_instance01.private_ip
    "private-01" = aws_instance.backend_private_instance01.private_ip
    "private-02" = aws_instance.backend_private_instance02.private_ip
    "private-03" = aws_instance.backend_private_instance03.private_ip
  }
}

output "bastion_public_ip" {
  description = "backend public instance (bastion) ip for ssh entrypoint"
  value       = aws_instance.backend_public_instance01.public_ip
}
