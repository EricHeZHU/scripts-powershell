<#
.SYNOPSIS

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation

.DESCRIPTION

This script will find and remove Azure network interfaces not attached to any virtul machines

General notes

For Az Module installed
use the Enable/Disable-AzureRmAlias cmdlets to add or remove aliases from AzureRM cmdlets to Az cmdlets
Enable-AzureRmAlias
Login-azaccount

For Azure RM Module installed
It needs to connect to AzureRM subscription first
Login-AzureRmAccount 


#>

function Remove-AzureRmUnattachedNetworkInterfaces{
    param(
        [Parameter(
    
            Mandatory = $false,
            HelpMessage = 'The network interfaces will be removed without confirmation'
        )
        ]
        [ValidateSet("true", "false")]
        [String]$forcetoremove = "false"
        
        
        
       
    )
    
        # Return Azure network interfaces info
        $aznetworkinterfaces = Get-AzureRmNetworkInterface | Select-Object Name, ResourceGroupName, Location, VirtualMachine
    
        foreach($aznetworkinterface in $aznetworkinterfaces){
    
            if ($aznetworkinterface.VirtualMachine -eq $null){
    
                Write-Output $aznetworkinterface | Format-Table
                #Start-Sleep -Seconds 10
    
                if ($forcetoremove -eq "false"){
    
                    Remove-AzureRmNetworkInterface -Name $aznetworkinterface.Name -ResourceGroupName $aznetworkinterface.ResourceGroupName
    
    
                }
                if($forcetoremove -eq "true"){
                    
                    Remove-AzureRmNetworkInterface -Name $aznetworkinterface.Name -ResourceGroupName $aznetworkinterface.ResourceGroupName -Force
    
    
                }
    
            }
    
    
        }
    
    }