[CmdletBinding(SupportsShouldProcess = $true)]
param()

. (Join-Path $PSScriptRoot 'Helpers\Functions.ps1')

$config.ReleasesUrl = 'https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/VERSION'
$config.ExecutableName = 'code.exe'
$config.InstallerArguments = 'D:\Temp\VSCode'

$jsonData = Invoke-RestMethod $config.ReleasesUrl
$config.LatestVersion = $jsonData | Select-Object -ExpandProperty productVersion
$config.LatestVersion = $config.LatestVersion.TrimEnd('.0')
$config.DownloadUrl = $jsonData | Select-Object -ExpandProperty url

$config.InstalledVersion = Get-InstalledVersion $config.InstallerArguments $config.ExecutableName

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