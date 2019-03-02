terraform {
  backend "azurerm" {
    storage_account_name = "redapthashicorpmeetup"
    container_name       = "terraform-storage"
    key                  = "hashicorp-platform.tfstate"
  }
}
