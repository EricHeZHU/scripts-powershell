
<#
.SYNOPSIS

.DESCRIPTION
This function will remove Azure Virtual Machine instance. It will remove public IP address, NICs, disks (managed or unmanaged disk), diag storage and also computer AD account. 

.NOTES
Author: Eric He ZHU (he.zhu@live.com.au)

#>

## Get installed Azure Modules
$AzModule = Get-InstalledModule -Name Az.* -ErrorAction SilentlyContinue

$AzureRmModule = Get-InstalledModule -Name Azure* -ErrorAction SilentlyContinue


## If no Azure Powershell Module installed, it will prompt to install Az module
if (($AzModule.count -eq 0) -and ($AzureRmModule.count -eq 0)){

    write-output "There is no Azure PowerShell Installed"

    Read-host -Prompt "Press any key to continue to install Az Module or CTRL+C to quit"
    
    Install-Module -name Az -Force

}


## If both Az and AzureRm both installed, it will prompt user to remove AzureRm module
if (($AzModule.count -ne 0) -and ($AzureRmModule.count -ne 0)){

    write-output "Both AzureRM and Az are isntall. Microsoft suggests it should not have both Module work together."

    Start-Process 'https://azure.microsoft.com/en-au/blog/azure-powershell-cross-platform-az-module-replacing-azurerm/'

    Read-host -Prompt "Press any key to continue to remove AzureRM Module or CTRL+C to quit"
    
    Remove-Module -name AzureRM* -Force
}

## If Az Module intalled, return Az PowerShell Module Installed
if ($AzModule.count -ne 0){

    write-output "Az PowerShell Module Installed"
}

## If AzureRM Module intalled, return Az PowerShell Module Installed
if ($AzureRmModule.count -ne 0){

    write-output "AzureRM PowerShell Module Installed"

}