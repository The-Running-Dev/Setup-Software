[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$config.LatestVersion = $jsonData | Select-Object -ExpandProperty productVersion
$config.LatestVersion = $config.LatestVersion.TrimEnd('.0')
$config.DownloadUrl = $jsonData | Select-Object -ExpandProperty url
$config.InstalledVersion = Get-MajorMinorBuildInstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output $config

    if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
        Get-Process $config.Process -ErrorAction SilentlyContinue | Stop-Process

        $config.Installer = Get-Installer $config.DownloadUrl

        Invoke-Unzip $config.Installer $config.InstallDestination
    }
}

if ($config.InstalledVersion) {
    Save-Config $config
}