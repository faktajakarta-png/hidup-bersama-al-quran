<#
.SYNOPSIS
    Skrip Otomatis Backup Ekosistem Proyek "Hidup Bersama Al-Qur'an" ke Cloud Drive & Lokal
.DESCRIPTION
    Menyalin struktur asli (4 Folder Pilar) dan membuat paket arsip .ZIP ke:
    - Google Drive (jika Google Drive for Desktop terpasang di G:\ atau folder User)
    - Microsoft OneDrive (sinkronisasi cloud otomatis)
    - Desktop Lokal
#>
param(
    [switch]$OpenDriveWeb
)

$ErrorActionPreference = 'Continue'
$dateStr = Get-Date -Format 'yyyy-MM-dd'
$folderName = "BACKUP_GDRIVE_HIDUP_BERSAMA_ALQURAN_$dateStr"

$targetRoots = @(
    "C:\Users\X250\Desktop",
    "C:\Users\X250\OneDrive"
)

# Deteksi otomatis Google Drive for Desktop jika terpasang
$gdriveCandidates = @(
    "G:\My Drive",
    "G:\Drive Saya",
    "$env:USERPROFILE\Google Drive",
    "$env:USERPROFILE\My Drive"
)
foreach ($g in $gdriveCandidates) {
    if (Test-Path $g) {
        $targetRoots += $g
        Write-Host "[INFO] Google Drive terdeteksi di: $g" -ForegroundColor Green
    }
}

$primaryDest = Join-Path $targetRoots[0] $folderName
Write-Host "=== MEMULAI BACKUP EKOSISTEM HIDUP BERSAMA AL-QUR'AN ($dateStr) ===" -ForegroundColor Cyan

New-Item -ItemType Directory -Path "$primaryDest\01 - Proyek Utama (Hidup Bersama Al-Qur'an)" -Force | Out-Null
New-Item -ItemType Directory -Path "$primaryDest\02 - Generator & Tools" -Force | Out-Null
New-Item -ItemType Directory -Path "$primaryDest\03 - Audio Tadabbur & Media" -Force | Out-Null
New-Item -ItemType Directory -Path "$primaryDest\04 - Antigravity Agent Skills (7 Lensa Framework)" -Force | Out-Null

Write-Host "1. Menyalin [01 - Proyek Utama (Hidup Bersama Al-Qur'an)]..."
robocopy "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an" "$primaryDest\01 - Proyek Utama (Hidup Bersama Al-Qur'an)" /MIR /XD .git /XF *.tmp ~$* *.lock /NFL /NDL /NJH /NJS | Out-Null

Write-Host "2. Menyalin [02 - Generator & Tools]..."
robocopy "C:\Users\X250\HidupBersamaAlQuran-Tools" "$primaryDest\02 - Generator & Tools" /MIR /NFL /NDL /NJH /NJS | Out-Null

Write-Host "3. Menyalin [03 - Audio Tadabbur & Media]..."
Get-ChildItem "C:\Users\X250\Downloads\*.m4a" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName "$primaryDest\03 - Audio Tadabbur & Media\" -Force
}
if (Test-Path "C:\Users\X250\Downloads\Video & Audio\当爱必须等待：古兰经2 235解读.mp4") {
    Copy-Item "C:\Users\X250\Downloads\Video & Audio\当爱必须等待：古兰经2 235解读.mp4" "$primaryDest\03 - Audio Tadabbur & Media\" -Force
}

Write-Host "4. Menyalin [04 - Antigravity Agent Skills (7 Lensa Framework)]..."
robocopy "C:\Users\X250\.agents\skills" "$primaryDest\04 - Antigravity Agent Skills (7 Lensa Framework)" /MIR /NFL /NDL /NJH /NJS | Out-Null

# Buat arsip ZIP menggunakan tar.exe (mendukung long path Windows)
$zipPath = Join-Path $targetRoots[0] "$folderName.zip"
Write-Host "5. Membuat paket arsip ZIP ($zipPath)..."
Push-Location $primaryDest
tar.exe -a -c -f $zipPath *
Pop-Location

# Sinkronisasi ke target lainnya (OneDrive & Google Drive jika ada)
for ($i = 1; $i -lt $targetRoots.Count; $i++) {
    $otherDest = Join-Path $targetRoots[$i] $folderName
    $otherZip  = Join-Path $targetRoots[$i] "$folderName.zip"
    Write-Host "6. Menyinkronkan folder & ZIP ke $($targetRoots[$i])..."
    robocopy $primaryDest $otherDest /MIR /NFL /NDL /NJH /NJS | Out-Null
    Copy-Item $zipPath $otherZip -Force
}

Write-Host "=== BACKUP SELESAI ===" -ForegroundColor Green
if ($OpenDriveWeb) {
    Start-Process "https://drive.google.com/drive/my-drive"
    Start-Process "explorer.exe" -ArgumentList "/select,`"$primaryDest`""
}
