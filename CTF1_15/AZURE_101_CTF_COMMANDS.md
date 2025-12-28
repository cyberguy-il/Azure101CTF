# Azure 101 Commands

A comprehensive reference guide for Azure CLI commands used in Azure CTF challenges and lab environments.

---

## Table of Contents

- [Application Information](#application-information)
- [Tenant Information](#tenant-information)
- [Subscriptions](#subscriptions)
- [Resource Groups](#resource-groups)
- [Azure AD / Entra ID](#azure-ad--entra-id)
- [Role-Based Access Control](#role-based-access-control-rbac)
- [Managed Identities](#managed-identities)
- [Virtual Machines](#virtual-machines)
- [Storage Accounts](#storage-accounts)
- [Key Vault](#key-vault)
- [Resource Deployment](#resource-deployment)
- [Additional Commands](#additional-useful-commands)
- [Tips & Tricks](#tips--tricks)

---

## Application Information

Common Azure application IDs used for authentication and API access:

```bash
# Microsoft Azure Management
797f4846-ba00-4fd7-ba43-dac1f8f63013

# Microsoft Graph
00000003-0000-0000-c000-000000000000

# Azure Storage
e406a681-f3d4-42a8-90b6-c2b029497af1
```

---

## Tenant Information

### Get Tenant Information

Retrieve tenant configuration from OpenID Connect discovery endpoint:

```bash
curl https://login.microsoftonline.com/azurectfchallengegame.com/.well-known/openid-configuration
```

### Get Tenant ID (One-liner)

Extract tenant ID from OpenID configuration:

```bash
curl -s https://login.microsoftonline.com/azurectfchallengegame.com/.well-known/openid-configuration | grep -Eo '[0-9a-fA-F-]{36}' | head -n 1
```

---

## Subscriptions

### List Current Subscription

```bash
az account show --query id -o tsv
```

### List All Subscriptions

```bash
az account list --query "[].{Name:name, SubscriptionId:id, TenantId:tenantId}" -o table
```

---

## Resource Groups

### List Resource Groups

```bash
# List all resource group names
az group list --query "[].name" -o json

# List with details
az group list --query "[].{Name:name, Location:location}" -o table
```

---

## Azure AD / Entra ID

### List AD Groups

```bash
# List all groups
az ad group list

# List group display names only
az ad group list --query "[].displayName" -o json

# List groups with descriptions
az ad group list --query "[].{displayName: displayName, description: description}" -o json
```

### List All Entra ID Users

```bash
# List all users
az ad user list

# List users with specific fields
az ad user list --query "[].{name:displayName,upn:userPrincipalName,job:jobTitle}" -o table

# List users with object IDs
az ad user list --query "[].{name:displayName,objectId:id,upn:userPrincipalName}" -o table
```

### List App Registrations

```bash
# List all app registrations
az ad app list

# List with display name, app ID, and redirect URIs
az ad app list --query "[].{displayName: displayName, appId: appId, redirectUris: web.redirectUris}" -o json

# List app registrations with object IDs
az ad app list --query "[].{displayName: displayName, appId: appId, objectId: id}" -o table
```

### List Service Principals

```bash
# List all service principals
az ad sp list --query "[].{displayName: displayName, appId: appId, objectId: id}" -o table
```

---

## Role-Based Access Control (RBAC)

### List Custom Roles

```bash
# List custom roles only
az role definition list --custom-role-only true

# List custom roles in table format
az role definition list --custom-role-only true -o table

# List all role definitions
az role definition list --query "[].{Name:name, Type:type}" -o table
```

### List Role Assignments

```bash
# List role assignments for current subscription
az role assignment list --query "[].{Principal:principalName, Role:roleDefinitionName, Scope:scope}" -o table

# List role assignments for a specific principal
az role assignment list --assignee <principal-id> --query "[].{Role:roleDefinitionName, Scope:scope}" -o table
```

---

## Managed Identities

### List Managed Identities

```bash
# List all managed identities
az identity list --query "[].{name:name,rg:resourceGroup}" -o table

# List with location and principal ID
az identity list --query "[].{name:name, resourceGroup:resourceGroup, location:location, principalId:principalId}" -o table
```

---

## Virtual Machines

### List VMs

```bash
# List all VMs with basic info
az vm list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, OS:storageProfile.osDisk.osType}" -o table

# List VMs with power state
az vm list --query "[].{Name:name, ResourceGroup:resourceGroup, PowerState:powerState}" -o table
```

### List VMs with Attached Managed Identity

```bash
# List VMs with managed identity information
az vm list --query "[].{VM:name,ResourceGroup:resourceGroup,IdentityType:identity.type,UserAssignedIdentities:identity.userAssignedIdentities}" -o json

# List VMs with system-assigned identity
az vm list --query "[?identity.type=='SystemAssigned'].{Name:name, ResourceGroup:resourceGroup, PrincipalId:identity.principalId}" -o table
```

### Run Commands in VM

**Linux VMs:**

```bash
# Run basic commands
az vm run-command invoke \
  --resource-group CTF-AZURE101-RG-MAIN \
  --name ctf-azure101-vm-1 \
  --command-id RunShellScript \
  --scripts "id && hostname && ls /tmp"

# Get instance metadata
az vm run-command invoke \
  --resource-group CTF-AZURE101-RG-MAIN \
  --name ctf-azure101-vm-1 \
  --command-id RunShellScript \
  --scripts "curl -H 'Metadata:true' 'http://169.254.169.254/metadata/instance?api-version=2021-02-01'"

# Get managed identity token
az vm run-command invoke \
  --resource-group CTF-AZURE101-RG-MAIN \
  --name ctf-azure101-vm-1 \
  --command-id RunShellScript \
  --scripts "curl -s -H 'Metadata:true' 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-02-01&resource=https://management.azure.com/'"
```

**Windows VMs:**

```bash
# Run PowerShell commands
az vm run-command invoke \
  --resource-group <resource-group> \
  --name <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-Process | Select-Object Name, Id"
```

---

## Storage Accounts

### List Storage Accounts

```bash
# List all storage account names
az storage account list --query "[].name" -o table

# List with resource group and location
az storage account list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" -o table
```

### List Storage Containers

```bash
# List containers in a storage account
az storage container list \
  --account-name ctfazure101wif7w0k4 \
  --auth-mode login \
  --query "[].name" -o table

# List containers with metadata
az storage container list \
  --account-name <storage-account-name> \
  --auth-mode login \
  --query "[].{Name:name, PublicAccess:properties.publicAccess}" -o table
```

### List Blobs

```bash
# List blobs in a container
az storage blob list \
  --account-name ctfazure101wif7w0k4 \
  --container-name ctf-flags \
  --auth-mode login \
  --query "[].name" -o table

# List blobs with size and last modified
az storage blob list \
  --account-name <storage-account-name> \
  --container-name <container-name> \
  --auth-mode login \
  --query "[].{Name:name, Size:properties.contentLength, LastModified:properties.lastModified}" -o table
```

### Download Blobs

```bash
# Download a blob
az storage blob download \
  --account-name ctfazure101wif7w0k4 \
  --container-name ctf-flags \
  --name flag.txt \
  --file flag.txt \
  --auth-mode login

# Download all blobs from a container
az storage blob download-batch \
  --account-name <storage-account-name> \
  --source <container-name> \
  --destination ./downloads \
  --auth-mode login
```

### Upload Blobs

```bash
# Upload a blob
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name <container-name> \
  --name <blob-name> \
  --file <local-file> \
  --auth-mode login
```

---

## Key Vault

### List Key Vaults

```bash
# List all key vaults
az keyvault list --query "[].name" -o table

# List with resource group
az keyvault list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location}" -o table
```

### List Secrets

```bash
# List all secrets in a key vault
az keyvault secret list \
  --vault-name ctf-azure101-kv-wif7w0k4 \
  --query "[].name" -o table

# List secrets with enabled status
az keyvault secret list \
  --vault-name <vault-name> \
  --query "[].{Name:name, Enabled:attributes.enabled}" -o table
```

### Get Secret Value

```bash
# Get secret value
az keyvault secret show \
  --vault-name ctf-azure101-kv-wif7w0k4 \
  --name ctf-flag \
  --query value -o tsv

# Get secret with metadata
az keyvault secret show \
  --vault-name <vault-name> \
  --name <secret-name> \
  --query "{Value:value, Enabled:attributes.enabled, Expires:attributes.expires}" -o json
```

### List Keys and Certificates

```bash
# List keys
az keyvault key list --vault-name <vault-name> --query "[].name" -o table

# List certificates
az keyvault certificate list --vault-name <vault-name> --query "[].name" -o table
```

---

## Resource Deployment

### Deploy ARM Template

```bash
# Deploy from local template file
az deployment group create \
  --resource-group <resource-group> \
  --template-file template.json \
  --parameters @parameters.json

# Deploy from URL
az deployment group create \
  --resource-group <resource-group> \
  --template-uri <template-url> \
  --parameters <param1>=<value1> <param2>=<value2>
```

### List Deployments

```bash
# List deployments in a resource group
az deployment group list \
  --resource-group <resource-group> \
  --query "[].{Name:name, State:properties.provisioningState, Timestamp:properties.timestamp}" -o table
```

### Show Deployment Details

```bash
# Show deployment details
az deployment group show \
  --resource-group <resource-group> \
  --name <deployment-name> \
  --query "properties.outputs" -o json
```

### Deploy Bicep Template

```bash
# Deploy Bicep template
az deployment group create \
  --resource-group <resource-group> \
  --template-file template.bicep \
  --parameters @parameters.json
```

---

## Additional Useful Commands

### Get Current Context

```bash
# Show current account and subscription
az account show

# Show current user
az account show --query user

# Show current subscription
az account show --query "{SubscriptionId:id, Name:name, TenantId:tenantId}" -o json
```

### Switch Subscription

```bash
# List subscriptions
az account list --query "[].{Name:name, SubscriptionId:id}" -o table

# Set active subscription
az account set --subscription <subscription-id>
```

### Get Resource Information

```bash
# Show resource details
az resource show \
  --resource-group <resource-group> \
  --name <resource-name> \
  --resource-type <resource-type>

# List resources in a resource group
az resource list \
  --resource-group <resource-group> \
  --query "[].{Name:name, Type:type, Location:location}" -o table
```

---

## Tips & Tricks

### Formatting Output

Azure CLI supports multiple output formats:

| Format | Flag | Use Case |
|--------|------|----------|
| Table | `-o table` | Human-readable output |
| JSON | `-o json` | Parsing and automation |
| TSV | `-o tsv` | Tab-separated values |
| YAML | `-o yaml` | YAML format |

### Query Examples

```bash
# Filter resources by location
az resource list --query "[?location=='eastus']"

# Select specific fields
az resource list --query "[].{Name:name, Type:type}"

# Combine filter and select
az vm list --query "[?powerState=='VM running'].{Name:name, ResourceGroup:resourceGroup}"
```

### Authentication Methods

```bash
# Interactive login
az login

# Service principal authentication
az login --service-principal -u <app-id> -p <password> --tenant <tenant-id>

# Managed identity authentication (from VM)
az login --identity
```

---

## Notes

- Replace placeholder values like `<resource-group>`, `<vm-name>`, `<storage-account-name>`, etc. with your actual resource names
- Never commit credentials or secrets to version control
- Use environment variables or Azure Key Vault for sensitive information
- Always verify permissions before executing commands that modify resources

---

**Last Updated**: 2026
