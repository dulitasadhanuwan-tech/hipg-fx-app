# Creates a Windows Desktop shortcut for HIPG FX Rate App
$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [Environment]::GetFolderPath("Desktop")
if (-not $DesktopPath -or -not (Test-Path $DesktopPath)) {
    $DesktopPath = Join-Path $env:USERPROFILE "Desktop"
}
$ShortcutPath = Join-Path $DesktopPath "HIPG Official CBSL FX App.lnk"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) {
    $ScriptDir = "C:\Users\HIPG-FIN\Documents\HIPG FX APP"
}
$TargetBat = Join-Path $ScriptDir "run_app.bat"
$IconPath = Join-Path $ScriptDir "hipg_fx.ico"

$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetBat
$Shortcut.WorkingDirectory = $ScriptDir
$Shortcut.Description = "HIPG Finance Official CBSL Foreign Exchange Portal"
if (Test-Path $IconPath) {
    $Shortcut.IconLocation = $IconPath
}
$Shortcut.Save()

Write-Host "Created Desktop Shortcut: $ShortcutPath"
