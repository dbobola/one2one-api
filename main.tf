provider "azurerm" {
    version = "3.0.0"
    features {}
}


terraform {
        backend "azurerm" {
            resource_group_name = 'one2oneapi'
            storage_account_name = 'one2onestorageaccount'
            container_name = 'one2oneblobcontainer'
            key = "terraform.tfstate"
        }
    }
variable imagebuild {
  type        = string
  description = "Latest One2one API Image Build"
}


resource "azurerm_resource_group" "one2one-rgf" {
    name = "one2one-rg"
    location = "UAE North"
}

resource "azurerm_container_group" "" {
    name = "one2one-cn-rsc"
    location = azurerm_resource_group.one2one.location
    resource_group_name = azurerm_resource_group.one2one.name
    ip_address_type     = "Public"
    dns_name_label      = "one2one-api-cn"
    os_type             = "Linux"
    container {
        name            = "one2one-cn"
        image           = "dbobola/one2oneapi:${var.imagebuild}"
            cpu             = "1"
            memory          = "1"

            ports {
                port        = 80
                protocol    = "TCP"
            }
    }
}