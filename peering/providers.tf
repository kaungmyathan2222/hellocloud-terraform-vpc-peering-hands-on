terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  cloud {
    organization = "genie"
    workspaces {
      # Pinned: the org default project is hc-vpc-peering, but the aws-oidc
      # varset and the IAM trust policy both scope to hc-vpc-peering-vcs-hcp.
      project = "hc-vpc-peering-vcs-hcp"
      name    = "hc-peering"
    }
  }
}

provider "aws" {
  region = var.region
}
