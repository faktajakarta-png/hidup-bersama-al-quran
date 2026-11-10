# Memperbaiki rantai navigasi (top-nav & footer-nav) seluruh berkas Al-Baqarah agar tautan prev/next lintas-blok benar.
param([switch]$Apply)
$SurahDir = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an\02 - Surah Al-Baqarah"
$Blocks = @(@{N='Blok 1 (Ayat 1-20)';S=1;E=20},@{N='Blok 2 (Ayat 21-39)';S=21;E=39},@{N='Blok 3 (Ayat 40-141)';S=40;E=141},@{N='Blok 4 (Ayat 142-252)';S=142;E=252},@{N='Blok 5 (Ayat 253-286)';S=253;E=286})
function B([int]$n){ foreach($b in $Blocks){ if($n -ge $b.S -and $n -le $b.E){ return $b.N } } }
function FN([int]$n){ "002-{0:D3} - QS. Al-Baqarah Ayat {1}.html" -f $n,$n }
function Rel([int]$f,[int]$t){
    if($t -lt 1){ return '../../01 - Surah Al-Fatihah/001-007 - QS. Al-Fatihah Ayat 7.html' }
    if($t -gt 286){ return '../../00 - Master Blueprint &amp; Arsitektur/Master_Tracker.md' }
    if((B $f) -eq (B $t)){ FN $t } else { "../$(B $t)/$(FN $t)" }
}
$changed = 0
for($n=1;$n -le 286;$n++){
    $p = "$SurahDir\$(B $n)\$(FN $n)"
    if(-not (Test-Path $p)){ Write-Host "$n MISSING"; continue }
    $raw = [IO.File]::ReadAllText($p,[Text.Encoding]::UTF8)
    $prev = Rel $n ($n-1); $next = Rel $n ($n+1)
    $new = [regex]::Replace($raw,'(?s)(<div class="(?:top-nav|footer-nav)"[^>]*>)(.*?)(</div>)',{
        param($m)
        $inner = $m.Groups[2].Value
        $links = [regex]::Matches($inner,'href="([^"]*)"')
        if($links.Count -ge 2){
            # ganti tautan pertama -> prev, terakhir -> next
            $first = $links[0]; $last = $links[$links.Count-1]
            $orig = $m.Groups[2].Value
            $sb = $orig.Substring(0,$first.Index) + "href=`"$prev`"" + $orig.Substring($first.Index+$first.Length, $last.Index-($first.Index+$first.Length)) + "href=`"$next`"" + $orig.Substring($last.Index+$last.Length)
            return $m.Groups[1].Value + $sb + $m.Groups[3].Value
        }
        return $m.Value
    })
    if($new -ne $raw){
        $changed++
        Write-Host "$n nav diperbaiki"
        if($Apply){ [IO.File]::WriteAllText($p,$new,(New-Object Text.UTF8Encoding($false))) }
    }
}
Write-Host "Total berkas dengan perubahan nav: $changed (Apply=$Apply)"
