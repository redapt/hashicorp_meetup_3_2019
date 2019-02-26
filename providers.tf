provider "aws" {
  region = "us-west-2"
}

provider "azurerm" {}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
