

<#
.SYNOPSIS

.DESCRIPTION
This function will remove Azure Virtual Machine instance. It will remove public IP address, NICs, disks (managed or unmanaged disk), diag storage and also computer AD account. 

.PARAMETER ResourceGroup
Resource group name

.PARAMETER Location
Azure Location eg. Australia East, East Asia

.PARAMETER VMName
Virtual Machaine name


.EXAMPLE

Remove-AzureRmDiskSnapshot -ResourceGroup 'ABCD' -location 'Australia East' -VMName 'EFHG'

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

For Az Module installed
use the Enable/Disable-AzureRmAlias cmdlets to add or remove aliases from AzureRM cmdlets to Az cmdlets
Enable-AzureRmAlias
Login-azaccount

For Azure RM Module installed
It needs to connect to AzureRM subscription first
Login-AzureRmAccount 


#>

function Add-AzureRmDiskSnapshot{
    
    param(
        [parameter(mandatory)]
        [string]$resourceGroupName, 

        [parameter(mandatory)]
        [string]$location, 

        [parameter(mandatory)]
        [string]$vmName

    )

$vm = get-azurermvm `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName

$snapshotName = $vm.StorageProfile.OsDisk.name + '_snapshot_'+ $(get-date -f yyyyMMddhhmmss)

$snapshot = New-AzureRmSnapshotConfig `
    -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
    -Location $location `
    -CreateOption copy


New-AzureRmSnapshot `
    -Snapshot $snapshot `
    -SnapshotName $snapshotName `
    -ResourceGroupName $resourceGroupName

}