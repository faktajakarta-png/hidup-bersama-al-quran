<#
.SYNOPSIS
    Autonomous Pipeline Runner v2.0 (Gold-Standard Edition) - Proyek Hidup Bersama Al-Qur'an (Kerangka 7 Lensa)
.DESCRIPTION
    Skrip orkestrasi otomatis untuk memproduksi kajian tafsir ensiklopedis komprehensif 114 Surah
    berstandar Gold-Standard v2.0 menggunakan Antigravity AI Engine (agy.exe).
    Mendukung mode Overwrite untuk pembaruan kualitas menyeluruh dari awal (Al-Fatihah, Al-Baqarah Blok 1-5, dst.).
#>

param(
    [string]$SurahNumber = "002",
    [string]$SurahName = "Al-Baqarah",
    [string]$BlockFolder = "02 - Surah Al-Baqarah\Blok 1 (Ayat 1-20)",
    [int]$StartAyat = 1,
    [int]$EndAyat = 20,
    [bool]$OverwriteExisting = $true,
    [string]$Model = "gemini-3.8-flash-high",
    [string]$LogFileName = ""
)

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$RootPath = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an"
$AgyPath = "C:\Users\X250\AppData\Local\agy\bin\agy.exe"
$TemplateFile = "$RootPath\01 - Surah Al-Fatihah\001-001 - QS. Al-Fatihah Ayat 1.html"

if ([string]::IsNullOrWhiteSpace($LogFileName)) {
    $LogFile = "$RootPath\automation\runner.log"
} else {
    $LogFile = "$RootPath\automation\$LogFileName"
}

function Log-Message([string]$msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] $msg"
    Write-Host $line
    for ($i = 0; $i -lt 5; $i++) {
        try {
            Add-Content -Path $LogFile -Value $line -Encoding UTF8 -ErrorAction Stop
            break
        } catch {
            Start-Sleep -Milliseconds 150
        }
    }
}

Log-Message "=== MEMULAI QURAN AUTOMATION PIPELINE v2.0 (GOLD-STANDARD) ==="
Log-Message "Surah: $SurahNumber ($SurahName) | Folder: $BlockFolder | Ayat: $StartAyat s/d $EndAyat | Overwrite: $OverwriteExisting"

if (-not (Test-Path $AgyPath)) {
    Log-Message "ERROR: agy.exe tidak ditemukan di $AgyPath"
    exit 1
}

$TargetDir = "$RootPath\$BlockFolder"
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

for ($ayat = $StartAyat; $ayat -le $EndAyat; $ayat++) {
    $ayatPadded = "{0:D3}" -f $ayat
    $fileName = "$SurahNumber-$ayatPadded - QS. $SurahName Ayat $ayat.html"
    $filePath = "$TargetDir\$fileName"

    if ((-not $OverwriteExisting) -and (Test-Path $filePath)) {
        $size = (Get-Item $filePath).Length
        if ($size -gt 28000) {
            Log-Message "SKIP: Ayat $ayat sudah memenuhi standar Gold-Standard ($size bytes) -> $fileName"
            continue
        }
    }

    Log-Message "GENERATING (GOLD-STANDARD): QS. $SurahName Ayat $ayat..."
    $prompt = @"
Tulis kajian ensiklopedis lengkap QS. $SurahName [$SurahNumber]: Ayat $ayat berstandar Kerangka 7 Lensa v2.0 (Gold-Standard) format HTML mandiri persis seperti Master Template:
'$TemplateFile'.
Tuliskan langsung seluruh kode HTML lengkap mulai dari <!DOCTYPE html> sampai </html> yang memuat:
1. Top-Nav, Badge Meta-Informasi (Surah, Makkiyah/Madaniyah, Blok/Klaster, Jumlah Kata & Huruf), Header Dokumen (Surah, Transliterasi Akademis, Judul Tematik Tajam, Subjudul), dan Daftar Isi 7 Lensa (.lens-toc)
2. Lensa 1: Teks (Nash Rasm Utsmani berharakat lengkap, Terjemahan Presisi + Catatan Nuansa Terjemahan, Tabel Analisis Lafaz demi Lafaz: Tajwid, Makharij/Sifat Huruf & Variasi Qira'at 10 Imam Mutawatirah beserta implikasinya, serta Takhrij Asbabun Nuzul & Hadits Sahih Penjelas dalam .hadith-box)
3. Lensa 2: Bahasa (Analisis Etimologi & Medan Semantik Akar Kata, Tabel Morfosintaksis/Sharaf & I'rab Kata demi Kata lengkap dengan Ta'alluq & Mahallul-Jumlah, serta Kajian Balaghah Ma'ani, Bayan, Badi' & I'jaz Fonetik)
4. Lensa 3: Konteks (Integrasi Metodologi 2S & 1L: Sibaq, Siyaq, Lihaq + Rekonstruksi Sosio-Historis & Kosmologi Peradaban)
5. Lensa 4: Tafsir Komparatif Lintas Generasi & Mazhab (6 Ulama Besar dalam .tafsir-quote: At-Tabari, Ibnu Katsir, Al-Qurthubi, Az-Zamakhsyari/Ar-Razi, M. Quraish Shihab, Buya Hamka & Kemenag RI + Tabel Matriks Komparasi Ijma' & Ikhtilaf Mufassirin)
6. Lensa 5: Kognisi (Sintesis Sistemik, Neuropsikologi, Epistemologi & Arsitektur Jiwa / Tazkiyatun Nafs)
7. Lensa 6: Realitas (Fenomenologi Kontemporer, Kritik Peradaban & Solusi Peradaban Abad ke-21)
8. Lensa 7: Praksis (Tepat 3 Tindakan Nyata Terukur dalam .highlight-box, Tepat 3 Pertanyaan Refleksi Batin dalam .reflection-box, Munajat & Doa Tadabbur Ayat dalam .doa-box, serta .footer-nav)
Berikan HANYA kode HTML murni tanpa awalan atau akhiran markdown.
"@

    try {
        $rawOutput = & $AgyPath -p $prompt --model $Model --effort high --dangerously-skip-permissions 2>&1
        $rawString = $rawOutput -join "`n"

        if ($rawString -match "(?s)(<!DOCTYPE html>.*?</html>)") {
            $htmlContent = $matches[1].Trim()
            [System.IO.File]::WriteAllText($filePath, $htmlContent, [System.Text.Encoding]::UTF8)
            Log-Message "SUCCESS: Berhasil menulis $fileName ($([System.IO.FileInfo]::new($filePath).Length) bytes)"
        } elseif ($rawString -match "(?s)(<html.*?>.*?</html>)") {
            $htmlContent = "<!DOCTYPE html>`n" + $matches[1].Trim()
            [System.IO.File]::WriteAllText($filePath, $htmlContent, [System.Text.Encoding]::UTF8)
            Log-Message "SUCCESS: Berhasil menulis $fileName ($([System.IO.FileInfo]::new($filePath).Length) bytes)"
        } else {
            Log-Message "WARNING: Output untuk Ayat $ayat tidak memiliki tag HTML valid. Raw length: $($rawString.Length)"
        }
    } catch {
        Log-Message "ERROR pada Ayat $ayat : $_"
    }

    Start-Sleep -Seconds 2
}

Log-Message "=== PIPELINE BATCH SELESAI ==="
