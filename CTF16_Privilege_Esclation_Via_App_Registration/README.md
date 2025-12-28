
# Azure 101 CTF Lab: DemoFlow

Welcome to the **Azure 101 CTF Lab**! This repository provides a hands-on Capture The Flag (CTF) scenario for learning Azure Active Directory, Service Principals, RBAC, and secure storage access using Terraform and PowerShell.

---

## 🚩 Scenario Overview

You are given a simulated Azure environment with:
- **7 lab users** (Azure AD)
- **A storage account** with a secret flag
- **A Service Principal** with Microsoft Graph permissions
- **Custom RBAC assignments**

Your mission: **Leverage your access and automation skills to retrieve the flag from blob storage!**

---

## 🏗️ Architecture

- **Terraform** provisions all Azure resources
- **PowerShell scripts** automate authentication and access
- **Microsoft Graph API** enables advanced directory operations

```
Azure AD
│
├── Lab Users (eliLabUser01-07)
├── Group: eliLab1Group
│   └── Storage Admin Roles
├── Service Principal: eliLab1
│   └── Microsoft Graph Permissions
└── Resource Group: rg-eli-lab1
  └── Storage Account: hackeriotstorageacct
    └── Container: labs
      └── Blob: Lab1_Flag.txt
```

---

## 📁 Project Structure


```
./
├── main.tf                        # Terraform configuration
├── Run.ps1                        # Main PowerShell workflow
├── docs/
│   └── architecture-diagram-placeholder.md
└── README.md                      # This file
```

---

## 🚀 Quick Start

### 1. Prerequisites
- Azure subscription
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0
- [Azure PowerShell](https://docs.microsoft.com/powershell/azure/new-azureps-module-az) (`Az`)
- [Microsoft Graph PowerShell](https://learn.microsoft.com/powershell/microsoftgraph/)

### 2. Clone & Configure
```bash
git clone <this-repo-url>
cd DemoFlow
```
Edit `main.tf` to set your Azure subscription and tenant domain if needed.

### 3. Deploy Lab Environment
```bash
terraform init
terraform apply
```

### 4. Retrieve Lab Credentials
- After deployment, check the Terraform output or `creds_lab.txt` for user credentials.

### 5. Start the Challenge
- Use the provided PowerShell scripts to authenticate and explore.
- Your goal: **Access the `Lab1_Flag.txt` blob in storage!**

---

## 🧩 Challenge Hints
- Users are **not** automatically added to the storage admin group. Use the Service Principal and Microsoft Graph to add yourself.
- The Service Principal has permissions to manage group membership.
- Use the credentials and scripts to automate your attack path.

---

## 🔐 Security & Best Practices
- **No real secrets** are committed; all credentials are generated for the lab.
- **Rotate passwords** by changing the `regenerate_passwords` variable and reapplying Terraform.
- **Review RBAC**: Only the group gets storage admin rights.



## 📣 Contact & Support
- Open an issue for questions or improvements.

---

**⚠️ This lab is for educational/demo use only. Do not use in production.**

## ⚙️ Configuration

### Terraform Variables

Edit `main.tf` to configure your environment:

```hcl
variable "subscription_id" {
  default = "your-subscription-id"
}

variable "tenant_domain" {
  default = "your-tenant.onmicrosoft.com"
}

variable "resource_group_name" {
  default = "rg-eli-lab1"
}
```

## 🔧 Usage

### Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

### Run PowerShell Scripts

```powershell

## 🔐 Security Notes

- **Never commit credentials** - Use environment variables or Azure Key Vault
- **Rotate secrets regularly** - Change the `regenerate_passwords` variable in Terraform to update user passwords
- **Review RBAC assignments** - Ensure least privilege access
- **Monitor access logs** - Track who accesses resources

## 📚 Key Features

### 1. Azure AD User Management
- Creates lab users with secure passwords
- Assigns users to groups

### 2. Service Principal Configuration
- Creates application registration
- Configures Microsoft Graph API permissions
- Sets up service principal authentication

### 3. Storage Account Setup
- Creates storage account and containers
- Uploads flag/blob files
- Configures access policies

### 4. Role Assignments
- Storage Account Contributor role
- Storage Blob Data Reader role
- Directory role assignments via Microsoft Graph


## 🧪 Testing

```powershell
# Verify role assignments
Get-AzRoleAssignment -ObjectId <service-principal-object-id>
```


## 📖 Scripts Documentation

### Run.ps1
Main workflow script demonstrating:
- User authentication
- Object ownership enumeration
- Secret creation via Microsoft Graph API
- Application access patterns

## 🔍 Troubleshooting

### Common Issues


**Authentication Errors**
```powershell
# Clear existing sessions
Disconnect-AzAccount
Disconnect-MgGraph
```

**Terraform State Lock**
```bash
# If state is locked, check for running terraform processes
# Or use: terraform force-unlock <lock-id>
```

**Permission Errors**
- Verify Service Principal has required permissions
- Check Azure AD app registration API permissions
- Ensure proper role assignments

## 📝 License

This project is for educational and lab purposes only.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Contact

For questions or issues, please open a GitHub issue.

---

**⚠️ Warning**: This repository contains lab/demo code. Do not use in production environments without proper security review.

