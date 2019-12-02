[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$versionData = Get-VersionFromRedirectUrl $config.ReleasesUrl $config.VersionRegEx
$config.LatestVersion = $versionData.Version
$config.DownloadUrl = $versionData.Url
$config.InstalledVersion = Get-MajorMinorBuildInstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments
	}
}

if ($config.InstalledVersion) {
	Save-Config $config
}