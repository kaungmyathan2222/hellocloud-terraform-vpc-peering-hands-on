# This stack manages the HCP workspaces that run every other stack in this repo.
# Its own state lives in hc-admin -- the one workspace created by hand, because
# a stack cannot manage the workspace holding its own state.

terraform {
  required_version = ">= 1.12"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.82"
    }
  }

  cloud {
    organization = "genie"
    workspaces {
      project = "hc-vpc-peering-vcs-hcp"
      name    = "hc-admin"
    }
  }
}

# Token comes from TFE_TOKEN. Use a team token: personal tokens die with the account.
provider "tfe" {
  organization = var.organization
}
