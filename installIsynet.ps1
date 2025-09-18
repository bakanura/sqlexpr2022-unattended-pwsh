param (
    [Parameter(Mandatory = $true)]
    [hashtable]$ParamHash,
    [string]$isynetExePath = "setup.exe",
    [string]$isynetArgs = '/s /f1"C:\TEMP\isynet.iss"',
    [string]$isynetDestination = "C:\TEMP\isynet_Vollversion",
    [string]$zipFilePath = "C:\TEMP\isynet_Vollversion.zip",
    [string]$tempExtractFolder = "C:\TEMP\isynet_Vollversion_temp"
)

# ----------------------------
# Unpack parameters from hashtable
# ----------------------------
foreach ($k in $ParamHash.Keys) {
    Set-Variable -Name $k -Value $ParamHash[$k] -Scope 0
}

# ----------------------------
# Install required .NET Framework
# ----------------------------
function Install-NetFramework {
    param ([string]$version)
    Write-Host "Checking if .NET Framework $version is installed..."
    if ($version -eq "3.5") {
        Write-Host "Installing .NET Framework 3.5 (includes 2.0 and 3.0)..."
        Enable-WindowsOptionalFeature -FeatureName "NetFx3" -Online -All -NoRestart
    }
}

Install-NetFramework -version "3.5"
Write-Host "All specified .NET Framework versions are installed or already present!"

# ----------------------------
# Download iSynet using $ParamHash['downloadLinkIsynet']
# ----------------------------
if (-Not (Test-Path $zipFilePath)) {
    if (-Not $ParamHash.ContainsKey('downloadLinkIsynet')) {
        Write-Error "Download link for iSynet not found in ParamHash!"
        return
    }
    Write-Host "Downloading iSynet from $($ParamHash['downloadLinkIsynet'])..."
    Invoke-WebRequest -Uri $ParamHash['downloadLinkIsynet'] -OutFile $zipFilePath
} else {
    Write-Host "iSynet zip already exists at $zipFilePath"
}

# ----------------------------
# Extract zip to temp folder
# ----------------------------
if (Test-Path $tempExtractFolder) { Remove-Item $tempExtractFolder -Recurse -Force }
Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractFolder

# Move extracted files to final destination
if (-Not (Test-Path $isynetDestination)) { New-Item -ItemType Directory -Path $isynetDestination | Out-Null }
Copy-Item -Path "$tempExtractFolder\*" -Destination $isynetDestination -Recurse -Force

# ----------------------------
# Build ISS file
# ----------------------------
$isynetIssFileLines = @(
    '[InstallShield Silent]',
    'Version=v7.00',
    'File=Response File',
    '[File Transfer]',
    'OverwrittenReadOnly=NoToAll',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-DlgOrder]',
    'Dlg0={210FBC0C-762F-4823-91FF-9862A07D0129}-SdWelcome-0',
    'Count=8',
    'Dlg1={210FBC0C-762F-4823-91FF-9862A07D0129}-PraxisTypeDialog-0',
    'Dlg2={210FBC0C-762F-4823-91FF-9862A07D0129}-SQLServerDialog-0',
    'Dlg3={210FBC0C-762F-4823-91FF-9862A07D0129}-ApplicationTypeDialog-0',
    'Dlg4={210FBC0C-762F-4823-91FF-9862A07D0129}-SdAskDestPath2-0',
    'Dlg5={210FBC0C-762F-4823-91FF-9862A07D0129}-SdStartCopy2-0',
    'Dlg6={210FBC0C-762F-4823-91FF-9862A07D0129}-SdFinishReboot-0',
    'Dlg7={210FBC0C-762F-4823-91FF-9862A07D0129}-SdFinishReboot-1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SdWelcome-0]',
    'Result=1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-PraxisTypeDialog-0]',
    'PraxisType=0',
    'Result=1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SQLServerDialog-0]',
    'Server=127.0.0.1',
    'DB=WINACS',
    'WindowsAuth=1',
    'Result=1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-ApplicationTypeDialog-0]',
    'ApplicationType=0',
    'Result=1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SdAskDestPath2-0]',
    'szDir=c:\WINACS',
    'Result=1',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SdStartCopy2-0]',
    'Result=1',
    '[Application]',
    'Name=Vollversion',
    'Version=25.3.67',
    'Company=medatixx GmbH & Co. KG',
    'Lang=0407',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SdFinishReboot-0]',
    'Result=1',
    'BootOption=0',
    '[{210FBC0C-762F-4823-91FF-9862A07D0129}-SdFinishReboot-1]',
    'Result=1',
    'BootOption=0'
)

Set-Content -Path "C:\TEMP\isynet.iss" -Value ($isynetIssFileLines -join "`r`n") -Encoding ASCII

# ----------------------------
# Run the installer
# ----------------------------
$fullExePath = Join-Path -Path $isynetDestination -ChildPath $isynetExePath

if (-Not (Test-Path $fullExePath)) {
    Write-Error "Executable not found at path: $fullExePath"
    return
} else {
    Write-Host "Executable found at $fullExePath. Starting silent install..."
    Start-Process -FilePath $fullExePath -ArgumentList $isynetArgs -Wait
}
