
<#
.SYNOPSIS

.DESCRIPTION

This script will find and remove Azure network security groups not attached to any virtul networks or subnets

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation


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

function Remove-AzureRmUnattachedNetworkSecurityGroups {
    param (
        [Parameter(
    
            Mandatory = $false,
            HelpMessage = 'The Network Security Groups will be removed without confirmation!'
        )
        ]
        [ValidateSet("true", "false")]
        [String]$forcetoremove = "false"
    )

    # return network security group not attached to any network interfaces and also subnets
    $nsgs = Get-AzureRmNetworkSecurityGroup | Select-Object name, resourcegroupname, location, NetworkInterfaces, subnets | `
    Where-Object {($_.networkinterfaces.count -eq 0) -and ($_.subnets.count -eq 0)}

    Write-Output $nsgs| Format-Table

    foreach ($nsg in $nsgs){

        if ($forcetoremove -eq "false"){
    
            Remove-AzureRmNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName


        }
        if($forcetoremove -eq "true"){
            
            Remove-AzureRmNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force


        }


    }
    
}