provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "git::https://github.com/danielscholl-terraform/module-resource-group?ref=v1.0.0"

  name     = "iac-terraform"
  location = "eastus2"

  resource_tags = {
    iac = "terraform"
  }
}

data "http" "my_ip" {
  url = "https://ifconfig.me"
}

module "storage_account" {
  source     = "../"
  depends_on = [module.resource_group]

  resource_group_name = module.resource_group.name
  name                = substr("iacterraform${module.resource_group.random}", 0, 23)

  default_network_rule = "Deny"
  access_list = {
    "my_ip" = data.http.my_ip.body
  }

  containers = [
    {
      name        = "iac-container",
      access_type = "private"
    }
  ]

  resource_tags = {
    iac = "terraform"
  }
}
