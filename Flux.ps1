[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.LatestVersion = Get-VersionFromHtml $config.ReleasesUrl $config.VersionRegEx
$config.InstalledVersion = Get-MajorMinorInstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments

		Remove-Item $config.DesktopLink -ErrorAction SilentlyContinue
	}
}

if ($config.InstalledVersion) {
	Save-Config $config
}