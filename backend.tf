terraform {
  backend "azurerm" {
    use_msi = true
  }
}