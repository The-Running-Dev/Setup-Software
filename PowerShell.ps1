[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.ReleasesUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
$config.Executable = 'pwsh.exe'
$config.InstallDestination = 'D:\Dev\Programs\Programming\PowerShell'

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$releaseData = $jsonData | Where-Object prerelease -eq $true | Select-Object -first 1

$config.DownloadUrl = $releaseData | `
    Select-Object -ExpandProperty assets | `
    Where-Object name -match '-win-x64.zip' | `
    Select-Object -ExpandProperty browser_download_url

$config.LatestVersion = $releaseData.tag_name.TrimStart('v')
$versionInfo = Get-VersionInfo $config.InstallDestination $config.Executable
$config.InstalledVersion = $versionInfo.ProductVersion -replace '\sSHA.*', ''

if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output $config | Format-Table

    if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
        $config.Installer = Get-Installer $config.DownloadUrl

        Invoke-Unzip $config.Installer $config.InstallDestination -clean $true
    }
}