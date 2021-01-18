terraform {
  backend "azurerm" {
    resource_group_name   = "lm-devops-rg"
    storage_account_name  = "lmdevopsstor"
    container_name        = "tf-state"
    key                   = "frontline.tfstate"
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
    prefix = "frontline"
}

resource "azurerm_resource_group" "rg" {
  name = "${local.prefix}-rg-${var.env}"
  location = var.location
}

resource "azurerm_app_service_plan" "asp" {
    name                = "${local.prefix}-asp-${var.env}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    
    sku {
        tier = "Standard"
        size = "S1"
    }
}

resource "azurerm_app_service" "web" {
    name                = "${local.prefix}-web-${var.env}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id
}

resource "azurerm_app_service_slot" "slot" {
    name                = "${local.prefix}-web-${var.env}-slot"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id
    app_service_name    = azurerm_app_service.web.name
}