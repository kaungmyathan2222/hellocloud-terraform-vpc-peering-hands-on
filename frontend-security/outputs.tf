output "security_group_ids" {
  description = "map of frontend security group ids by tier"
  value = {
    "public-01"  = aws_security_group.pub_sgp_01.id
    "private-01" = aws_security_group.pri_sgp_01.id
    "private-02" = aws_security_group.pri_sgp_02.id
    "private-03" = aws_security_group.pri_sgp_03.id
  }
}
