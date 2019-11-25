$config = @{
    DownloadUrl        = '';
    Executable         = ''
    InstallDestination = '';
    InstalledVersion   = '';
    Installer          = '';
    InstallerArguments = '';
    LatestVersion      = '';
    Name               = Get-Item $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName
    ReleasesUrl        = '';
    VersionRegEx       = ''
}

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

function Get-MajorMinorBuildInstalledVersion($searchPath, $executable) {
    $versionInfo = Get-VersionInfo $searchPath $executable

    return "$($versionInfo.ProductMajorPart).$($versionInfo.ProductMinorPart).$($versionInfo.ProductBuildPart)"
}

function Get-MajorMinorInstalledVersion($searchPath, $executable) {
    $versionInfo = Get-VersionInfo $searchPath $executable

    return "$($versionInfo.ProductMajorPart).$($versionInfo.ProductMinorPart)"
}

function Get-VersionInfo($searchPath, $executable) {
    $executablePath = Get-ChildItem $searchPath -File -Recurse `
        $executable -ErrorAction SilentlyContinue | `
        Select-Object -First 1 -ExpandProperty FullName

    if ([System.IO.File]::Exists($executablePath)) {
        $versionInfo = Get-Item $executablePath | `
            Select-Object -ExpandProperty VersionInfo

        return $versionInfo
    }
}

function Get-Installer($downloadUrl) {
    $installer = Join-Path $env:Temp (Split-Path $downloadUrl -Leaf)

    # If file is not already downloaded
    if (-not [System.IO.File]::Exists($installer)) {
        (New-Object System.Net.WebClient).DownloadFile($downloadUrl, $installer)
    }

    if ([System.IO.File]::Exists($installer)) {
        return $installer
    }
}

function Invoke-Installer($installer, $arguments) {
    if ([System.IO.File]::Exists($installer)) {
        Start-Process $installer $arguments -Wait
    }
}

function Invoke-Unzip($archive, $destination, $clean = $false) {
    if ([System.IO.Directory]::Exists($destination) -and $clean) {
        Remove-Item -Recurse -Force "$destination\*"
    }

    if ([System.IO.File]::Exists($archive)) {
        Expand-Archive -Path $archive -DestinationPath $destination -Force

        Remove-Item $archive -ErrorAction SilentlyContinue
    }
}