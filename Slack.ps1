[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.DownloadUrl = 'https://downloads.slack-edge.com/releases_x64/SlackSetup.exe'
$config.ReleasesUrl = 'https://slack.com/downloads/windows'
$config.VersionRegEx = '.*Version ([\d]+\.[\d\.]+)'
$config.Executable = 'Slack.exe'
$config.InstallDestination = Join-Path $env:UserProfile 'AppData\Local'
$config.InstallerArguments = '/s'
$config.DesktopLink = Join-Path $env:UserProfile 'Desktop\Slack.lnk'

$config.LatestVersion = Get-VersionFromHtml $config.ReleasesUrl $config.VersionRegEx
$config.InstalledVersion = Get-InstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config | Format-Table

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments

		Remove-Item $config.DesktopLink -ErrorAction SilentlyContinue
	}
}