[CmdletBinding()]
param(
    [switch] $showInterface,
    [switch] $createLayout
)

# Import the config
. (Join-Path $PSScriptRoot 'config.ps1') -showInterface:$showInterface

# If the installer was not found
if (-not (Test-Path $config.Installer -ErrorAction SilentlyContinue)) {
    # Download the installer
    $config.Installer = Get-Installer $config.DownloadUrl

    Write-Output "Downloaded the Installer...
    $($config.Installer)"
}

Write-Output "
Latest Version: $($config.LatestVersion)
Latest Build: $($config.LatestBuildNumber)
Download Url: $($config.DownloadUrl)

Installed Version: $($config.InstalledVersion)
Installed Build: $($config.InstalledBuildNumber)

Install Arguments: $($config.InstallArguments)
Install Config: $($config.InstallConfig)
Install Executable: $($config.InstallExecutable)
Install Update Arguments: $($config.InstallUpdateArguments)

Installer: $($config.Installer)
Installer Update Arguments: $($config.InstallerUpdateArguments)
Installer Layout Directory: $($config.LayoutDirectory)
Installer Layout Update Arguments: $($config.LayoutDirectoryUpdateArguments)
"

# Update the installer if a newer version is found online
if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output "Newer Version Exists...`n"

    Write-Output "Updating the Installer...
    $($config.Installer) $($config.InstallerUpdateArguments)`n"

    #Start-Process $config.Installer $config.InstallerUpdateArguments -Wait

    # If the layout directory exists, update it as well
    if (Test-Path $config.LayoutDirectory) {
        Write-Output "Updating the Local Layout...
        $($config.Installer) $($config.LayoutDirectoryUpdateArguments)`n"

        #Start-Process $config.Installer $config.LayoutDirectoryUpdateArguments -Wait

        Write-Output "Removing Outdated Packages...`n"

        Get-ChildItem -Directory $config.LayoutDirectory | `
            Group-Object { $_.name -replace ',version=[0-9\.]+$', '' } | `
            Where-Object Count -gt 1 | `
            ForEach-Object { $_.Group | Select-Object -First 1 } | `
            Remove-Item -Recurse
    }
}


if (-not $createLayout) {
    # If the install executable does not exist, this is a new install
    if (-not (Test-Path $config.InstallExecutable -ErrorAction SilentlyContinue)) {
        Write-Output "Installing...
    $($config.InstallationArguments)`n"

        #Start-Process $config.InstallExecutable $config.InstallationArguments -Wait
    }
    elseif ($latestVersion -ne $installedVersion) {
        Write-Output "Updating Installed Instance...
    $($config.InstallExecutable) $($config.UpdateArguments)`n"

        #Start-Process $config.InstallExecutable $config.UpdateArguments -Wait
    }
    else {
        Write-Output "Your Are Up to Date...`n"
    }
}
else {
    # Create the layout directory if it does not exist
    if (-not (Test-Path $config.LayoutDirectory)) {
        New-Item -ItemType Directory $config.LayoutDirectory
    }

    if (Test-Path $config.LayoutDirectory) {
        Write-Output "Creating/Updating Local Layout...
        $($config.Installer) $($config.LayoutDirectoryUpdateArguments)`n"

        #Start-Process $config.Installer $config.LayoutDirectoryUpdateArguments -Wait
    }
}