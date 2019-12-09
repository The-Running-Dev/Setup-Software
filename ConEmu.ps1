[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$releaseData = $jsonData | Sort-Object published_at -Descending | Select-Object -first 1

$config.DownloadUrl = $releaseData | `
    Select-Object -ExpandProperty assets | `
    Where-Object name -match '.7z' | `
    Select-Object -ExpandProperty browser_download_url

$config.LatestVersion = $releaseData.tag_name.TrimStart('v')
$versionInfo = Get-VersionInfo $config.InstallDestination $config.Executable
$config.InstalledVersion = $versionInfo.ProductVersion -replace '\sSHA.*', ''

if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output $config

    if ($pscmdlet.ShouldProcess($config.Name, 'Downloading and Installing...')) {
        $config.Installer = Get-Installer $config.DownloadUrl

        Invoke-Unzip $config.Installer $config.InstallDestination -clean $true
    }
}

if ($config.InstalledVersion) {
    Save-Config $config
}