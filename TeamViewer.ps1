. (Join-Path $PSScriptRoot 'Functions.ps1')

$downloadUrl = 'https://download.teamviewer.com/download/TeamViewer_Setup.exe'
$executableName = 'TeamViewer.exe'

$releaseUrl = 'http://www.filehorse.com/download-teamviewer/'
$versionRegEx = '.TeamViewer ([0-9\.]+)'

$localExecutable = 'C:\Program Files (x86)\TeamViewer\TeamViewer.exe'
$installerArguments = '/S /norestart'

Clear-Host

if ($localExecutable -eq '') {
	$localExecutable = Get-ChildItem C:\ -Recurse $executableName `
		-ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}

$latestVersion = Get-LatestVersion $releaseUrl $versionRegEx
$installedVersion = Get-InstalledVersion $localExecutable

$installer = Get-Installer @{
	LocalExecutable  = $localExecutable;
	LatestVersion    = $latestVersion;
	InstalledVersion = $installedVersion;
	DownloadUrl      = $downloadUrl
}

Write-Output "
Latest Version: $latestVersion
Installed Version: $installedVersion

Installer: $installer
"

$desktopLink = (Join-Path $env:UserProfile 'Desktop\TeamViewer.lnk')
Invoke-Installer $installer $installerArguments $desktopLink