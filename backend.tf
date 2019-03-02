terraform {
  backend "azurerm" {
    resource_group_name  = "hashicorp-meetup-backend-rg"
    storage_account_name = "redapthashicorpmeetup"
    container_name       = "terraform-storage"
    key                  = "hashicorp-platform.tfstate"
    use_msi              = true
  }
}
