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
  description = "AWS region published to every workspace as AWS_DEFAULT_REGION"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  description = "Optional: set via TF_VAR_aws_access_key_id to manage the credential here instead of in the UI"
  type        = string
  default     = null
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "Optional: set via TF_VAR_aws_secret_access_key"
  type        = string
  default     = null
  sensitive   = true
}
