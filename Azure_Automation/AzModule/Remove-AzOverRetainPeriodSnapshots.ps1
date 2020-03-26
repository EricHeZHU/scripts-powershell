<#
.SYNOPSIS

.DESCRIPTION

This function will remove snapshots exceed retain periods


.PARAMETER RetainSnapshortTime

snapshort retain perild in days eg. 365

.EXAMPLE

Remove-AzOverRetainPeriodSnapshorts -retainsnapshottime 365

.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first
Login-azaccount


#>

function Remove-AzOverRetainPeriodSnapshots {
    param (

        [parameter(mandatory)]
        $retainsnapshottime

    )

    # Return all snapshots in the subcription
    $azsnapshots = Get-AzSnapshot

    foreach ($azsnapshot in $azsnapshots) {

        ## Calculate how many days the snapshot has been created
        $dayssnapshotcreatedtime = [Math]::Abs(($azsnapshot.TimeCreated - (get-date)).days)

        $azsnapshotname = $azsnapshot.Name

        if ($dayssnapshotcreatedtime -gt $retainsnapshottime){

            Write-Warning -Message "Remving Snapshot $azsnapshotname." 
            ## confirmation needed to remove snapshots, change $true to $false to skip confirmation
            Remove-AzSnapshot  $azsnapshot.resourcegroupname -SnapshotName $azsnapshot.Name -Force -Confirm:$true
        }
        else{

            Write-host "$azsnapshotname is still in retain period." -ForegroundColor Green
        }
    }

}
