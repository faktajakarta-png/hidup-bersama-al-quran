@echo off
title Queue Runner v3.0 - Hidup Bersama Al-Qur'an (Al-Baqarah 1-286)
echo =========================================================================
echo    QUEUE RUNNER v3.0 - 5 WORKER PARALEL (SURAH AL-BAQARAH 1-286)
echo    Otomatis: isi ayat yang hilang, lalu upgrade berkas v1.0 ke v2.0.
echo    Rotasi model + tidur otomatis saat kuota habis. Aman dijalankan ulang.
echo =========================================================================
cd /d "C:\Users\X250"
for /L %%i in (1,1,5) do (
  start "Queue Worker %%i" /min powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\automation\run_queue.ps1" -WorkerId %%i
  timeout /t 7 /nobreak >nul
)
echo 5 worker diluncurkan. Pantau log: automation\queue_worker1..5.log
pause
