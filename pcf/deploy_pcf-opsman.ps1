﻿param(
$opsmanager_uri  = "https://opsmanagerwesteurope.blob.core.windows.net/images/ops-manager-2.1-build.212.vhd",
$resourceGroup = 'OpsMANAGER',
$location = $GLOBAL:AZS_Location,
$storageaccount = 'opsmanstorageaccount',
$image_containername = 'opsman-image'
)

$vhdName = 'image.vhd'
$storageType = 'Standard_LRS'
$file = split-path -Leaf $opsmanager_uri
$localPath = "$HOME\Downloads\$file"

if (!(Test-Path $localPath))
    {
    Start-BitsTransfer -Source $opsmanager_uri -Destination $localPath -DisplayName OpsManager     
    }
if (!RegisterProividers)
    {
        foreach ($provider in ('Microsoft.Compute','Microsoft.Network','Microsoft.KeyVault','Microsoft.Storage'))
        {
            Get-AzureRmResourceProvider -ProviderNamespace $provider | Register-AzureRmResourceProvider
        } 
    }


New-AzureRmResourceGroup -Name $resourceGroup -Location $location
New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name `
    $storageAccount -Location $location `
    -Type $storageType 
$urlOfUploadedImageVhd = ('https://' + $storageaccount + '.blob.' + $Global:AZS_location + '.' + $Global:dnsdomain+ '/' + $image_containername + '/' + $vhdName)
Add-AzureRmVhd -ResourceGroupName $resourceGroup -Destination $urlOfUploadedImageVhd `
    -LocalFilePath $localPath

$parameters = @{}
# $parameters.Add("SSHKeyData",$Global:VMPassword)
New-AzureRmResourceGroupDeployment -Name OpsManager -ResourceGroupName $resourceGroup -Mode Incremental -TemplateFile .\pcf\azuredeploy.json -TemplateParameterObject $parameters







    
<#
create a key
ssh-keygen -t rsa -f opsman -C ubuntu
 ssh -i opsman ubuntu@pcf-opsman.local.cloudapp.azurestack.external



<# register provider network storage keyvault, compute "!!!!!! 

login ui



https://docs.pivotal.io/pivotalcf/2-1/customizing/ops-man-api.html
uaac target https://pcf-opsman.local.cloudapp.azurestack.external/uaa --skip-ssl-validation
uaac token owner get

$ uaac token owner get
Client ID: opsman
Client secret: [Leave Blank]
User name: OPS-MAN-USERNAME
Password: OPS-MAN-PASSWORD


token="$(uaac context | awk '/^ *access_token\: *([a-zA-Z0-9.\/+\-_]+) *$/ {print $2}' -)"
curl -H "Authorization: bearer $token" "$@"

curl "https://pcf-opsman.local.cloudapp.azurestack.external/api/v0/vm_types" \
    -X GET \
    -H "Authorization: bearer $token" \
    --insecure




curl -k https://pcf-opsman.local.cloudapp.azurestack.external/api/v0/vm_types -X \
PUT -H "Authorization: bearer $token" -H \
"Content-Type: application/json" -d '{"vm_types":[
{"name":"Standard_DS1_v2","ram":3584,"cpu":1,"ephemeral_disk":51200},
{"name":"Standard_DS2_v2","ram":7168,"cpu":2,"ephemeral_disk":102400},
{"name":"Standard_DS3_v2","ram":14336,"cpu":4,"ephemeral_disk":204800},
{"name":"Standard_DS4_v2","ram":28672,"cpu":8,"ephemeral_disk":409600},
{"name":"Standard_DS5_v2","ram":57344,"cpu":8,"ephemeral_disk":819200},
{"name":"Standard_DS11_v2","ram":14336,"cpu":2,"ephemeral_disk":102400},
{"name":"Standard_DS12_v2","ram":28672,"cpu":4,"ephemeral_disk":204800},
{"name":"Standard_DS13_v2","ram":57344,"cpu":8,"ephemeral_disk":409600},
{"name":"Standard_DS14_v2","ram":114688,"cpu":16,"ephemeral_disk":819200}]}' --insecure



###

$URI = "https://vmimage.blob.local.azurestack.external/vmimage/aliases.json"

az cloud register `
  -n AzureStackUser `
  --endpoint-resource-manager "https://management.local.azurestack.external" `
  --suffix-storage-endpoint "local.azurestack.external" `
  --suffix-keyvault-dns ".vault.local.azurestack.external" `
  --endpoint-active-directory-graph-resource-id "https://graph.windows.net/" `
  --endpoint-vm-image-alias-doc $uri

  #>