[CmdletBinding(SupportsShouldProcess = $true)]
param()

$script = $MyInvocation.MyCommand.Name

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$url = 'https://www.binaryfortress.com/Data/Download/?package=clipboardfusion&log=104'
$versionRegEx = 'ClipboardFusionSetup-([0-9\.\-]+)\.exe$'
$executableName = 'ClipboardFusion.exe'
$installerArguments = '/VERYSILENT /LAUNCHAFTER=0'

$latestVersion = Get-VersionFromRedirectUrl $url $versionRegEx
$installedVersion = Get-InstalledVersion ${env:ProgramFiles(x86)} $executableName

if ($latestVersion.Version -ne $installedVersion) {
	if ($pscmdlet.ShouldProcess($script, 'Downloading the Installer...')) {
		$installer = Get-Installer $latestVersion.Url

		Write-Output "
Latest Version: $($latestVersion.Version)
Installed Version: $installedVersion

Installer: $installer
Installing...`n"

		Invoke-Installer $installer $installerArguments
	}
}
else {
	Write-Output "$($script)...Up to Date`n"
}