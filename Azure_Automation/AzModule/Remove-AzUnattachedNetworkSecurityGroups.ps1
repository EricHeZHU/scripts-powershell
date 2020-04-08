
<#
.SYNOPSIS

.DESCRIPTION

This script will find and remove Azure network security groups not attached to any virtul networks or subnets

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation


.NOTES
Author: Eric ZHU (he.zhu@live.com.au)

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first
Login-azaccount

#>

function Remove-AzUnattachedNetworkSecurityGroups {
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
    $nsgs = Get-AzNetworkSecurityGroup | Select-Object name, resourcegroupname, location, NetworkInterfaces, subnets | `
    Where-Object {($_.networkinterfaces.count -eq 0) -and ($_.subnets.count -eq 0)}

    Write-Output $nsgs| Format-Table

    foreach ($nsg in $nsgs){

        if ($forcetoremove -eq "false"){
    
            Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName


        }
        if($forcetoremove -eq "true"){
            
            Remove-AzNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force


        }


    }
    
}