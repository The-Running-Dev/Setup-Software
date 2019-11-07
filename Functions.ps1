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

function Get-Installer($config) {
    # config.LocalExecutable
    # config.LatestVersion
    # config.InstalledVersion
    # config.DownloadUrl

    $installer = Join-Path $env:Temp (Split-Path $config.DownloadUrl -Leaf)

    if (-not (Test-Path $config.LocalExecutable) `
            -or $config.LatestVersion -ne $config.InstalledVersion) {
        (New-Object System.Net.WebClient).DownloadFile($config.DownloadUrl, $installer)

        if (Test-Path $installer) {
            return $installer
        }
    }
}

function Invoke-Installer($installer, $arguments, $desktopLink) {
    if (Test-Path $installer -ErrorAction SilentlyContinue) {
        Start-Process $installer $arguments -Wait

        Get-ChildItem $desktopLink | Remove-Item -ErrorAction SilentlyContinue
    }
}