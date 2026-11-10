# Start 5 queue workers in background for Surah Ali 'Imran (1-200)
$targetScript = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\automation\run_queue_ali_imran.ps1"
for ($i = 1; $i -le 5; $i++) {
    $cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$targetScript`" -WorkerId $i"
    Write-Host "Launching Ali 'Imran Queue Worker $i..."
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmd } | Out-Null
    Start-Sleep -Seconds 7
}
Write-Host "All 5 Queue Workers for Surah Ali 'Imran launched successfully."
