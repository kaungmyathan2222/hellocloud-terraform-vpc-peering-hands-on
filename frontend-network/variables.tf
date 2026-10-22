variable "project" {
  type    = string
  default = "hc-frontend"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.0.253.0/24", "10.0.254.0/24", "10.0.255.0/24"]
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
