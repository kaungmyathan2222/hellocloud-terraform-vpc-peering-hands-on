variable "organization" {
  description = "HCP Terraform organization"
  type        = string
  default     = "genie"
}

variable "project_name" {
  description = "Existing HCP project that holds the lab workspaces"
  type        = string
  default     = "hc-vpc-peering-vcs-hcp"
}

variable "region" {
  description = "AWS region the stacks deploy into"
  type        = string
  default     = "us-east-1"
}

variable "github_repo" {
  description = "owner/repo backing every workspace"
  type        = string
  default     = "kaungmyathan2222/hellocloud-terraform-vpc-peering-hands-on"
}

variable "github_app_installation_id" {
  description = "HCP's GitHub App installation, taken from the existing VCS connection"
  type        = string
  default     = "ghain-jdpDymSFbf3SGmAr"
}
