[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.ReleasesUrl = 'https://www.binaryfortress.com/Data/Download/?package=clipboardfusion&log=104'
$config.VersionRegEx = 'ClipboardFusionSetup-([0-9\.\-]+)\.exe$'
$config.Executable = 'ClipboardFusion.exe'
$config.InstallerArguments = '/VERYSILENT /LAUNCHAFTER=0'
$config.InstallDestination = ${env:ProgramFiles(x86)}

$versionData = Get-VersionFromRedirectUrl $config.ReleasesUrl $config.VersionRegEx
$config.LatestVersion = $versionData.Version
$config.DownloadUrl = $versionData.Url

$config.InstalledVersion = Get-InstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config | Format-Table

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments
	}
}