<#
.SYNOPSIS
    Queue Runner v3.0 (Resilient) - Proyek Hidup Bersama Al-Qur'an (Kerangka 7 Lensa Gold-Standard v2.0)
.DESCRIPTION
    Worker paralel berbasis antrean untuk menuntaskan Surah Al-Baqarah (1-286):
      - Prioritas 1: ayat yang belum ada berkasnya.
      - Prioritas 2: berkas v1.0 lama yang belum memenuhi Gold-Standard v2.0 (di-upgrade, v1.0 dicadangkan).
    Fitur: klaim ayat via lock-file (aman untuk banyak worker), rotasi model saat kuota habis (429),
    tidur otomatis sampai kuota reset, validasi kualitas sebelum menulis, retry terbatas per ayat.
    Jalankan beberapa instance sekaligus dengan -WorkerId berbeda.
#>
param(
    [int]$WorkerId = 1,
    [string[]]$Models = @('gemini-3.8-flash-high', 'gemini-4-argon-high', 'claude-sonnet-5-5-high'),
    [int]$MaxAttemptsPerAyat = 4,
    [int]$From = 1,
    [int]$To = 286,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$RootPath   = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an"
$SurahDir   = "$RootPath\02 - Surah Al-Baqarah"
$AutoDir    = "$RootPath\automation"
$LockDir    = "$AutoDir\locks"
$BackupDir  = "$AutoDir\backup_v1"
$StateFile  = "$AutoDir\quota_state.json"
$AttemptDir = "$AutoDir\attempts"
$AgyPath    = "C:\Users\X250\AppData\Local\agy\bin\agy.exe"
$TemplateFile = "$RootPath\02 - Surah Al-Baqarah\Blok 1 (Ayat 1-20)\002-002 - QS. Al-Baqarah Ayat 2.html"
$LogFile    = "$AutoDir\queue_worker$WorkerId.log"
foreach ($d in $LockDir, $BackupDir, $AttemptDir) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null } }

$Blocks = @(
    @{ Name = 'Blok 1 (Ayat 1-20)';    S = 1;   E = 20;  Theme = 'Tipologi Manusia di Hadapan Petunjuk (Muttaqin, Kafir, Munafik)' },
    @{ Name = 'Blok 2 (Ayat 21-39)';   S = 21;  E = 39;  Theme = 'Seruan Universal Ibadah & Mandat Kekhalifahan Adam AS' },
    @{ Name = 'Blok 3 (Ayat 40-141)';  S = 40;  E = 141; Theme = 'Sejarah, Kritik, & Dialektika Bani Israil + Kiblat Ibrahim AS' },
    @{ Name = 'Blok 4 (Ayat 142-252)'; S = 142; E = 252; Theme = 'Kemandirian Umat, Syariat Ibadah, Jihad, & Hukum Keluarga' },
    @{ Name = 'Blok 5 (Ayat 253-286)'; S = 253; E = 286; Theme = 'Ayat Kursi, Tauhid Finansial (Infaq vs Riba), & Penutup Agung' }
)
function Get-Block([int]$n) { foreach ($b in $Blocks) { if ($n -ge $b.S -and $n -le $b.E) { return $b } } }
function Get-FileName([int]$n) { "002-{0:D3} - QS. Al-Baqarah Ayat {1}.html" -f $n, $n }
function Get-FilePath([int]$n) { "$SurahDir\$((Get-Block $n).Name)\$(Get-FileName $n)" }
function Get-RelLink([int]$from, [int]$to) {
    if ($to -lt 1 -or $to -gt 286) { return $null }
    $bf = (Get-Block $from).Name; $bt = (Get-Block $to).Name
    if ($bf -eq $bt) { return (Get-FileName $to) } else { return "../$bt/$(Get-FileName $to)" }
}

function Log([string]$msg) {
    $line = "[{0}] [W{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $WorkerId, $msg
    Write-Host $line
    for ($i = 0; $i -lt 5; $i++) { try { Add-Content -Path $LogFile -Value $line -Encoding UTF8 -ErrorAction Stop; break } catch { Start-Sleep -Milliseconds 150 } }
}

function Test-Quality([string]$raw, [int]$n) {
    $probs = @()
    $bytes = [Text.Encoding]::UTF8.GetByteCount($raw)
    if ($bytes -lt 40000) { $probs += "small($bytes)" }
    if (([regex]'[\u00C3\u00C2\u00D8\u00D9][\u0080-\u00BF]').Matches($raw).Count -gt 20) { $probs += 'mojibake' }
    if (([regex]'[\u0600-\u06FF]').Matches($raw).Count -lt 200) { $probs += 'arabic' }
    for ($l = 1; $l -le 7; $l++) { if ($raw -notmatch "(?i)lensa[\s-]*$l") { $probs += "lensa$l" } }
    foreach ($s in 'Tabari|Thabari', 'Katsir|Kathir', 'Qurthubi|Qurtubi', 'Razi|Zamakhsyari', 'Hamka', 'Shihab') { if ($raw -notmatch "(?i)$s") { $probs += "mufassir:$s" } }
    foreach ($c in 'highlight-box', 'reflection-box', 'doa-box', 'lens-toc', 'top-nav', 'footer-nav') { if ($raw -notmatch $c) { $probs += $c } }
    if ($raw -notmatch '</html>\s*$') { $probs += 'noEnd' }
    if ($raw -notmatch "(?i)(Ayat|2\s*:\s*|\[2\]\s*:\s*)\s*$n\b") { $probs += 'ayatRef' }
    return , $probs
}

function Test-NeedsWork([int]$n) {
    $p = Get-FilePath $n
    if (-not (Test-Path $p)) { return 'missing' }
    $raw = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
    $probs = Test-Quality $raw $n
    if ($probs.Count -gt 0) { return 'upgrade' }
    return $null
}

function Get-QuotaState {
    for ($i = 0; $i -lt 5; $i++) {
        try { if (Test-Path $StateFile) { return (Get-Content $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json) } else { return [pscustomobject]@{} } } catch { Start-Sleep -Milliseconds 200 }
    }
    return [pscustomobject]@{}
}
function Set-ModelBlocked([string]$model, [datetime]$until) {
    $st = Get-QuotaState
    $st | Add-Member -NotePropertyName $model -NotePropertyValue ($until.ToString('o')) -Force
    for ($i = 0; $i -lt 5; $i++) { try { ($st | ConvertTo-Json) | Set-Content -Path $StateFile -Encoding UTF8 -ErrorAction Stop; break } catch { Start-Sleep -Milliseconds 200 } }
}
function Get-AvailableModel {
    $st = Get-QuotaState
    $now = Get-Date
    foreach ($m in $Models) {
        $u = $st.$m
        if (-not $u -or ([datetime]$u) -le $now) { return $m }
    }
    return $null
}
function Get-EarliestReset {
    $st = Get-QuotaState
    $min = $null
    foreach ($m in $Models) { $u = $st.$m; if ($u) { $d = [datetime]$u; if (-not $min -or $d -lt $min) { $min = $d } } }
    return $min
}

function Get-Attempts([int]$n) { $f = "$AttemptDir\$n.txt"; if (Test-Path $f) { return [int](Get-Content $f -Raw) } else { return 0 } }
function Add-Attempt([int]$n) { $c = (Get-Attempts $n) + 1; Set-Content -Path "$AttemptDir\$n.txt" -Value $c; return $c }

function Claim-Next {
    $order = @()
    $missing = @(); $upgrade = @()
    for ($n = $From; $n -le $To; $n++) {
        $need = Test-NeedsWork $n
        if ($need -eq 'missing') { $missing += $n } elseif ($need -eq 'upgrade') { $upgrade += $n }
    }
    $order = $missing + $upgrade
    foreach ($n in $order) {
        if ((Get-Attempts $n) -ge $MaxAttemptsPerAyat) { continue }
        $lock = "$LockDir\$n.lock"
        if (Test-Path $lock) {
            # Stale lock (> 45 menit) dianggap mati
            if (((Get-Date) - (Get-Item $lock).LastWriteTime).TotalMinutes -gt 45) { Remove-Item $lock -Force -ErrorAction SilentlyContinue } else { continue }
        }
        try {
            $fs = [IO.File]::Open($lock, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
            $w = New-Object IO.StreamWriter($fs); $w.Write("W$WorkerId $(Get-Date -Format o)"); $w.Close()
            return @{ N = $n; Kind = (Test-NeedsWork $n) }
        } catch { continue }
    }
    return $null
}

function Build-Prompt([int]$n, [string]$kind) {
    $b = Get-Block $n
    $prev = Get-RelLink $n ($n - 1); $next = Get-RelLink $n ($n + 1)
    if (-not $prev) { $prev = '../../01 - Surah Al-Fatihah/001-007 - QS. Al-Fatihah Ayat 7.html' }
    if (-not $next) { $next = '../../00 - Master Blueprint & Arsitektur/Master_Tracker.md' }
    $old = ''
    if ($kind -eq 'upgrade') {
        $old = "`nCatatan: Sudah ada draf v1.0 lama di '$(Get-FilePath $n)'. Anda boleh membacanya sebagai bahan, namun tulis ulang secara utuh dan jauh lebih mendalam sesuai standar v2.0 (jangan sekadar menyalin)."
    }
    return @"
Tulis kajian ensiklopedis lengkap QS. Al-Baqarah [002]: Ayat $n berstandar Kerangka 7 Lensa v2.0 (Gold-Standard) dalam format HTML mandiri, meniru PERSIS struktur, kelas CSS, gaya <style>, dan kedalaman Master Template berikut (baca berkasnya terlebih dahulu):
'$TemplateFile'.
Konteks: Surah Madaniyah; $($b.Name) - Tema Sentral: $($b.Theme).$old

Tuliskan langsung seluruh kode HTML lengkap mulai dari <!DOCTYPE html> sampai </html> yang memuat:
1. Top-Nav (<div class="top-nav">) dengan tautan sebelumnya href="$prev" dan berikutnya href="$next", Badge Meta-Informasi (Surah, Madaniyah, Blok/Klaster, Jumlah Kata & Huruf), Header Dokumen (Surah, Transliterasi Akademis, Judul Tematik Tajam, Subjudul), dan Daftar Isi 7 Lensa (.lens-toc)
2. Lensa 1: Teks (Nash Rasm Utsmani berharakat lengkap QS. 2:$n yang AKURAT, Terjemahan Presisi + Catatan Nuansa Terjemahan, Tabel Analisis Lafaz demi Lafaz: Tajwid, Makharij/Sifat Huruf & Variasi Qira'at 10 Imam Mutawatirah beserta implikasinya, serta Takhrij Asbabun Nuzul & Hadits Sahih Penjelas dalam .hadith-box lengkap dengan Mukharrij, nomor hadits, dan derajat sanad; jangan memuat riwayat palsu/israiliyyat batil)
3. Lensa 2: Bahasa (Analisis Etimologi & Medan Semantik Akar Kata via Maqayis al-Lughah & Lisan al-'Arab, Tabel Morfosintaksis/Sharaf & I'rab Kata demi Kata lengkap dengan Ta'alluq & Mahallul-Jumlah, serta Kajian Balaghah Ma'ani, Bayan, Badi' & I'jaz Fonetik)
4. Lensa 3: Konteks (Integrasi Metodologi 2S & 1L: Sibaq, Siyaq, Lihaq + Rekonstruksi Sosio-Historis & Korelasi Maqasid Surah)
5. Lensa 4: Tafsir Komparatif Lintas Generasi & Mazhab (dalam .tafsir-quote: At-Tabari, Ibnu Katsir, Al-Qurthubi, Az-Zamakhsyari/Ar-Razi, Ibnu 'Asyur, M. Quraish Shihab, Buya Hamka & Kemenag RI + Tabel Matriks Komparasi Ijma' & Ikhtilaf Mufassirin)
6. Lensa 5: Kognisi (Pola Pikir Lama vs Qur'ani, Mental Model, Neuropsikologi & Tazkiyatun Nafs; beri penanda jelas bahwa ini ANALISIS, bukan wahyu; tanpa cocoklogi sains)
7. Lensa 6: Realitas (Fenomenologi Kontemporer Abad ke-21, Kritik Peradaban & Solusi)
8. Lensa 7: Praksis (Tepat 3 Tindakan Nyata Terukur dalam .highlight-box, Tepat 3 Pertanyaan Refleksi Batin dalam .reflection-box, Munajat & Doa Tadabbur Ayat dalam .doa-box, serta <div class="footer-nav"> dengan tautan href="$prev" dan href="$next")
Bahasa Indonesia akademis yang mengalir. JANGAN menulis atau mengubah berkas apa pun; cukup cetak HTML-nya.
Berikan HANYA kode HTML murni tanpa awalan atau akhiran markdown.
"@
}

function Invoke-Generate([int]$n, [string]$kind, [string]$model) {
    $prompt = (Build-Prompt $n $kind) -replace '"', "'"   # PS 5.1 memecah argumen native yang memuat tanda kutip ganda
    $raw = & $AgyPath -p $prompt --model $model --effort high --print-timeout 25m --dangerously-skip-permissions 2>&1
    return ($raw -join "`n")
}

if ($DryRun) {
    for ($n = $From; $n -le $To; $n++) {
        $p = Get-FilePath $n
        if (-not (Test-Path $p)) { Write-Host "$n MISSING"; continue }
        $probs = Test-Quality ([IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)) $n
        if ($probs.Count) { Write-Host "$n UPGRADE: $($probs -join ' ')" }
    }
    return
}

Log "=== QUEUE RUNNER v3.0 START | Models: $($Models -join ', ') | Range $From-$To ==="
$idleRounds = 0
while ($true) {
    $model = Get-AvailableModel
    if (-not $model) {
        $reset = Get-EarliestReset
        $wait = if ($reset) { [Math]::Max(30, [int]($reset - (Get-Date)).TotalSeconds + 15) } else { 300 }
        Log "Semua model terkena kuota. Tidur $wait detik (reset ~ $reset)."
        Start-Sleep -Seconds $wait
        continue
    }

    $job = Claim-Next
    if (-not $job) {
        $idleRounds++
        if ($idleRounds -ge 3) { Log "Antrean kosong (atau sisa ayat sudah mencapai batas percobaan). Worker selesai."; break }
        Start-Sleep -Seconds 60; continue
    }
    $idleRounds = 0
    $n = $job.N; $kind = $job.Kind; $target = Get-FilePath $n
    $lock = "$LockDir\$n.lock"
    Log "GENERATING [$kind] QS. 2:$n via $model ..."
    $t0 = Get-Date
    try {
        $out = Invoke-Generate $n $kind $model
        $html = $null
        if ($out -match '(?s)(<!DOCTYPE html>.*</html>)') { $html = $matches[1].Trim() }
        elseif ($out -match '(?s)(<html.*</html>)') { $html = "<!DOCTYPE html>`n" + $matches[1].Trim() }

        if (-not $html) {
            if ($out -match 'RESOURCE_EXHAUSTED|quota|429|overload|capacity|rate.*limit|503|500|busy') {
                $secs = 1800
                if ($out -match 'Resets in (?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?') {
                    $secs = ([int]$matches[1]) * 3600 + ([int]$matches[2]) * 60 + ([int]$matches[3]) + 20
                }
                Set-ModelBlocked $model ((Get-Date).AddSeconds($secs))
                Log "QUOTA: $model diblokir $secs detik. Ayat $n dikembalikan ke antrean."
            } else {
                $c = Add-Attempt $n
                $snip = $out.Substring(0, [Math]::Min(300, $out.Length)) -replace '\s+', ' '
                Log "WARNING: Tanpa HTML valid untuk ayat $n (percobaan $c). Len=$($out.Length). Cuplikan: $snip"
            }
        } else {
            $probs = Test-Quality $html $n
            if ($probs.Count -gt 0) {
                $c = Add-Attempt $n
                Log "REJECT: Ayat $n gagal validasi (percobaan $c): $($probs -join ' ')"
            } else {
                $dir = Split-Path $target
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
                if (Test-Path $target) { Copy-Item $target "$BackupDir\$(Get-FileName $n)" -Force }
                $tmp = "$target.tmp"
                [IO.File]::WriteAllText($tmp, $html, (New-Object Text.UTF8Encoding($false)))
                Move-Item $tmp $target -Force
                $sec = [int]((Get-Date) - $t0).TotalSeconds
                Log "SUCCESS: $(Get-FileName $n) ($([IO.FileInfo]::new($target).Length) bytes, $sec s, $model)"
            }
        }
    } catch {
        Add-Attempt $n | Out-Null
        Log "ERROR ayat $n : $_"
    } finally {
        Remove-Item $lock -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 3
}
Log "=== QUEUE RUNNER v3.0 SELESAI ==="
