[CmdletBinding(SupportsShouldProcess = $true)]
param()

$script = $MyInvocation.MyCommand.Name

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$downloadUrl = 'https://downloads.slack-edge.com/releases_x64/SlackSetup.exe'
$executableName = 'Slack.exe'

$releaseUrl = 'https://slack.com/downloads/windows'
$versionRegEx = '.*Version ([\d]+\.[\d\.]+)'

$installerArguments = '/s'

$latestVersion = Get-VersionFromHtml $releaseUrl $versionRegEx
$installedVersion = Get-InstalledVersion `
	(Join-Path $env:UserProfile 'AppData\Local') $executableName

if ($latestVersion -ne $installedVersion) {
	if ($pscmdlet.ShouldProcess($script, 'Downloading the Installer...')) {
		$installer = Get-Installer $downloadUrl

		Write-Output "
Latest Version: $latestVersion
Installed Version: $installedVersion

Installer: $installer
Installing...`n"

		Invoke-Installer $installer $installerArguments
		Remove-Item (Join-Path $env:UserProfile 'Desktop\Slack.lnk') -ErrorAction SilentlyContinue
	}
}
else {
	Write-Output "$($script)...Up to Date`n"
}