
variable "location" {
  type    = "string"
  default = "eastus2"
}

variable "agents_size" {
  type    = "string"
  default = "Standard_B2s"
}

variable "prefix" {
  type    = "string"
  default = "advent"
}

provider "azurerm" {}

provider "azuread" {}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
}

resource "random_password" "aks_sp" {
  length  = 16
  special = false
}

resource "azuread_application" "aks_sp" {
  name = "advent-aks"
}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_sp.application_id
}

resource "azuread_service_principal_password" "aks_sp" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp.result
  end_date_relative    = "17520h"
}

resource "azurerm_resource_group" "aks" {
  name     = "${var.prefix}-aks"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "advent" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.prefix
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name               = "default"
    node_count         = 3
    vm_size            = "Standard_B2s"
    availability_zones = [1, 2, 3]
    type               = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = random_password.aks_sp.result
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_user_assigned_identity" "aks_user_msi" {
  resource_group_name = azurerm_kubernetes_cluster.advent.node_resource_group
  location            = azurerm_resource_group.aks.location

  name = "aks-user-msi"
}