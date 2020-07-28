




<#
.SYNOPSIS

.DESCRIPTION
This function will remove Azure unattached disks  

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation

.EXAMPLE

Remove-AzUnattachedDisks -forceremove true

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first
Login-azaccount

#>

function Remove-AzUnattachedDisks {
param(
    [Parameter(

        Mandatory = $false,
        HelpMessage = 'The unattached disks will be removed without confirmation'
    )
    ]
    [ValidateSet("true", "false")]
    [String]$forcetoremove = "false"
)
    $AzUnattachedManagedDisks = get-azdisk | select name, ResourceGroupName, DiskState | Where-Object {$_.DiskState -eq 'Unattached'}


    foreach ($AzUnattachedManagedDisk in $AzUnattachedManagedDisks){


            if ($forcetoremove -eq "false"){

                Write-Output "Removing disk " $AzUnattachedManagedDisk.name
                remove-azdisk $AzUnattachedManagedDisk.ResourceGroupName -DiskName $AzUnattachedManagedDisk.name

            }

            if ($forcetoremove -eq "true"){

                Write-Output "Removing disk " $AzUnattachedManagedDisk.name
                remove-azdisk $AzUnattachedManagedDisk.ResourceGroupName -DiskName $AzUnattachedManagedDisk.name -Force


            }

        
    }

}



# Set deleteUnattachedVHDs=1 if you want to delete unattached VHDs
# Set deleteUnattachedVHDs=0 if you want to see the Uri of the unattached VHDs
$deleteUnattachedVHDs=0
$storageAccounts = Get-AzStorageAccount
foreach($storageAccount in $storageAccounts){
    $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value
    $context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey
    $containers = Get-AzStorageContainer -Context $context
    foreach($container in $containers){
        $blobs = Get-AzStorageBlob -Container $container.Name -Context $context
        #Fetch all the Page blobs with extension .vhd as only Page blobs can be attached as disk to Azure VMs
        $blobs | Where-Object {$_.BlobType -eq 'PageBlob' -and $_.Name.EndsWith('.vhd')} | ForEach-Object { 
            #If a Page blob is not attached as disk then LeaseStatus will be unlocked
            if($_.ICloudBlob.Properties.LeaseStatus -eq 'Unlocked'){


                $_.ICloudBlob.Uri.AbsoluteUri | out-file -filepath '/Users/ericzhu/results/unattachedunmanagedvhd.txt' -Append

            }
        }
    }
}



