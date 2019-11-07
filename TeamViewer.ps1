[CmdletBinding(SupportsShouldProcess = $true)]
param()

Clear-Host

$script = $MyInvocation.MyCommand.Name

. (Join-Path $PSScriptRoot 'Functions.ps1')

$downloadUrl = 'https://download.teamviewer.com/download/TeamViewer_Setup.exe'
$executableName = 'TeamViewer.exe'

$releaseUrl = 'http://www.filehorse.com/download-teamviewer/'
$versionRegEx = '.TeamViewer ([0-9\.]+)'

$installerArguments = '/S /norestart'

$executablePath = Get-ChildItem C:\ -Recurse $executableName `
	-ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

$latestVersion = Get-LatestVersion $releaseUrl $versionRegEx
$installedVersion = Get-InstalledVersion $executablePath

if ($latestVersion -ne $installedVersion) {
	if ($pscmdlet.ShouldProcess($script, 'Downloading the Installer...')) {
		$installer = Get-Installer $downloadUrl

		Write-Output "
Latest Version: $latestVersion
Installed Version: $installedVersion

Installer: $installer
Installing...`n"

		$desktopLink = (Join-Path $env:UserProfile 'Desktop\TeamViewer 14.lnk')
		Invoke-Installer $installer $installerArguments $desktopLink
	}
}
else {
	Write-Output "`nYour Are Up to Date...`n"
}