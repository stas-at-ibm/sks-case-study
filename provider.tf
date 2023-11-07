terraform {
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
      version = "~> 0.30.1"
    }
  }
}

provider "exoscale" {}