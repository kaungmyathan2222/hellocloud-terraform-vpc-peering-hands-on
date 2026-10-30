
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "hc-backend"
}

variable "my_ip" {
  # No default on purpose: a VCS-driven run cannot take -var, so a committed
  # default would silently become permanent. Value comes from the aws-oidc set.
  description = "Admin CIDR allowed to SSH"
  type        = string
}
