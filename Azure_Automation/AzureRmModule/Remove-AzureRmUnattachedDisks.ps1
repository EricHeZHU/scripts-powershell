


<#
.SYNOPSIS

.DESCRIPTION
This function will remove Azure unattached disks  

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation

.EXAMPLE

Remove-AzureRmUnattachedDisks -forcetoremove true

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first

Enable-AzureRmAlias


#>

function Remove-AzureRmUnattachedDisks {
    param(
        [Parameter(
    
            Mandatory = $false,
            HelpMessage = 'The unattached disks will be removed without confirmation'
        )
        ]
        [ValidateSet("true", "false")]
        [String]$forcetoremove = "false"
    )
        $AzureRmUnattachedDisks = get-azurermdisk | Select-Object name, ResourceGroupName, DiskState | Where-Object {$_.DiskState -eq 'Unattached'}
    
        if ($forcetoremove -eq "true"){
    
    
            
        }
    
        foreach ( $AzureRmUnattachedDisk in  $AzureRmUnattachedDisks){
    
    
                if ($forcetoremove -eq "false"){
    
                    Write-Output "Removing disk " $AzureRmUnattachedDisk.name
                    remove-azdisk $AzureRmUnattachedDisk.ResourceGroupName -DiskName $AzureRmUnattachedDisk.name
    
                }
    
                if ($forcetoremove -eq "true"){
    
                    Write-Output "Removing disk " $AzureRmUnattachedDisk.name
                    remove-azdisk $AzureRmUnattachedDisk.ResourceGroupName -DiskName $AzureRmUnattachedDisk.name -Force
    
    
                }
    
            
        }
    
    }
    