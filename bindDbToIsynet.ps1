param (
    [Parameter(Mandatory = $true)]
    [hashtable]$ParamHash
)

# ----------------------------
# Unpack parameters from hashtable
# ----------------------------
foreach ($k in $ParamHash.Keys) {
    Set-Variable -Name $k -Value $ParamHash[$k] -Scope 0
}

# Verify required params
if (-not $downloadLinkIsynet) {
    throw "downloadLinkIsynet is null or empty!"
}

$ldf = "C:\Temp\isynet_Vollversion\Daten\xisynet_250371_2k16_log.ldf"
$mdf = "C:\Temp\isynet_Vollversion\Daten\xisynet_250371_2k16.mdf"
$dbName = "WINACS"
$InstanceName = "isynet"
$SAPWD = "noT-4-all"
$SA = "sa"
$instance = "ISYNET"
$serviceAccount = "NT SERVICE\MSSQL`$$instance"
$folder = "C:\Temp\isynet_Vollversion\Daten"
$isynetdestination = "C:\TEMP\isynet_Vollversion"
$zipFilePath = "C:\TEMP\isynet_Vollversion.zip"
$tempExtractFolder = "C:\TEMP\isynet_Vollversion_temp"


# Ensure the folder exists
mkdir C:\TEMP -ErrorAction SilentlyContinue

if (-Not (Test-Path $zipFilePath)) {
    (New-Object System.Net.Http.HttpClient).GetStreamAsync($downloadLinkIsynet).Result.CopyTo([System.IO.File]::Create($zipFilePath))
    Write-Host "Download completed: $zipFilePath"
} else { Write-Host "Zip file already exists. Skipping download." }


# Extract the zip file to a temporary folder
if (-Not (Test-Path $tempExtractFolder)) {
    Write-Host "Extracting zip file to temporary folder..."
    Expand-Archive -Path $zipFilePath -DestinationPath $tempExtractFolder -Force
} else {
    Write-Host "Temporary folder already exists. Skipping extraction."
}

# Check if the extracted subfolder exists
$extractedSubFolder = Join-Path -Path $tempExtractFolder -ChildPath "x.isynet_x.vianova_25.3_Quartalsversion_Vollversion"
if (-Not (Test-Path $extractedSubFolder)) {
    Write-Error "Expected subfolder not found in the extracted content. Please check the zip file."
    return
}

# Use robocopy for fast file transfer from temporary folder to destination
Write-Host "Using robocopy to move files to destination folder..."
robocopy $extractedSubFolder $isynetdestination /E /COPYALL /MOVE /NFL /NDL

# Clean up by removing the temporary extraction folder
Remove-Item -Path $tempExtractFolder -Recurse -Force
Write-Host "Temporary extraction folder cleaned up."

# Clean up by removing the downloaded zip file (optional)
Remove-Item -Path $zipFilePath -Force
Write-Host "Temporary zip file cleaned up."

# Ensure the SQL Server service account has full control over the database files
icacls $folder /grant "${serviceAccount}:(OI)(CI)F" /T

# SQL to attach the database
$sql = @(
"IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'$dbName')",
"BEGIN",
    "CREATE DATABASE [$dbName] ON", 
    "(FILENAME = N'$mdf'),",
    "(FILENAME = N'$ldf')",
    "FOR ATTACH;",
"END",
"ALTER AUTHORIZATION ON DATABASE::[$dbName] TO [WINACS];"
)

# Find sqlcmd.exe using Get-ChildItem and store the clean path in a variable
$sqlcmdPath = (Get-ChildItem -Path "C:\" -Filter "sqlcmd.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName)
if (-not $sqlcmdPath) {
    throw "sqlcmd.exe not found on C:\ drive. Please install SQL Server Command Line Utilities."
}

# Join SQL statements into a single string
$sqlText = $sql -join "`r`n"

# Pipe the SQL to sqlcmd
$sqlText | & $sqlcmdPath -S ".\$InstanceName" -U $SA -P $SAPWD -b

$sqlText
