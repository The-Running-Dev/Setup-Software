$downloadUrl = 'https://download.teamviewer.com/download/TeamViewer_Setup.exe'
$releaseUrl = 'http://www.filehorse.com/download-teamviewer/'
$executableName = 'TeamViewer.exe'
$versionRegEx = '.TeamViewer ([0-9\.]+)'
$localExecutable = 'C:\Program Files (x86)\TeamViewer\TeamViewer.exe'
$installerArguments = '/S /norestart'
$installerPath = Join-Path $env:Temp (Split-Path $downloadUrl -Leaf)

Clear-Host

if ($localExecutable -eq '') {
	$localExecutable = Get-ChildItem C:\ -Recurse $executableName `
		-ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
}

$releasePage = Invoke-WebRequest -Uri $releaseUrl -UseBasicParsing
$latestVersion = ([regex]::match($releasePage.Content, $versionRegEx).Groups[1].Value)

if (Test-Path $localExecutable) {
	$installedVersion = Get-Item $localExecutable | `
		Select-Object -ExpandProperty VersionInfo | `
		Select-Object -ExpandProperty ProductVersion

	$installedVersion = $installedVersion.TrimEnd('.0')
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

		Get-ChildItem (Join-Path $env:UserProfile 'Desktop') 'TeamViewer.lnk' | Remove-Item
	}
}