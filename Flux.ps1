[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.DownloadUrl = 'https://justgetflux.com/flux-setup.exe'
$config.ReleasesUrl = 'http://www.filehorse.com/download-flux/'
$config.VersionRegEx = '.*f.lux ([0-9\.]+)'
$config.Executable = 'flux.exe'
$config.InstallDestination = Join-Path $env:UserProfile 'AppData\Local'
$config.InstallerArguments = '/S'
$config.DesktopLink = Join-Path $env:UserProfile 'Desktop\Flux.lnk'

$config.LatestVersion = Get-VersionFromHtml $config.ReleasesUrl $config.VersionRegEx
$config.InstalledVersion = Get-MajorMinorInstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config | Format-Table

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments

		Remove-Item $config.DesktopLink -ErrorAction SilentlyContinue
	}
}