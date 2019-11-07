[CmdletBinding(SupportsShouldProcess = $true)]
param()

Clear-Host

$script = $MyInvocation.MyCommand.Name

. (Join-Path $PSScriptRoot 'Functions.ps1')

$downloadUrl = 'https://downloads.slack-edge.com/releases_x64/SlackSetup.exe'
$executableName = 'Slack.exe'

$releaseUrl = 'https://slack.com/downloads/windows'
$versionRegEx = '.*Version ([\d]+\.[\d\.]+)'

$installerArguments = '/s'

$executablePath = Get-ChildItem (Join-Path $env:UserProfile 'AppData\Local') `
	-Recurse $executableName -ErrorAction SilentlyContinue | `
	Select-Object -First 1 -ExpandProperty FullName

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

		$desktopLink = (Join-Path $env:UserProfile 'Desktop\Slack.lnk')
		Invoke-Installer $installer $installerArguments $desktopLink
	}
}
else {
	Write-Output "`nYour Are Up to Date...`n"
}