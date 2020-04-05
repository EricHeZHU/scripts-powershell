

<#
.SYNOPSIS

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation

.DESCRIPTION

This script will find and remove Azure Public IP addresses not attached to any Azure Resouces

.EXAMPLE

Remove-UnattachedPublicIPAddress

Remove-UnattachedPublicIPAddress -forcetoremove true

General notes

For Az Module installed
use the Enable/Disable-AzureRmAlias cmdlets to add or remove aliases from AzureRM cmdlets to Az cmdlets
Enable-AzureRmAlias
Login-azaccount

For Azure RM Module installed
It needs to connect to AzureRM subscription first
Login-AzureRmAccount 


#>

function Remove-AzureRmUnattachedPublicIPAddress{
    param(
        [Parameter(
    
            Mandatory = $false,
            HelpMessage = 'The Public IP Address will be removed without confirmation!'
        )
        ]
        [ValidateSet("true", "false")]
        [String]$forcetoremove = "false"
        
        
       
    )
    
        ## Return Azure Public IP Addresses information
        $AzPublicIpAddresses = Get-AzureRmPublicIpAddress | Select-Object Name, @{N='ResourceGroup';E={$_.ResourceGroupName}}, Location, @{n='AttachedtoInterface';E={($_.IpConfiguration.id -split '/')[8]}}

        Write-Output $AzPublicIpAddresses | Format-Table

        foreach($AzPublicIpAddress in $AzPublicIpAddresses){
    
            if ($AzPublicIpAddress.AttachedtoInterface -eq $null){
    

                #Start-Sleep -Seconds 10
    
                if ($forcetoremove -eq "false"){
    
                    Remove-AzureRmPublicIpAddress -Name $AzPublicIpAddress.Name -ResourceGroupName $AzPublicIpAddress.ResourceGroup
    
    
                }
                if($forcetoremove -eq "true"){
                    
                    Remove-AzureRmPublicIpAddress -Name $AzPublicIpAddress.Name -ResourceGroupName $AzPublicIpAddress.ResourceGroup -Force
    
    
                }
    
            }
    
    
        }
    
    }
    