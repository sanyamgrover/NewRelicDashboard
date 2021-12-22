terraform {
  required_version = ">= 1.0.0"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.30"
    }
  }
}

provider "newrelic" {
  api_key    = var.newrelic_api_key
  account_id = var.newrelic_account_id
  region     = "US"
}
