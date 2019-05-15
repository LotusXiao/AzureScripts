if (Get-Module TEK-Functions) 
{
    Remove-Module -name TEK-Functions
}   
Import-Module -Name ./TEK-Functions

Login-AzAccount
Import-Csv -Path ./Set-VMAutoShutDown.csv | SetVMAutoShutDown