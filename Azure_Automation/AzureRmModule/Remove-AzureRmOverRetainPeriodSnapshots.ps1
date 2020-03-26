<#
.SYNOPSIS

.DESCRIPTION

This function will remove snapshots exceed retain periods


.PARAMETER retainsnapshorttime

snapshort retain perild in days eg. 365

.EXAMPLE

Remove-AzureRmOverRetainPeriodSnapshorts -retainsnapshottime 365

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

function Remove-AzureRmOverRetainPeriodSnapshots {
    param (

        [parameter(mandatory)]
        $retainsnapshottime

    )

     # Return all snapshots in the subcription
    $azsnapshots = Get-AzureRmSnapshot
    
    foreach ($azsnapshot in $azsnapshots) {

         ## Calculate how many days the snapshot has been created
        $dayssnapshotcreatedtime = [Math]::Abs(($azsnapshot.TimeCreated - (get-date)).days)

        $azsnapshotname = $azsnapshot.Name

        if ($dayssnapshotcreatedtime -gt $retainsnapshottime){
            
            Write-Warning -Message "Remvoing Snapshot $azsnapshotname." 
            ## confirmation needed to remove snapshots, change $true to $false to skip confirmation
            Remove-AzureRmSnapshot $azsnapshot.resourcegroupname -SnapshotName $azsnapshot.Name -Force -Confirm:$true
        }
        else{

            Write-host "$azsnapshotname is still in retain period." -ForegroundColor Green
        }
    }

}
