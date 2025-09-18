param (
    [string]$iniFilePath = "C:\Windows\WINACS.INI",
    [string]$winacsFolderPath = "C:\WINACS",
    [string]$logFilePath = "C:\Program Files (x86)\Common Files\MCSSHARED\LOGS\Vollversion.log",
    [string]$logSuccessString = "Prozess beendet!"
)

    # Check for WINACS.ini and folder size
    $iniFileExists = Test-Path $iniFilePath

    # Only files have Length, so filter with -File
    $folderSizeBytes = 0
    [System.IO.Directory]::EnumerateFiles($winacsFolderPath, '*', 'AllDirectories') |
        ForEach-Object {
            try {
                $folderSizeBytes += (Get-Item $_).Length
            } catch {
                Write-Host "Could not access file: $_"
            }
        }
    $folderSizeKB = $folderSizeBytes -shr 10

    # Read the log file if it exists
    $isynetLogChecker = Get-Content $logFilePath -ErrorAction SilentlyContinue

    if ($iniFileExists -and $folderSizeKB -gt 7050 -and ($isynetLogChecker -contains $logSuccessString)) {
        Write-Host "WINACS is installed and folder is not empty."
    } else {
        Write-Host "WINACS is not installed or folder is empty."
    }