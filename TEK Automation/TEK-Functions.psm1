function DisplayMenu
# In progress
{
param(
    [parameter(Mandatory=$true)]$GetFunction,
	[parameter(Mandatory=$true)]$Name,
    [parameter(Mandatory=$false)]$SetFunction,
    [parameter(Mandatory=$false)]$Options
	)

	$GetFunction = [Scriptblock]::Create($GetFunction)
    $ChosenResource = $(Invoke-command -ScriptBlock $GetFunction)
	$count = 0
	Foreach($cr in $ChosenResource)
		{
			Write-Host "[$count]" $cr.$Name
			$count++
		}
	$selection = Read-Host "Select option"
	Write-Host "Selected resource: " $ChosenResource[$selection].$Name
	
	$SetFunction = [Scriptblock]::Create($SetFunction)
    Invoke-command -ScriptBlock $SetFunction

}

function DeleteResourceGroup

{
	param(
		[parameter(ValueFromPipelineByPropertyName=$true)]$Name,
		[parameter(ValueFromPipelineByPropertyName=$true)]$SubscriptionName
		)
	
	process
	{
		Select-AzSubscription -SubscriptionName $SubscriptionName
		Write-Output "Deleting ResourceGroup $Name from Subscription $Subscription..."
		Remove-AzResourceGroup -Name $Name -Force -AsJob
	}
}

function SetVMAutoShutDown

{
	param(
		[parameter(ValueFromPipelineByPropertyName=$true)]$Name,
		[parameter(ValueFromPipelineByPropertyName=$true)]$SubscriptionName,
		[parameter(ValueFromPipelineByPropertyName=$true)]$ResourceGroupName,
		[parameter(ValueFromPipelineByPropertyName=$true)]$Time,		
		[parameter(ValueFromPipelineByPropertyName=$true)]$TimeZone = "FLE Standard Time",		
		[parameter(ValueFromPipelineByPropertyName=$true)]$WebhookUrl,		
		[parameter(ValueFromPipelineByPropertyName=$true)]$Email,		
		[parameter(ValueFromPipelineByPropertyName=$true)]$Disable		
		)
	
	process
	{
		Select-AzSubscription -SubscriptionName $SubscriptionName
		$properties = @{}
		$notificationsettings = @{
            "status" = "Disabled";
            "timeInMinutes" = 30
			}
	
		if ($WebhookUrl)
		{
			$notificationsettings["status"] = "Enabled"
			$notificationsettings += @{"WebhookUrl" = $WebhookUrl}
		}
		
		if ($Email)
		{
			$notificationsettings["status"] = "Enabled"
			$notificationsettings += @{emailRecipient = $Email; notificationLocale = "en"}
		}
		
		if ($Disable)
			{
				$properties += @{status = "Disabled"}
			}
		else
			{
				$properties += @{status = "Enabled"}
			}
			
		$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction SilentlyContinue
			if ($vm -eq $null) 
				{
					Write-Error -Message "Virtual machine '$Name' under resource group '$ResourceGroupName' was not found."
				}

		$properties += @{
		taskType = "ComputeVmShutdownTask";
        dailyRecurrence = @{"time" = ("{0:HHmm}" -f $Time) };
        timeZoneId = $TimeZone;
        notificationSettings = $notificationsettings;
        targetResourceId = $vm.Id
    }
		
		New-AzResource -ResourceId ("/subscriptions/{0}/resourceGroups/{1}/providers/microsoft.devtestlab/schedules/shutdown-computevm-{2}" -f (Get-AzContext).Subscription.Id, $ResourceGroupName, $Name) -Location $vm.Location -Properties $properties -ApiVersion "2017-04-26-preview" -Force
		Write-Output "Creating Auto-Shutdown for $Name..."
	}
}

Export-ModuleMember -Function DisplayMenu
Export-ModuleMember -Function DeleteResourceGroup
Export-ModuleMember -Function SetVMAutoShutDown