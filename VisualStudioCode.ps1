[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.ReleasesUrl = 'https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/VERSION'
$config.Executable = 'code.exe'
$config.InstallDestination = 'D:\Temp\VSCode'

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$config.LatestVersion = $jsonData | Select-Object -ExpandProperty productVersion
$config.LatestVersion = $config.LatestVersion.TrimEnd('.0')
$config.DownloadUrl = $jsonData | Select-Object -ExpandProperty url

$config.InstalledVersion = Get-InstalledVersion $config.InstallDestination $config.Executable

if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output $config | Format-Table

    if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
        $config.Installer = Get-Installer $config.DownloadUrl

        Invoke-Unzip $config.Installer $config.InstallDestination
    }
}