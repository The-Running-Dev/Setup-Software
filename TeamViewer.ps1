[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$downloadUrl = 'https://download.teamviewer.com/download/TeamViewer_Setup.exe'
$executableName = 'TeamViewer.exe'

$releaseUrl = 'http://www.filehorse.com/download-teamviewer/'
$versionRegEx = '.TeamViewer ([0-9\.]+)'

$installerArguments = '/S /norestart'

$latestVersion = Get-VersionFromHtml $releaseUrl $versionRegEx
$installedVersion = Get-InstalledVersion ${env:ProgramFiles(x86)} $executableName

if ($latestVersion -ne $installedVersion) {
	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading the Installer...')) {
		$installer = Get-Installer $downloadUrl

		Write-Output "
Latest Version: $latestVersion
Installed Version: $installedVersion

Installer: $installer
Installing...`n"

		Invoke-Installer $installer $installerArguments
		Remove-Item (Join-Path $env:UserProfile 'Desktop\TeamViewer 14.lnk') -ErrorAction SilentlyContinue
	}
}
else {
	Write-Output "$($config.Name)...Up to Date`n"
}