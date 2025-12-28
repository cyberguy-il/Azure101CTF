# 🏴 Azure 101 CTF Platform

<div align="center">

![Azure](https://img.shields.io/badge/Microsoft_Azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)

**A hands-on Capture The Flag platform for learning Azure Security and Penetration Testing**

[Getting Started](#-getting-started) • [Challenges](#-challenges) • [Prerequisites](#-prerequisites) • [Platform Features](#-platform-features)

</div>

---
<img width="1918" height="1054" alt="2025-12-28_16-40-46" src="https://github.com/user-attachments/assets/c9e8e2b3-3ec7-4cc8-8f82-1e238b6ad1ad" />

## 📖 About

Azure 101 CTF is an interactive learning platform designed to teach Azure cloud security concepts through practical, hands-on challenges. Students learn to enumerate Azure resources, discover misconfigurations, and understand privilege escalation paths in Azure Active Directory and Azure Resource Manager.

This platform provides a safe, controlled environment to practice offensive security techniques against Azure infrastructure, helping security professionals and students understand:

- 🔍 Azure reconnaissance and enumeration
- 🔐 Identity and Access Management (IAM) vulnerabilities
- 📊 Misconfiguration detection
- ⬆️ Privilege escalation techniques
- 🔑 Secret and credential discovery

---

## 🎯 Challenges

The platform includes **17 progressive challenges** covering essential Azure security topics:

### 🟢 Beginner Level (Easy)

| # | Challenge | Topic Covered |
|---|-----------|---------------|
| 1 | **Tenant Name Discovery** | Azure AD tenant enumeration and reconnaissance basics |
| 2 | **Tenant ID Enumeration** | Understanding Azure AD tenant identifiers and their significance |
| 3 | **User Principal Discovery** | Enumerating user properties and attributes in Azure AD |
| 4 | **Service Principal Secrets** | Understanding application identities and their configurations |
| 6 | **Azure AD Group Enumeration** | Group discovery and understanding access control structures |
| 8 | **Security Group Discovery** | Microsoft 365 Groups and their security implications |

### 🟡 Intermediate Level (Medium)

| # | Challenge | Topic Covered |
|---|-----------|---------------|
| 5 | **Managed Identity Token Theft** | Instance Metadata Service (IMDS) and managed identity exploitation |
| 7 | **App Registration Analysis** | Application credentials and secret management vulnerabilities |
| 9 | **Custom Role Inspection** | Azure RBAC custom role definitions and permission analysis |
| 10 | **ARM Deployment Secrets** | Extracting sensitive data from ARM deployment outputs |
| 11 | **Blob Storage Discovery** | Azure Storage enumeration and blob container access |
| 12 | **Azure Function Parameter Extraction** | Function App configuration and application settings exposure |
| 13 | **Key Vault Secret Retrieval** | Azure Key Vault access and secret management |
| 14 | **Application Administrator Role** | Azure AD directory roles and administrative permissions |

### 🔴 Advanced Level (Hard)

| # | Challenge | Topic Covered |
|---|-----------|---------------|
| 15 | **App Registration Permission Analysis** | API permissions (Delegated vs Application) and OAuth2 scopes |
| 16 | **Privilege Escalation via App Registration** | Complete attack chain: App Registration → Group → Storage Access |
| 17 | **Storage Contributor Privilege Escalation** | Exploiting Storage Account Contributor role without direct blob access |

---

## 🧠 Learning Objectives

By completing these challenges, you will learn:

### Azure AD / Entra ID
- Tenant and user enumeration techniques
- Service Principal and App Registration analysis
- Group membership enumeration
- Directory role discovery
- OAuth2 permission models (Delegated vs Application)

### Azure Resource Manager (ARM)
- Resource enumeration across subscriptions
- RBAC role and permission analysis
- ARM deployment output extraction
- Custom role definition inspection

### Azure Storage
- Storage account enumeration
- Blob container access methods
- SAS token generation
- Storage account key extraction

### Azure Compute
- Instance Metadata Service (IMDS) exploitation
- Managed Identity token extraction
- Function App configuration analysis

### Identity & Privilege Escalation
- App Registration abuse techniques
- Group membership manipulation
- Credential extraction and reuse
- Multi-step attack chains

---

## 🛠️ Prerequisites

Before starting the challenges, ensure you have:

### Required Tools
```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure PowerShell Module
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Microsoft Graph PowerShell Module
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Recommended Knowledge
- Basic understanding of cloud computing concepts
- Familiarity with command-line interfaces
- Understanding of authentication and authorization concepts
- Basic knowledge of REST APIs

### Platform Access
- Valid Azure 101 CTF platform credentials
- Azure subscription access (provided per challenge)
- Internet connectivity

---

## 🖥️ Platform Features

### For Students
- **Progress Tracking**: Track completed challenges and overall progress
- **Flag Submission**: Verify your answers with instant feedback
- **Hints System**: Get guidance when stuck
- **Command Reference**: Azure CLI and PowerShell examples for each challenge
- **Solution Steps**: Step-by-step guidance after completion

### Security Features
- **Two-Factor Authentication**: TOTP-based 2FA support
- **Password Complexity**: Enforced strong password requirements
- **Session Management**: Secure session handling
- **Rate Limiting**: Protection against brute-force attacks

---

## 📚 Challenge Walkthroughs

Detailed command references and walkthroughs are available on GitHub:

- **[Challenges 1-15 Commands](https://github.com/cyberguy-il/Azure101CTF/tree/main/CTF1_15_Commands)** - Basic to intermediate challenge solutions
- **[CTF 16 Walkthrough](https://github.com/cyberguy-il/Azure101CTF/tree/main/CTF16_Privilege_Esclation_Via_App_Registration)** - Privilege escalation via App Registration

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure 101 CTF Platform                    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Flask     │  │   SQLite    │  │   Entra ID          │  │
│  │   Web App   │  │   Database  │  │   Integration       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    Azure Environment                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Azure AD   │  │  Storage    │  │   App               │  │
│  │  Users/Apps │  │  Accounts   │  │   Registrations     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎓 Who Is This For?

- **Security Professionals** looking to expand their cloud security skills
- **Penetration Testers** wanting to learn Azure-specific techniques
- **Cloud Architects** seeking to understand security misconfigurations
- **Students** learning about cloud security for certifications
- **Red Team Members** practicing Azure attack techniques
- **Blue Team Members** understanding attacker methodologies

---

## ⚠️ Disclaimer

This platform is designed for **educational purposes only**. The techniques taught here should only be used:

- In authorized penetration testing engagements
- In your own lab environments
- With explicit written permission

**Never use these techniques against systems you do not own or have permission to test.**

---

## 📄 License

This project is for educational purposes. Please use responsibly and ethically.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

---

## 📬 Contact

For questions or support, please reach out through the platform's contact system.

---

<div align="center">

**Happy Hacking! 🎯**

*Remember: With great power comes great responsibility*

</div>
