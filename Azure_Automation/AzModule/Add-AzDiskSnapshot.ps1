


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

Remove-AzDiskSnapshot -ResourceGroup 'ABCD' -location 'Australia East' -VMName 'EFHG'

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first
Login-azaccount

#>

function Add-AzDiskSnapshot{
    
    param(
        [parameter(mandatory)]
        [string]$resourceGroupName, 

        [parameter(mandatory)]
        [string]$location, 

        [parameter(mandatory)]
        [string]$vmName

    )

$vm = get-azvm `
    -ResourceGroupName $resourceGroupName `
    -Name $vmName


$snapshotName = $vm.StorageProfile.OsDisk.name + '_snapshot_'+ $(get-date -f yyyyMMddhhmmss)

$snapshot = New-AzSnapshotConfig `
    -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
    -Location $location `
    -CreateOption copy


New-AzSnapshot `
    -Snapshot $snapshot `
    -SnapshotName $snapshotName `
    -ResourceGroupName $resourceGroupName
}

