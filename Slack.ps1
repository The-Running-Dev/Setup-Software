. (Join-Path $PSScriptRoot 'Functions.ps1')

$downloadUrl = 'https://downloads.slack-edge.com/releases_x64/SlackSetup.exe'
$executableName = 'Slack.exe'

$releaseUrl = 'https://slack.com/downloads/windows'
$versionRegEx = '.*Version ([\d]+\.[\d\.]+)'

$localExecutable = 'C:\Users\boyank\AppData\Local\slack\slack.exe'
$installerArguments = '/s'

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

$desktopLink = (Join-Path $env:UserProfile 'Desktop\Slack.lnk')
Invoke-Installer $installer $installerArguments $desktopLink