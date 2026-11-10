# Start 5 queue workers in background
$targetScript = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\automation\run_queue.ps1"
for ($i = 1; $i -le 5; $i++) {
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$targetScript`" -WorkerId $i"
    Write-Host "Launching Queue Worker $i..."
    Start-Process -FilePath "powershell.exe" -ArgumentList $arg -WindowStyle Minimized
    Start-Sleep -Seconds 7
}
Write-Host "All 5 Queue Workers launched."
