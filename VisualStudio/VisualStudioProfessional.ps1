$downloadUrl = 'https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16'
$configUrl = 'https://'

$installerPath = Join-Path $env:Temp 'vs_community.exe'
$configPath = Join-Path $env:Temp '.vsconfig'

# Download the installer
(New-Object System.Net.WebClient).DownloadFile($downloadUrl, $installerPath)

# Download the config file
(New-Object System.Net.WebClient).DownloadFile($configUrl, $configPath)

if ((Test-Path $installer) -and (Test-Path $configPath)) {
    Start-Process `
        $installer `
        "--config \"$configPath\" --passive --norestart --wait" `
        -Wait
}