terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.49.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

variable "subscription_id" {
  description = "Subscription that hosts the lab resources"
  type        = string
  default     = "03514587-4953-448c-a100-b43f615f10b5"
}

variable "tenant_domain" {
  description = "Primary domain for the Entra ID tenant"
  type        = string
  default     = "betterpretergmail.onmicrosoft.com"
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group for storage assets"
  type        = string
  default     = "rg-eli-lab1"
}

variable "flag_text" {
  description = "Content that will be uploaded into Lab1_Flag.txt"
  type        = string
  default     = "Flag{eliLab2_storage_admins_rule_Final}"
}

variable "regenerate_passwords" {
  description = "Change this value to force regeneration of all user passwords"
  type        = string
  default     = "1"
}

locals {
  lab_users = {
    eliLabUser01 = { display_name = "eli Lab User 01" }
    eliLabUser02 = { display_name = "eli Lab User 02" }
    eliLabUser03 = { display_name = "eli Lab User 03" }
    eliLabUser04 = { display_name = "eli Lab User 04" }
    eliLabUser05 = { display_name = "eli Lab User 05" }
    eliLabUser06 = { display_name = "eli Lab User 06" }
    eliLabUser07 = { display_name = "eli Lab User 07" }
  }

  microsoft_graph_app_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
}

provider "azuread" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_group" "lab_users_bypass_mfa" {
  display_name = "lab_users"
}

data "azuread_service_principal" "microsoft_graph" {
  client_id = local.microsoft_graph_app_id
}

resource "azurerm_resource_group" "eli_lab1" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "eli_lab1" {
  name                            = "hackeriotstorageacct"
  resource_group_name             = azurerm_resource_group.eli_lab1.name
  location                        = azurerm_resource_group.eli_lab1.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "eli_lab1" {
  name                  = "labs"
  storage_account_id    = azurerm_storage_account.eli_lab1.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "lab1_flag" {
  name                   = "Lab1_Flag.txt"
  storage_account_name   = azurerm_storage_account.eli_lab1.name
  storage_container_name = azurerm_storage_container.eli_lab1.name
  type                   = "Block"
  source_content         = var.flag_text
  content_type           = "text/plain"
}

resource "random_password" "lab_users" {
  for_each = local.lab_users

  length      = 20
  special     = true
  min_lower   = 4
  min_upper   = 4
  min_numeric = 4
  min_special = 2

  keepers = {
    regenerate = var.regenerate_passwords
    user_key   = each.key
  }
}

resource "azuread_user" "lab_users" {
  for_each = local.lab_users

  user_principal_name   = "${each.key}@${var.tenant_domain}"
  display_name          = each.value.display_name
  mail_nickname         = replace(lower(each.key), "_", "-")
  password              = random_password.lab_users[each.key].result
  force_password_change = true

  lifecycle {
    ignore_changes = []
  }
}

resource "azuread_group_member" "bypass_mfa" {
  for_each = azuread_user.lab_users

  group_object_id  = data.azuread_group.lab_users_bypass_mfa.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group" "eli_lab1" {
  display_name     = "eliLab1Group"
  description      = "Lab group with storage administrator capabilities"
  security_enabled = true
  mail_enabled     = false
}

# Note: Users are NOT automatically added to this group
# Students must use the eliLab1 Service Principal to add themselves via Microsoft Graph API

resource "local_file" "creds_lab" {
  depends_on = [azuread_user.lab_users, random_password.lab_users]

  filename = "${path.module}/creds_lab.txt"
  
  content = <<-EOT
Lab User Credentials
====================
Regenerate Token: ${var.regenerate_passwords}
(Change this value to regenerate all passwords)

${join("\n\n", [
  for user_key, user in azuread_user.lab_users :
  "Username: ${user.user_principal_name}\nPassword: ${random_password.lab_users[user_key].result}"
])}
EOT

  lifecycle {
    create_before_destroy = true
    # Force update when passwords are regenerated
    replace_triggered_by = [
      random_password.lab_users
    ]
  }
}

resource "azurerm_role_assignment" "eli_lab1_storage_admin" {
  scope                = azurerm_storage_account.eli_lab1.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_group.eli_lab1.object_id
}

resource "azurerm_role_assignment" "eli_lab1_blob_reader" {
  scope                = azurerm_storage_account.eli_lab1.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.eli_lab1.object_id
  depends_on           = [azurerm_storage_blob.lab1_flag]
}

resource "azuread_application" "eli_lab1" {
  display_name = "eliLab1"

  required_resource_access {
    resource_app_id = local.microsoft_graph_app_id

    resource_access {
      id   = data.azuread_service_principal.microsoft_graph.app_role_ids["GroupMember.ReadWrite.All"]
      type = "Role"
    }

    resource_access {
      id   = data.azuread_service_principal.microsoft_graph.app_role_ids["Directory.Read.All"]
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "eli_lab1" {
  client_id = azuread_application.eli_lab1.client_id
}

resource "azuread_application_password" "eli_lab1" {
  application_id = azuread_application.eli_lab1.id
  display_name   = "eliLab1-automation"
}

resource "azuread_application_owner" "eli_lab1" {
  for_each = azuread_user.lab_users

  application_id  = azuread_application.eli_lab1.id
  owner_object_id = each.value.object_id
}

resource "azuread_app_role_assignment" "group_member_rw" {
  app_role_id         = data.azuread_service_principal.microsoft_graph.app_role_ids["GroupMember.ReadWrite.All"]
  principal_object_id = azuread_service_principal.eli_lab1.object_id
  resource_object_id  = data.azuread_service_principal.microsoft_graph.object_id
}

resource "azuread_app_role_assignment" "directory_read" {
  app_role_id         = data.azuread_service_principal.microsoft_graph.app_role_ids["Directory.Read.All"]
  principal_object_id = azuread_service_principal.eli_lab1.object_id
  resource_object_id  = data.azuread_service_principal.microsoft_graph.object_id
}

output "eli_lab1_user_credentials" {
  description = "UPNs and temporary passwords for the seven lab users"
  value = {
    for user_key, user in azuread_user.lab_users :
    user_key => {
      upn      = user.user_principal_name
      password = random_password.lab_users[user_key].result
    }
  }
  sensitive = true
}

# Console output - prints all passwords clearly
output "all_passwords_console" {
  description = "All user passwords printed to console (non-sensitive for lab purposes)"
  value = <<-EOT

╔═══════════════════════════════════════════════════════════════╗
║                    LAB USER CREDENTIALS                       ║
║         Regenerate Token: ${var.regenerate_passwords}                      ║
╚═══════════════════════════════════════════════════════════════╝

${join("\n\n", [
  for user_key, user in azuread_user.lab_users :
  "Username: ${user.user_principal_name}\nPassword: ${nonsensitive(random_password.lab_users[user_key].result)}"
])}

╔═══════════════════════════════════════════════════════════════╗
║  To regenerate passwords, run:                                ║
║  terraform apply -var="regenerate_passwords=X"               ║
║  (where X is a different number)                              ║
╚═══════════════════════════════════════════════════════════════╝
EOT
  sensitive = false
}


output "eli_lab1_app_registration" {
  description = "Useful identifiers for the eliLab1 application"
  value = {
    client_id     = azuread_application.eli_lab1.client_id
    object_id     = azuread_application.eli_lab1.object_id
    sp_object_id  = azuread_service_principal.eli_lab1.object_id
    client_secret = azuread_application_password.eli_lab1.value
  }
  sensitive = true
}

output "storage_blob_details" {
  description = "Location of the Lab1 flag blob"
  value = {
    resource_group = azurerm_resource_group.eli_lab1.name
    account_name   = azurerm_storage_account.eli_lab1.name
    container      = azurerm_storage_container.eli_lab1.name
    #blob_name      = azurerm_storage_blob.lab1_flag.name
  }
}
