# Script to write a given registry key to Application event log, to be pulled from machine via log collection

# Get the registry key
$log = reg query "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL" /s|Out-String

# Write to Application log
Write-EventLog -LogName "Application" -Source "Windows Error Reporting" -EventID 9999 -EntryType Error -Message $log -Category 1 -RawData 10,20