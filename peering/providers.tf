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
      name = "hc-peering"
    }
  }
}

provider "aws" {
  region = var.region
}
