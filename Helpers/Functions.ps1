$configDirName = 'Setup-Software'
$repositoryConfigDir = 'Config'

$repositoryDirectory = Get-Item $MyInvocation.PSCommandPath | Select-Object -ExpandProperty Directory
$repositoryConfigDirectory = Join-Path $repositoryDirectory $repositoryConfigDir
$configFile = "$(Get-Item $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName).json"

$globalConfig = @{
    Settings           = Join-Path (Join-Path $env:AppData $configDirName) $configFile
    SettingsDirectory  = Join-Path $env:AppData $configDirName
    RepositorySettings = Join-Path $repositoryConfigDirectory $configFile
}

$config = @{
    DownloadUrl        = '';
    Executable         = '';
    InstallDestination = '';
    InstalledVersion   = '';
    Installer          = '';
    InstallerArguments = '';
    LatestVersion      = '';
    LastUpdateCheck    = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
    Name               = Get-Item $MyInvocation.PSCommandPath | Select-Object -ExpandProperty BaseName;
    Process            = '';
    ReleasesUrl        = '';
    VersionRegEx       = '';
}

New-Item -ItemType Directory $globalConfig.SettingsDirectory -ErrorAction SilentlyContinue | Out-Null

if (-not (Test-Path $globalConfig.Settings -ErrorAction SilentlyContinue)) {
    $config = Get-Content $globalConfig.RepositorySettings | ConvertFrom-Json

    $config.PSobject.Properties | ForEach-Object {
        $config.$($_.Name) = $ExecutionContext.InvokeCommand.ExpandString($_.Value)
    }
}
else {
    $config = Get-Content $globalConfig.Settings | ConvertFrom-Json

    $config.PSobject.Properties | ForEach-Object {
        $config.$($_.Name) = $ExecutionContext.InvokeCommand.ExpandString($_.Value)
    }
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

    if ($versionInfo) {
        return "$($versionInfo.ProductMajorPart).$($versionInfo.ProductMinorPart).$($versionInfo.ProductBuildPart)"
    }
    else {
        return ''
    }
}

function Get-MajorMinorInstalledVersion($searchPath, $executable) {
    $versionInfo = Get-VersionInfo $searchPath $executable

    if ($versionInfo) {
        return "$($versionInfo.ProductMajorPart).$($versionInfo.ProductMinorPart)"
    }
    else {
        return ''
    }
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
        Expand-Archive -Path $archive -OutputPath $destination -Force

        Remove-Item $archive -ErrorAction SilentlyContinue
    }
}

function Save-Config($config) {
    $date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    if (-not $config.LastUpdateCheck) {
        $config | Add-Member -NotePropertyName LastUpdateCheck -NotePropertyValue $date
    }
    else {
        $config.LastUpdateCheck = $date
    }

    $config.InstalledVersion = $config.LatestVersion

    Set-Content -Path $globalConfig.Settings -Value ($config | ConvertTo-Json)
}