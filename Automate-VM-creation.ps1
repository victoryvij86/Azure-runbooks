Login-AzureRmAccount
Get-AzureRmSubscription -SubscriptionName "Free Trial" | select-azureRmSubscription

$location = “West US”

$rgroup = “myrg”
$vmname = “SGAZIWSQLP010”
$vmSize = "Standard_D2"
$computerName = "SGAZIWSQLP010"
$osDiskName = $vmname + "-OSDisk"
$vnetname="VN-SGAZ-Int"
$storage="myrgstorevij"
#$avName = "AS-SGAZ-Prod-SharedPlat-ThirdParty-SQL-02"
$VnetRG = "myrg"
$subnetname = "IT-SN"
$cred = Get-Credential -Message "Type the name and password for the local administrator account."


$vnet=Get-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $VnetRG

$subnet1 = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetname

#$avSet = New-AzureRmAvailabilitySet -ResourceGroupName $rgroup  -Name $avName -Location $location  
#$avSet=Get-AzureRmAvailabilitySet –Name $avName –ResourceGroupName $rgroup
$vmconfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmSize #-AvailabilitySetId $avSet.Id
$vm = Set-AzureRmVMOperatingSystem -VM $vmconfig  -ComputerName $vmname -Credential $cred -Windows

#$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest

$pubName = Get-AzurermVMImagePublisher -Location $location | Out-GridView -Title "Select Publisher" -PassThru

#Pick a specific offer
$offerName = Get-AzurermVMImageOffer -Location $location -Publisher $pubName.PublisherName | Out-GridView -Title "Select Offer" -PassThru

#View the different SKUs
$skuname = Get-AzurermVMImageSku -Location $location -Publisher $pubName.PublisherName -Offer $offerName.Offer | Out-GridView -Title "Select Sku" -PassThru

#View the versions of a SKU
$image = Get-AzurermVMImage -Location $location -PublisherName $pubName.PublisherName -Offer $offerName.Offer -Skus $skuname.Skus | Out-GridView -Title "Select Version" -PassThru

$nic1 = New-AzureRmNetworkInterface -Name SGAZIWSQLP010-NIC1 -ResourceGroupName $rgroup -Location $location -SubnetId $subnet1.Id #$vnet.Subnets[2].Id -PublicIpAddressId $pip.Id
$nic2 = New-AzureRmNetworkInterface -Name SGAZIWSQLP010-NIC2 -ResourceGroupName $rgroup -Location $location -SubnetId $subnet1.Id #$vnet.Subnets[2].Id

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic1.Id
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic2.Id
$vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true



#View detail of a specific version of the SKU

$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $image.PublisherName -Offer $image.Offer -Skus $image.Skus -Version $image.version 

$storageAcc = Get-AzureRMStorageAccount -Name $storage -ResourceGroupName $rgroup
$osDiskUri = '{0}vhds/{1}-{2}.vhd' -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage 

New-AzureRmVM -ResourceGroupName $rgroup -Location $location -VM $vm

#SQL Extention Installation
Set-AzureRmVMSqlServerExtension -ResourceGroupName $rgroup -VMName $vmname -Name "SQLIaasExtension" -Version "1.2"

Set-AzureRmVMAccessExtension -ResourceGroupName $rgroup -VMName $vmname -Name "SQLIaasExtension" -Version "1.2"