

<#
.SYNOPSIS

.PARAMETER forcetoremote
default value is false, -forcetoremote will skip azure confirmation

.DESCRIPTION

This script will find and remove Azure network interfaces not attached to any virtul machines

General notes

AZ Module Required
The script is running under donetcore so it can run in both Windows, Linux and MAC OS
It needs to connect to AzureRM subscription first
Login-azaccount


#>

function Remove-AzUnattachedNetworkInterfaces{
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
    $aznetworkinterfaces = Get-AzNetworkInterface | Select-Object Name, ResourceGroupName, Location, VirtualMachine

    foreach($aznetworkinterface in $aznetworkinterfaces){

        if ($aznetworkinterface.VirtualMachine -eq $null){

            Write-Output $aznetworkinterface | Format-Table
            #Start-Sleep -Seconds 10

            if ($forcetoremove -eq "false"){

                Remove-AzNetworkInterface -Name $aznetworkinterface.Name -ResourceGroupName $aznetworkinterface.ResourceGroupName


            }
            if($forcetoremove -eq "true"){
                
                Remove-AzNetworkInterface -Name $aznetworkinterface.Name -ResourceGroupName $aznetworkinterface.ResourceGroupName -Force


            }

        }


    }

}


