[CmdletBinding()]
param([switch] $showInterface)

Import-Module PowerHTML

. (Join-Path $PSScriptRoot '..\Helpers\Functions.ps1' -Resolve)

$interfaceSwitch = $(@{$true = '--passive'; $false = '--quiet' }[$showInterface.IsPresent])

$config = Get-Content (Join-Path $PSScriptRoot 'Config\config.json') | ConvertFrom-Json

# If the installed executable is not found
if (-not (Test-Path $config.InstalledExecutable -ErrorAction SilentlyContinue)) {
    $config.InstalledExecutable = Get-ChildItem C:\ -Recurse $config.InstalledExecutable `
        -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

    # If the executable is still not found, set it to empty string
    if (-not (Test-Path $config.InstalledExecutable -ErrorAction SilentlyContinue)) {
        $config.InstalledExecutable = ''
    }
}

# Get the release history HTML, to get the latest verison
$releasesHtml = Invoke-WebRequest $config.ReleasesUrl -UseBasicParsing | ConvertFrom-HTML

$latestVersion = $releasesHtml.SelectNodes('//table').Descendants('td') | Select-Object -First 1 -ExpandProperty InnerText
$latestBuildNumber = $releasesHtml.SelectNodes('//table').Descendants('td') | Select-Object -First 1 -Skip 2 -ExpandProperty InnerText

$localVersion = (Get-Item $config.InstalledExecutable).VersionInfo.ProductVersion
$localVersionNode = $releasesHtml.SelectNodes('//table').Descendants('td') | `
    Where-Object InnerText -eq $localVersion | `
    Select-Object -ExpandProperty ParentNode

$installedVersion = $localVersionNode.Descendants('td') | Select-Object -First 1 -ExpandProperty InnerText
$installedBuildNumber = $localVersionNode.Descendants('td') | Select-Object -First 1 -Skip 2 -ExpandProperty InnerText

# Add the latest version and installed version to the config
$config | Add-Member -NotePropertyName LatestVersion -NotePropertyValue $latestVersion
$config | Add-Member -NotePropertyName LatestBuildNumber -NotePropertyValue $latestBuildNumber
$config | Add-Member -NotePropertyName InstalledBuildNumber -NotePropertyValue $installedBuildNumber
$config | Add-Member -NotePropertyName InstalledVersion -NotePropertyValue $installedVersion

# Config has to be evaluated first as it's used
$config.InstallConfig = $ExecutionContext.InvokeCommand.ExpandString($config.InstallConfig)

$config.InstallArguments = $ExecutionContext.InvokeCommand.ExpandString($config.InstallArguments)
$config.InstallUpdateArguments = $ExecutionContext.InvokeCommand.ExpandString($config.InstallUpdateArguments)
$config.Installer = $ExecutionContext.InvokeCommand.ExpandString($config.Installer)
$config.InstallerUpdateArguments = $ExecutionContext.InvokeCommand.ExpandString($config.InstallerUpdateArguments)
$config.LayoutDirectory = $ExecutionContext.InvokeCommand.ExpandString($config.LayoutDirectory)
$config.LayoutDirectoryUpdateArguments = $ExecutionContext.InvokeCommand.ExpandString($config.LayoutDirectoryUpdateArguments)

if ($config.ProductKey) {
    $config.InstallationArguments += " --productKey '$($config.ProductKey)'"
}

# If the layout directory exists
if (Test-Path $config.LayoutDirectory -ErrorAction SilentlyContinue) {
    # Try to find the installer in the layout directory
    $config.Installer = Get-ChildItem $config.LayoutDirectory -File | `
        Where-Object Name -Match 'vs_(professional|enterprise|community)\.exe' | `
        Select-Object -ExpandProperty FullName
}

# If the installer was not found
if (-not (Test-Path $config.Installer -ErrorAction SilentlyContinue)) {
    # Get the download page HTML
    $downloadPageContent = Invoke-WebRequest $config.DownloadUrl -UseBasicParsing | Select-Object -ExpandProperty Content

    # Find the download link for the installer executable
    if ($downloadPageContent -match '(http.*?.exe)') {
        $config.DownloadUrl = $matches[0]
    }
}