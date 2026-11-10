$base = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\03 - Surah Ali 'Imran"
$subdirs = @(
    "Blok 1 (Ayat 1-32)",
    "Blok 2 (Ayat 33-63)",
    "Blok 3 (Ayat 64-101)",
    "Blok 4 (Ayat 102-151)",
    "Blok 5 (Ayat 152-200)"
)
foreach ($s in $subdirs) {
    $p = Join-Path $base $s
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        Write-Host "Created: $p"
    }
}
Write-Host "Setup Ali 'Imran directory structure done."
