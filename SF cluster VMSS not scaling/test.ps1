# Script to download another PS script from an Azure blob and create a scheduled task to execute it locally.
# Run with the Azure Blob as -Uri parameter from command line.

param
(
	$uri, 
	$ScriptName = "configurationscript.ps1",
	$ScriptInstallPath = (Join-Path $PSScriptRoot $ScriptName),
	$TaskName = "LogDate Test Script"
)

function Setup-ScheduledTask
{
    # Create the Task Triggers, so that it will run at startup and Daily
    $Triggers = @()
    $Triggers += New-ScheduledTaskTrigger -AtStartup
    $Triggers += New-ScheduledTaskTrigger -At 12AM -Daily

    # Create Settings that that if a Scheduled Start is missed it will strart right away.
    $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable

    # Create the Action for the task, Execute our Powershell Script to configure the node settings.
    $Action = New-ScheduledTaskAction -Execute Powershell.exe -Argument "-File $ScriptInstallPath"

    # Create the Task
    $Task = Register-ScheduledTask -TaskName $TaskName -Trigger $Triggers -Action $Action -User System -RunLevel Highest -Description "Log date of execution"

    # Add to the Daily Trigger to execute every 30min once it has started.
    $Task.Triggers | ?{$_.DaysInterval -ne $null} | %{$_.Repetition.Duration = "P1D"; $_.Repetition.Interval = "PT30M"; $_.Repetition.StopAtDurationEnd = $True}
    $Task | Set-ScheduledTask
}


Invoke-WebRequest -Uri $Uri -OutFile $ScriptInstallPath
get-content $ScriptInstallPath | % { write-host $_ }

Setup-ScheduledTask

#invoke-expression -Command .\configurationscript.ps1