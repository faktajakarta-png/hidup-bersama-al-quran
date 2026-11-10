# Download and format Asbabun Nuzul into NotebookLM Dossiers
param(
    [string[]]$SurahCodes = @("002", "003")
)

$OutDir = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\00 - Master Blueprint & Arsitektur\NotebookLM_Hub\03_Asbabun_Nuzul_Takhrij"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

foreach ($code in $SurahCodes) {
    Write-Host "Mengunduh Asbabun Nuzul Surah $code..."
    $url = "https://raw.githubusercontent.com/mostafaahmed97/asbab-al-nuzul-dataset/main/data/structured/json/$code.json"
    try {
        $items = Invoke-RestMethod -Uri $url -Method Get
        $surahInt = [int]$code
        $surahName = if ($surahInt -eq 2) { "Al-Baqarah" } elseif ($surahInt -eq 3) { "Ali 'Imran" } else { "Surah $surahInt" }
        
        $md = New-Object System.Text.StringBuilder
        [void]$md.AppendLine("# SUMBER HISTORIS: ASBABUN NUZUL SURAH $surahName.ToUpper() [${code}]")
        [void]$md.AppendLine("**Koleksi Riwayat Sebab Turunnya Wahyu (Kitab Asbabun Nuzul al-Wahidi & as-Suyuthi)**")
        [void]$md.AppendLine("**Surah**: $surahName ($surahInt) | **Format**: Grounding Dataset untuk Google NotebookLM`n")
        [void]$md.AppendLine("---`n")
        
        foreach ($item in $items) {
            $ayahList = $item.ayahs -join ", "
            [void]$md.AppendLine("## Asbabun Nuzul QS. $surahName [$surahInt]: Ayat $ayahList")
            $occIdx = 1
            foreach ($occ in $item.occasions) {
                [void]$md.AppendLine("### Riwayat / Sabab $occIdx")
                [void]$md.AppendLine("$occ`n")
                $occIdx++
            }
            [void]$md.AppendLine("---`n")
        }
        
        $outPath = Join-Path $OutDir ("{0}_Asbabun_Nuzul_{1}.md" -f $code, ($surahName -replace '\s+', '_'))
        [IO.File]::WriteAllText($outPath, $md.ToString(), [System.Text.Encoding]::UTF8)
        $sizeKb = [Math]::Round(([IO.FileInfo]::new($outPath).Length / 1KB), 1)
        Write-Host "SUKSES: $outPath ($sizeKb KB)"
    } catch {
        Write-Host "GAGAL mengunduh Asbabun Nuzul Surah ${code}: $_"
    }
}
