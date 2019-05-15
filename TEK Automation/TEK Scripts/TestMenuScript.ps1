if (Get-Module TEK-Functions) 
{
    Remove-Module -name TEK-Functions
}   
Import-Module -Name ./TEK-Functions

$Options = @{"Name" = "S*"}
DisplayMenu -GetFunction 'Get-AzResourceGroup @Options' -Name 'ResourceGroupName' -SetFunction {DisplayMenu -GetFunction 'Get-AzResourceGroup' -Name 'ResourceGroupName'}