@echo off
title Queue Runner v3.0 - Hidup Bersama Al-Qur'an (Ali 'Imran 1-200)
echo =========================================================================
echo    QUEUE RUNNER v3.0 - 5 WORKER PARALEL (SURAH ALI 'IMRAN 1-200)
echo    Otomatisasi Kerangka 7 Lensa Gold-Standard v2.0
echo    Rotasi model + tidur otomatis saat kuota habis. Aman dijalankan ulang.
echo =========================================================================
cd /d "C:\Users\X250"
for /L %%i in (1,1,5) do (
  start "Ali Imran Worker %%i" /min powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\automation\run_queue_ali_imran.ps1" -WorkerId %%i
  timeout /t 7 /nobreak >nul
)
echo 5 worker Surah Ali 'Imran diluncurkan. Pantau log: automation\queue_worker_ali_imran_1..5.log
pause
