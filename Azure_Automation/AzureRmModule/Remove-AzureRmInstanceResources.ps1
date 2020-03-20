<#
.SYNOPSIS

.DESCRIPTION
This function will remove Azure Virtual Machine instance. It will remove public IP address, NICs, disks (managed or unmanaged disk), diag storage and also computer AD account. 

.PARAMETER ResourceGroup
Resource group name

.PARAMETER VMName
Virtual Machaine name

.PARAMETER RemovePublicIP
Set true to remove public IP attached to VM. Default is false. 

.EXAMPLE

Remove-AzureRmVMInstanceResources -ResourceGroup 'ABCD' -VMName 'EFHG' -RemovePublicIP $true

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

Azure RM Module required
It needs to connect to AzureRM subscription first
Login-AzureRmAccount 

#>

function  Remove-AzureRMVMInstanceResouces {
    [cmdletbinding(SupportsShouldProcess,ConfirmImpact='High')]
    param (

        # ResourceGroup Name
        [parameter(mandatory)]
        [string]$ResourceGroup,

        # The VM name to remove, regex are supported
        [parameter(mandatory)]
        [string]$VMname,

        # A configuration setting to also delete public IP's, off by default
        $RemovePublicIP = $false

    )

    # Remove the VM's and then remove the datadisks, osdisk, NICs
    Get-AzureRmVM -ResourceGroupName $ResourceGroup | Where Name -Match $VMName  | foreach {
        $vm=$_
        $DataDisks = @($vm.StorageProfile.DataDisks.Name)
        $OSDisk = @($vm.StorageProfile.OSDisk.Name) 

        ## diagnostics storage
        $azResourceParams = @{
            'ResourceName' = $VMName
            'ResourceType' = 'Microsoft.Compute/virtualMachines'
                'ResourceGroupName' = $ResourceGroup
            }
        $vmResource = Get-AzureRmResource @azResourceParams
        $vmId = $vmResource.Properties.VmId
        $diagSa = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
        $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, 9), $vmId)
        $diagSaRg = (Get-AzureRmStorageAccount | where { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
        $saParams = @{
            'ResourceGroupName' = $diagSaRg
            'Name' = $diagSa
        } 

        ## If there is no diagstorage, there will be error returned and script will go on running
        $diagStorage =  Get-AzureRmStorageAccount @saParams | Get-AzureStorageContainer | where { $_.Name-eq $diagContainerName } 

        if ($pscmdlet.ShouldProcess("$($_.Name)", "Removing VM, Disks, NIC (PublicIP): $($_.Name)"))
        {
            Write-Warning -Message "Removing VM: $($_.Name)"
            $_ | Remove-AzureRmVM -Force -Confirm:$false

            $_.NetworkProfile.NetworkInterfaces | where {$_.ID} | ForEach-Object {
                $NICName = Split-Path -Path $_.ID -leaf
                Write-Warning -Message "Removing NIC: $NICName"
                $Nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup -Name $NICName
                $Nic | Remove-AzureRmNetworkInterface -Force
                
                # Optionally remove public ip's, will not save the static ip, if you need the same one, do not delete it.
                if ($RemovePublicIP)
                {
                    $nic.IpConfigurations.PublicIpAddress | where {$_.ID} | ForEach-Object {
                        $PublicIPName = Split-Path -Path $_.ID -leaf
                        Write-Warning -Message "Removing PublicIP: $PublicIPName"
                        $PublicIP = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Name $PublicIPName
                        $PublicIP | Remove-AzureRmPublicIpAddress -Force
                    }
                }
            }

            # Support to remove managed disks
            if($vm.StorageProfile.OsDisk.ManagedDisk ) {
                ($OSDisk + $DataDisks) | where {$_.Name} | ForEach-Object {
                    Write-Warning -Message "Removing Disk: $_"
                    Get-AzureRmDisk -ResourceGroupName $ResourceGroup -DiskName $_ | Remove-AzureRmDisk -Force
                }
            }
            # Support to remove unmanaged disks (from Storage Account Blob)
            else {
                # This assumes that OSDISK and DATADisks are on the same blob storage account
                # Modify the function if that is not the case.
                $saname = ($vm.StorageProfile.OsDisk.Vhd.Uri -split '\.' | Select -First 1) -split '//' |  Select -Last 1
                $sa = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroup -Name $saname
        
                # Remove DATA disks
                $vm.StorageProfile.DataDisks | foreach {
                    $disk = $_.Vhd.Uri | Split-Path -Leaf
                    Get-AzureStorageContainer -Name vhds -Context $Sa.Context |
                    Get-AzureStorageBlob -Blob  $disk |
                    Remove-AzureStorageBlob  
                }
        
                # Remove OSDisk disk
                $disk = $vm.StorageProfile.OsDisk.Vhd.Uri | Split-Path -Leaf
                Get-AzureStorageContainer -Name vhds -Context $Sa.Context |
                Get-AzureStorageBlob -Blob  $disk |
                Remove-AzureStorageBlob  

            }
            
            # Support to remove diagnostics storage
            if ($diagStorage -ne $null){

                Write-Warning -Message "VM has diagnostics storage, removing $diagstorage"
                $diagStorage | Remove-AzureStorageContainer -Force

            }
            else {
                Write-Output "VM does not have diagnositcs storage"
            }

            # If you are on the network you can cleanup the Computer Account in AD            
            # Get-ADComputer -Identity $vm.OSProfile.ComputerName | Remove-ADObject -Recursive -confirm:$false
        
        }#PSCmdlet(ShouldProcess)
    }
    
}

