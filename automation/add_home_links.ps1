$root = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$files = Get-ChildItem -LiteralPath "$root\01 - Surah Al-Fatihah", "$root\02 - Surah Al-Baqarah", "$root\03 - Surah Ali 'Imran" -Recurse -Filter "*.html"

$updated = 0
foreach ($f in $files) {
    $relFromRoot = $f.FullName.Substring($root.Length + 1)
    $depth = ($relFromRoot.Split('\').Count) - 1
    $homeHref = if ($depth -eq 1) { "../index.html" } elseif ($depth -eq 2) { "../../index.html" } else { "index.html" }

    $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)

    if ($raw -notmatch 'href="[^"]*index\.html"') {
        $new = [regex]::Replace($raw, '(?s)(<div class="top-nav"[^>]*>.*?)\s*<span>[^<]*(?:<strong>[^<]*</strong>[^<]*)?Hidup Bersama Al-Qur''an[^<]*</span>', "`$1`n        <a href=`"$homeHref`" style=`"background:#fef3c7;color:#92400e;border:1px solid #fcd34d;`">&#127968; Beranda Portal Indeks</a>")
        if ($new -ne $raw) {
            [System.IO.File]::WriteAllText($f.FullName, $new, $utf8NoBom)
            $updated++
        }
    }
}
Write-Host "Updated home portal link in $updated additional files."
