[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.DownloadUrl = 'https://download.teamviewer.com/download/TeamViewer_Setup.exe'
$config.ReleasesUrl = 'http://www.filehorse.com/download-teamviewer/'
$config.VersionRegEx = '.TeamViewer ([0-9\.]+)'
$config.Executable = 'TeamViewer.exe'
$config.InstallDestination = ${env:ProgramFiles(x86)}
$config.InstallerArguments = '/S /norestart'
$config.DesktopLink = Join-Path $env:UserProfile 'Desktop\TeamViewer 14.lnk'

$config.LatestVersion = Get-VersionFromHtml $config.ReleasesUrl $config.VersionRegEx
$config.InstalledVersion = Get-MajorMinorBuildInstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
	Write-Output $config | Format-Table

	if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
		$config.Installer = Get-Installer $config.DownloadUrl

		Invoke-Installer $config.Installer $config.InstallerArguments

		Remove-Item $config.DesktopLink -ErrorAction SilentlyContinue
	}
}