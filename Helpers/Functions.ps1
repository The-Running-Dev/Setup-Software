function Get-VersionFromRedirectUrl($url, $regEx) {
    $downloadUrl = ((Get-WebURL -Url $url).ResponseUri).AbsoluteUri

    return @{
        Url     = $downloadUrl;
        Version = [regex]::match($downloadUrl, $regEx).Groups[1].Value
    }
}

function Get-VersionFromHtml($url, $regEx) {
    $pageContent = Invoke-WebRequest -Uri $url -UseBasicParsing

    return ([regex]::match($pageContent.Content, $regEx).Groups[1].Value)
}

function Get-InstalledVersion($searchPath, $executable) {
    $executablePath = Get-ChildItem $searchPath -Recurse `
        $executableName -ErrorAction SilentlyContinue | `
        Select-Object -First 1 -ExpandProperty FullName

    if ([System.IO.File]::Exists($executablePath)) {
        $installedVersion = Get-Item $executablePath | `
            Select-Object -ExpandProperty VersionInfo | `
            Select-Object -ExpandProperty ProductVersion

        return $installedVersion.TrimEnd('.0')
    }
}

function Get-Installer($downloadUrl) {
    $installer = Join-Path $env:Temp (Split-Path $downloadUrl -Leaf)

    (New-Object System.Net.WebClient).DownloadFile($downloadUrl, $installer)

    if ([System.IO.File]::Exists($installer)) {
        return $installer
    }
}

function Invoke-Installer($installer, $arguments) {
    if ([System.IO.File]::Exists($installer)) {
        Start-Process $installer $arguments -Wait
    }
}