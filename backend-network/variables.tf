variable "project" {
  type    = string
  default = "hc-backend-vpc"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "private_cidrs" {
  type    = list(string)
  default = ["192.168.253.0/24", "192.168.254.0/24", "192.168.255.0/24"]
}

variable "public_cidrs" {
  type    = list(string)
  default = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}
