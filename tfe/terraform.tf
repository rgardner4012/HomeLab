terraform {
  required_version = ">= 1.6"

  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "~> 2.4" # v3-API-based resources still ship in current provider
    }
  }

  # CLI-driven workspace: state + execution in HCP, runs dispatch to your
  # in-network agent. `terraform login` once on this machine first.
  cloud {
    organization = "homelab_nutanix"
    workspaces {
      name = "hl-dev"
    }
  }
}
