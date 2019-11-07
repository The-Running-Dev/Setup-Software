$downloadUrl = 'https://downloads.slack-edge.com/releases_x64/SlackSetup.exe'
$releaseUrl = 'https://slack.com/downloads/windows'
$executableName = 'Slack.exe'
$versionRegEx = '.*Version ([\d]+\.[\d\.]+)'
$localExecutable = 'C:\Users\boyank\AppData\Local\slack\slack.exe'
$installerArguments = '/s'
$installerPath = Join-Path $env:Temp (Split-Path $downloadUrl -Leaf)

Clear-Host

if ($localExecutable -eq '') {
	$localExecutable = Get-ChildItem C:\ -Recurse $executableName `
		-ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}

$releasePage = Invoke-WebRequest -Uri $releaseUrl -UseBasicParsing -MaximumRedirection 1
$latestVersion = ([regex]::match($releasePage.Content, $versionRegEx).Groups[1].Value)

if (Test-Path $localExecutable) {
	$installedVersion = Get-Item $localExecutable | `
		Select-Object -ExpandProperty VersionInfo | `
		Select-Object -ExpandProperty ProductVersion
}

Write-Output "
Latest Version: $latestVersion
Installed Version: $installedVersion

Installer: $installerPath
"

if (-not (Test-Path $localExecutable) -or $latestVersion -ne $installedVersion) {
	Write-Output "Downloading $downloadUrl..."

	Invoke-WebRequest -UseBasicParsing $downloadUrl -OutFile $installerPath

	if (Test-Path $installerPath) {
		Write-Output "Installing $installerPath..."

		Start-Process $installerPath $installerArguments -Wait

		Get-ChildItem (Join-Path $env:UserProfile 'Desktop') 'Slack.lnk' | Remove-Item
	}
}