param (
    [string]$serviceNamePattern = "ServiceProvider_*",
    [string]$logFilePath = "C:\Program Files (x86)\Common Files\MCSSHARED\LOGS\Vollversion.log",
    [string]$successString = "Prozess beendet mit ReturnCode: 0"
)

    # Get processes matching the pattern
    $matchingProcesses = Get-Process | Where-Object { $_.Name -like $serviceNamePattern }

    # Check log file content
    $svcLogChecker = Get-Content -Path $logFilePath -ErrorAction SilentlyContinue

    if ($matchingProcesses -and ($svcLogChecker -contains $successString)) {
        Write-Host "WINACS is installed and Log reports end of process."
    } else {
        Write-Host "WINACS is not installed or Log does not report end of process."
    }