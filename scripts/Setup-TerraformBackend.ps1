if(-not(Get-Module -ListAvailable -Name Az)){
    Install-Module Az -Force -Scope CurrentUser
}

#[PSCredential]$Creds = [pscredential]::new($env:ARM_CLIENT_ID,$(ConvertTo-SecureString -String $env:ARM_CLIENT_SECRET -AsPlainText -Force))

Import-Module Az
#Connect-AzAccount -Tenant $env:ARM_TENANT_ID -ServicePrincipal -Credential $Creds

$resourceGroupName = "hashicorp-meetup-backend-rg"
$location = "WestUS2"
$storageAccountName = "redapthashicorpmeetup"
$storageContainerName = "terraform-storage"
$tags = @{
    HashicorpMeetup = "3/6/2019"
}

try {
    Get-AzResourceGroup -Name $resourceGroupName -Location $location -ErrorAction Stop
    Write-Host "Resource Group: $resourceGroupName in Location: $location exists!"
}
catch {
    Write-Host "Creating New Resource Group $resourceGroupName"
    New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag $tags
}

try {
    Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction Stop
    Write-Host "Storage Account Name: $storageAccountName exists in Resource Group: $resourceGroupName"
    $keys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $storageAccountName
    $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $keys[0].Value
    $env:ARM_ACCESS_KEY=$keys[0]
}
catch {
    Write-Host "Creating Storage Account $storageAccountName in Resource Group $resourceGroupName"
    $storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS
}

try {
    Get-AzStorageContainer -Name $storageContainerName -Context $ctx -ErrorAction Stop
    Write-Host "Storage Container $storageContainerName exists"
}
catch {
    Write-Host "Creating storage container $storageContainerName"
    if (-not ($ctx)) {
        $ctx = New-AzStorageContext -ConnectionString $storageAccount.Context.ConnectionString
    }
    New-AzStorageContainer -Name $storageContainerName -Context $ctx -Permission Container
    $connstr_array = $ctx.ConnectionString.Split(';')
    $accountKey = $connstr_array[$connstr_array.Length - 1].Split('=')
    Write-Output "access_key=`"$($accountKey[1])==`"" | Out-File -FilePath ../terraform.tfvars
}

Write-Output "storage_account_name=$storageAccountName" | Out-File -FilePath ../terraform.tfvars -Append
Write-Output "container_name=`"$($storageContainerName)`"" | Out-File -FilePath ../terraform.tfvars -Append
Write-Output "key=`"hashicorp-platform.tfstate`"" | Out-File -FilePath ../terraform.tfvars -Append