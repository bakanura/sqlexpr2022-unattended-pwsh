param (
    [string]$serviceprovider = "C:\Winacs\Tools\ServiceProvider\ServiceProvider.exe",
    [string]$PVSDATAPATH = "C:\Winacs\TEXT\ServiceProvider",
    [string]$PVSNAME = "X.ISYNET",
    [string]$cstiddev = "253438",
    [string]$InstanceName = "isynet"
)
    
    # Muss nach isynet ausgeführt werden, findet isch nach Installation unter Pfad unten
    # WinACS ist Programmverzeichniss von Isynet
    # 253438 => Demo-Kundennummer
    $serviceprovider = "C:\Winacs\Tools\ServiceProvider\ServiceProvider.exe"
    $PVSDATAPATH = "C:\Winacs\TEXT\ServiceProvider"
    $PVSNAME = "X.ISYNET"
    $cstiddev = "253438"
    $InstanceName = "isynet"
    $user = "Administrator"

    $serviceprovider + " " + "/PVSDATAPATH=$PVSDATAPATH" + " " + "/PVSNAME=$PVSNAME" + " " + "/KUNDENNUMMER=$cstiddev"

    # Isynetrunner => done if C:\Windows\WINACS.INI exists
    # Muss Script bauen, damit ich ini file anpassen kann
    $contentLines = @(
        '[DBEngine]',
        'Type=3',
        'DB=WINACS',
        "Server=127.0.0.1\ + $InstanceName",
        'IntSec=1',
        '[Pfade]',
        'Programm=c:\WINACS\',
        'Stamm=c:\WINACS\DATA',
        'Praxis=c:\WINACS\DATA',
        'Medikament=c:\IFAPWIN',
        'Archiv=c:\WINACS\DATA',
        'Export=c:\WINACS\EXPORT',
        'Import=c:\WINACS\IMPORT',
        'Temp=c:\WINACS\TEMP',
        'Formular=c:\WINACS\FORM',
        'Text=c:\WINACS\TEXT',
        'Hilfe=c:\WINACS\HILFE',
        'Modul=c:\WINACS\MODUL',
        'Pruefmodul=c:\WINACS\PRFMODUL',
        'Sound=c:\WINACS\SOUND',
        'Report=c:\WINACS\REPORT',
        'Vorlage=c:\WINACS\VORLAGE',
        'Rechnung=c:\WINACS\RECHNUNG',
        'Update=c:\WINACS\UPDATE',
        'Profi=c:\WINACS\PROFI',
        'DFUE=c:\WINACS\DFUE',
        'Skizzen=c:\WINACS\SKIZZEN',
        'FormEdit=c:\WINACS\FORMEDIT',
        'PDS=c:\WINACS\TEMP',
        'Foto=c:\WINACS\FOTO',
        'Spool=c:\WINACS\SPOOL',
        'Serienbrief=c:\WINACS\SERIENBRIEF',
        'Versand=c:\WINACS\VERSAND',
        'MedikamentEmpfehlung=c:\WINACS\MEDIKAMENT',
        'IsyDoku=c:\WINACS\ISYDOKU',
        'D2D=c:\WINACS\D2D',
        'REHA=c:\WINACS\REHA',
        'DMP=c:\WINACS\DMP',
        '',
        '[Benutzer]',
        "User=$user",
        'Mandant=1',
        '',
        '[Station]',
        'Nummer=1',
        'BroadcastIP=',
        'RemotePolling=Falsch',
        'Name=Anmeldung',
        '',
        '[Optionen]',
        'PRDruckAlt=1',
        'FormularAnzeigeArt=0',
        '',
        '[DBEngine]',
        'Type=3',
        'DB=WINACS',
        "Server=127.0.0.1\$InstanceName",
        'IntSec=1'
    )

    $content = $contentLines -join "`r`n"


    $content | Set-Content -Path "C:\Windows\WINACS.INI"
    Write-Host "WINACS.INI updated"
