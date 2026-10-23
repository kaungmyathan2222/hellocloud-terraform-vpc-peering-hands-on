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
      name = "hc-backend-security"
    }
  }
}

provider "aws" {
  region = var.region
}
