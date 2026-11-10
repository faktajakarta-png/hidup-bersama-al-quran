@echo off
title Auto-Resume Pipeline 5 Workers - Hidup Bersama Al-Qur'an
echo =========================================================================
echo    MELANJUTKAN PIPELINE 5 WORKER PARALEL (SURAH AL-BAQARAH 1-286)
echo =========================================================================
echo Sistem mendeteksi berkas yang sudah ada dan otomatis melanjutkan sisa ayat.
echo.

cd /d "C:\Users\X250"

start "Worker 1: Blok 2 (Ayat 21-39)" powershell -NoExit -ExecutionPolicy Bypass -File "C:\Users\X250\.gemini\antigravity-cli\brain\a9218d9d-55a1-459c-8f90-66152b9a940a\scratch\run_block.ps1" -Start 21 -End 39
start "Worker 2: Blok 3A (Ayat 40-70)" powershell -NoExit -ExecutionPolicy Bypass -File "C:\Users\X250\.gemini\antigravity-cli\brain\a9218d9d-55a1-459c-8f90-66152b9a940a\scratch\run_worker2.ps1"
start "Worker 3: Blok 3B (Ayat 71-103)" powershell -NoExit -ExecutionPolicy Bypass -File "C:\Users\X250\.gemini\antigravity-cli\brain\a9218d9d-55a1-459c-8f90-66152b9a940a\scratch\run_worker3.ps1"
start "Worker 4: Blok 4 (Ayat 236-252)" powershell -NoExit -ExecutionPolicy Bypass -File "C:\Users\X250\.gemini\antigravity-cli\brain\a9218d9d-55a1-459c-8f90-66152b9a940a\scratch\run_worker4.ps1"
start "Worker 5: Blok 5 (Ayat 253-286)" powershell -NoExit -ExecutionPolicy Bypass -File "C:\Users\X250\.gemini\antigravity-cli\brain\a9218d9d-55a1-459c-8f90-66152b9a940a\scratch\run_worker5.ps1"

echo 5 Worker Paralel berhasil diluncurkan! Jendela ini dapat Anda tutup.
pause
