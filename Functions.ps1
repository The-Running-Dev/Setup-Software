function Get-LatestVersion($url, $regEx) {
    # config.ReleaseUrl
    # config.VersionRegEx

    $releasePage = Invoke-WebRequest -Uri $url -UseBasicParsing -MaximumRedirection 1
    $version = ([regex]::match($releasePage.Content, $regEx).Groups[1].Value)

    return $version
}

function Get-InstalledVersion($executable) {
    if (Test-Path $executable) {
        $version = Get-Item $executable | `
            Select-Object -ExpandProperty VersionInfo | `
            Select-Object -ExpandProperty ProductVersion

        $version = $version.TrimEnd('.0')
    }

    return $version
}

function Get-Installer($downloadUrl) {
    $installer = Join-Path $env:Temp (Split-Path $downloadUrl -Leaf)

    (New-Object System.Net.WebClient).DownloadFile($downloadUrl, $installer)

    if (Test-Path $installer) {
        return $installer
    }
}

function Invoke-Installer($installer, $arguments, $desktopLink) {
    if (Test-Path $installer -ErrorAction SilentlyContinue) {
        Start-Process $installer $arguments -Wait

        Get-ChildItem $desktopLink -ErrorAction SilentlyContinue | Remove-Item
    }
}