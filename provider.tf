terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.63.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {    
    }
}

terraform {
   backend "azurerm" {
    resource_group_name  = "ResourceGroup Of Storage Account"
    storage_account_name = "Storage Account Name for stock you Tf"
    container_name       = "Storage Account Container Name"
    key                  = "Key of your storage account"
   } 
}
