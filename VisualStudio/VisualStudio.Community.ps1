$downloadUrl = 'https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16'
$configUrl = 'https://github.com/The-Running-Dev/Setup-Software/raw/master/VisualStudio/Config/.vsconfig.community'

$installerPath = Join-Path $env:Temp 'vs_community.exe'
$configPath = Join-Path $env:Temp '.vsconfig'

"
You are Installing Visual Studio Community With:

.NET Desktop Development
.NET Core Cross-Platform Development
ASP.NET and Web Development
Mobile Development with .NET
" | Write-Output

Read-Host "Hit Any Key to Continue..."

# Download the installer
"Downloading Installer '$downloadUrl' to '$installerPath'..." | Write-Output
(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $installerPath)

# Download the config file
"Downloading Config '$configUrl' to '$configPath'..." | Write-Output
(New-Object System.Net.WebClient).DownloadFile($configUrl, $configPath)

if ((Test-Path $installer) -and (Test-Path $configPath)) {
    "Running Installer '$installer'
    Arguments: --config ""$configPath"" --passive --norestart --wait" | Write-Output

    Start-Process `
        $installer `
        "--config ""$configPath"" --passive --norestart --wait" `
        -Wait
}