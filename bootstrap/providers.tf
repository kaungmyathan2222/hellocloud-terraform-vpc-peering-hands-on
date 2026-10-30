# Local state on purpose: this stack creates the HCP workspaces, so it cannot
# live in one of them. Keep terraform.tfstate here (it is gitignored) or move it
# into a hand-made admin workspace later.

terraform {
  required_version = ">= 1.12"

  required_providers {
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}

# Credentials come from the TFE_TOKEN env var, or ~/.terraform.d/credentials.tfrc.json
provider "tfe" {
  organization = var.organization
}
