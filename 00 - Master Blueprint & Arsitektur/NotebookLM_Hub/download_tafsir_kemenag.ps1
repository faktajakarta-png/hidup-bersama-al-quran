# Download & format Tafsir Kemenag RI into NotebookLM Dossiers
param(
    [int[]]$SurahNumbers = @(2, 3)
)

$OutDir = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\00 - Master Blueprint & Arsitektur\NotebookLM_Hub\01_Tafsir_Komparatif"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

foreach ($s in $SurahNumbers) {
    Write-Host "Mengunduh Tafsir Kemenag RI Surah $s..."
    $url = "https://raw.githubusercontent.com/rioastamal/quran-json/master/surah/$s.json"
    try {
        $json = Invoke-RestMethod -Uri $url -Method Get
        $surahData = $json."$s"
        $surahNameLatin = $surahData.name_latin
        $surahNameArabic = $surahData.name
        $numAyah = $surahData.number_of_ayah
        
        $md = New-Object System.Text.StringBuilder
        [void]$md.AppendLine("# SUMBER PRIMER TAFSIR: SURAH $surahNameLatin ($surahNameArabic) [00$s]")
        [void]$md.AppendLine("**Koleksi Tafsir Tahlili Resmi Kementerian Agama Republik Indonesia**")
        [void]$md.AppendLine("**Jumlah Ayat**: $numAyah | **Format**: Grounding Source untuk Google NotebookLM`n")
        [void]$md.AppendLine("---`n")
        
        for ($a = 1; $a -le $numAyah; $a++) {
            $ar = $surahData.text."$a"
            $id = $surahData.translations.id.text."$a"
            $tafsir = $surahData.tafsir.id.kemenag.text."$a"
            
            [void]$md.AppendLine("## QS. $surahNameLatin [$s]: Ayat $a")
            [void]$md.AppendLine("### Teks Wahyu (Rasm Utsmani)")
            [void]$md.AppendLine("> $ar`n")
            [void]$md.AppendLine("### Terjemahan")
            [void]$md.AppendLine("> `"$id`"`n")
            [void]$md.AppendLine("### Tafsir Kemenag RI")
            [void]$md.AppendLine("$tafsir`n")
            [void]$md.AppendLine("---`n")
        }
        
        $outPath = Join-Path $OutDir ("{0:D3}_Tafsir_Kemenag_Surah_{1}.md" -f $s, ($surahNameLatin -replace '\s+', '_'))
        [IO.File]::WriteAllText($outPath, $md.ToString(), [System.Text.Encoding]::UTF8)
        $sizeKb = [Math]::Round(([IO.FileInfo]::new($outPath).Length / 1KB), 1)
        Write-Host "SUKSES: $outPath ($sizeKb KB)"
    } catch {
        Write-Host "GAGAL mengunduh Surah ${s}: $_"
    }
}
