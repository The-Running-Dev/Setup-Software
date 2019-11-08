[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch] $showInterface,
    [switch] $createLayout
)

$script = $MyInvocation.MyCommand.Name

# Import the config
. (Join-Path $PSScriptRoot 'config.ps1') -showInterface:$showInterface

# If the installer was not found
if (-not (Test-Path $config.Installer -ErrorAction SilentlyContinue)) {
    if ($pscmdlet.ShouldProcess($script, 'Downloading the Installer...')) {
        Write-Output "Downloading the Installer...
        $($config.DownloadUrl)
        $($config.Installer)"

        # Download the installer
        $config.Installer = Get-Installer $config.DownloadUrl
    }
}

Write-Output "
Latest Version: $($config.LatestVersion)
Latest Build: $($config.LatestBuildNumber)
Download Url: $($config.DownloadUrl)

Installed Version: $($config.InstalledVersion)
Installed Build: $($config.InstalledBuildNumber)
Installed Executable: $($config.InstalledExecutable)

Install Arguments: $($config.InstallArguments)
Install Config: $($config.InstallConfig)
Install Update Arguments: $($config.InstallUpdateArguments)

Installer: $($config.Installer)
Installer Update Arguments: $($config.InstallerUpdateArguments)
Installer Layout Directory: $($config.LayoutDirectory)
Installer Layout Update Arguments: $($config.LayoutDirectoryUpdateArguments)
"

# Update the installer if a newer version is found online
if ($config.LatestVersion -ne $config.InstalledVersion) {
    Write-Output "Newer Version Exists...`n"

    if ($pscmdlet.ShouldProcess($script, 'Updating the Installer...')) {
        Write-Output "Updating the Installer...
    $($config.Installer) $($config.InstallerUpdateArguments)`n"

        Start-Process $config.Installer $config.InstallerUpdateArguments -Wait
    }

    # If the layout directory exists, update it as well
    if (Test-Path $config.LayoutDirectory) {
        if ($pscmdlet.ShouldProcess($script, 'Updating the Local Layout...')) {
            Write-Output "Updating the Local Layout...
        $($config.Installer) $($config.LayoutDirectoryUpdateArguments)`n"

            Start-Process $config.Installer $config.LayoutDirectoryUpdateArguments -Wait
        }

        if ($pscmdlet.ShouldProcess($script, 'Removing Outdated Packages...')) {
            Write-Output "
        Removing Outdated Packages...`n"

            Get-ChildItem -Directory $config.LayoutDirectory | `
                Group-Object { $_.name -replace ',version=[0-9\.]+$', '' } | `
                Where-Object Count -gt 1 | `
                ForEach-Object { $_.Group | Select-Object -First 1 } | `
                Remove-Item -Recurse
        }
    }
}

if (-not $createLayout) {
    # If the installed executable does not exist, this is a new install
    if (-not (Test-Path $config.InstalledExecutable -ErrorAction SilentlyContinue)) {
        if ($pscmdlet.ShouldProcess($script, 'Installing...')) {
            Write-Output "Installing...
        $($config.InstallArguments)`n"

            Start-Process $config.Installer $config.InstallArguments -Wait
        }
    }
    elseif ($config.LatestVersion -ne $config.InstalledVersion) {
        if ($pscmdlet.ShouldProcess($script, 'Updating Installed Instance...')) {
            Write-Output "Updating Installed Instance...
        $($config.Installer) $($config.InstallUpdateArguments)`n"

            Start-Process $config.Installer $config.InstallUpdateArguments -Wait
        }
    }
    else {
        Write-Output "$($script)...Up to Date`n"
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

        if ($pscmdlet.ShouldProcess($script, 'Creating/Updating Local Layout...')) {
            Start-Process $config.Installer $config.LayoutDirectoryUpdateArguments -Wait
        }
    }
}