[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.ReleasesUrl = 'https://api.github.com/repos/PowerShell/PowerShell/releases'
$config.ExecutableName = 'pwsh.exe'
$config.InstallerArguments = 'D:\Temp\PowerShell'

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$releaseData = $jsonData | Where-Object prerelease -eq $true | Select-Object -first 1

$config.DownloadUrl = $releaseData | `
    Select-Object -ExpandProperty assets | `
    Where-Object name -match '-win-x64.zip' | `
    Select-Object -ExpandProperty browser_download_url

$config.LatestVersion = $releaseData.tag_name.TrimStart('v')
$config.InstalledVersion = Get-InstalledVersion $config.InstallerArguments $config.ExecutableName
$config.InstalledVersion = $config.InstalledVersion -replace '\sSHA.*', ''

if ($config.LatestVersion -ne $config.InstalledVersion) {
    if ($pscmdlet.ShouldProcess($config.Name, 'Downloading the Installer...')) {
        Write-Output "
Download Url: $($config.DownloadUrl)
Installed Version: $($config.InstalledVersion)
Latest Version: $($config.LatestVersion)
Releases Url: $($config.ReleasesUrl)

Getting the Installer..."

        $config.Installer = Get-Installer $config.DownloadUrl

        Write-Output "
Unzipping: $($config.Installer)
Destination: $($config.InstallerArguments)`n"

        Invoke-Unzip $config.Installer $config.InstallerArguments
    }
}
else {
    Write-Output "$($config.Name)...Up to Date`n"
}