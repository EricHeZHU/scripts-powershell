

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

#>

function  Remove-AzStorageAccountsContainerContents {
    param (
        
        # The Storage Account name to remove
        [parameter(mandatory)]
        [String]$StorageAccountName,

        [parameter(mandatory)]
        [String]$StorageAccountKey,

        [parameter(mandatory)]
        [String]$Container

    )

    ## Return Context of the Storage Account BlobStorage
    $ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

    ## Remove Contents of the Blob Container storage
    Get-AzStorageBlob -Context $ctx -Container $Container | Remove-AzStorageBlob

    ## Remove Container itself
    Remove-AzStorageContainer -Context $ctx -Name $Container -Force
}