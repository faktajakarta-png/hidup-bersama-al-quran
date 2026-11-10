[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$root = "C:\Users\X250\Documents\Hidup Bersama Al-Qur'an"

function Extract-Meta($filePath, $relPath, $surahName, $blockName) {
    $raw = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $theme = ""
    if ($raw -match '<div class="thematic-title">\s*([\s\S]*?)\s*</div>') {
        $theme = $matches[1].Trim() -replace '\s+', ' '
    }
    $title = ""
    if ($raw -match '<title>\s*([\s\S]*?)\s*</title>') {
        $title = $matches[1].Trim()
    }
    $ayat = 0
    if ($filePath -match 'Ayat\s*(\d+)') {
        $ayat = [int]$matches[1]
    }
    return [PSCustomObject]@{
        Surah = $surahName
        Block = $blockName
        Ayat = $ayat
        ThematicTitle = $theme
        Title = $title
        RelPath = $relPath
    }
}

$items = [System.Collections.Generic.List[PSCustomObject]]::new()

# Fatihah
$fatihahFiles = Get-ChildItem "$root\01 - Surah Al-Fatihah" -Filter "*.html" | Sort-Object Name
foreach ($f in $fatihahFiles) {
    $rel = "01 - Surah Al-Fatihah/$($f.Name)"
    $items.Add((Extract-Meta $f.FullName $rel "Surah Al-Fātihah" "Ummul Qur'ān"))
}

# Baqarah 000
$baqarah000 = "$root\02 - Surah Al-Baqarah\002-000 - Pengantar & Peta Maqasid Surah Al-Baqarah.html"
if (Test-Path $baqarah000) {
    $rel = "02 - Surah Al-Baqarah/002-000 - Pengantar & Peta Maqasid Surah Al-Baqarah.html"
    $items.Add((Extract-Meta $baqarah000 $rel "Surah Al-Baqarah" "Pengantar & Maqasid"))
}

# Baqarah Blocks
$blockDirs = @(
    @{ Name = "Blok 1 (Ayat 1-20)"; Label = "Blok 1: Tipologi Manusia (1–20)" },
    @{ Name = "Blok 2 (Ayat 21-39)"; Label = "Blok 2: Ibadah & Khalifah Adam (21–39)" },
    @{ Name = "Blok 3 (Ayat 40-141)"; Label = "Blok 3: Bani Israil & Kiblat Ibrahim (40–141)" },
    @{ Name = "Blok 4 (Ayat 142-252)"; Label = "Blok 4: Kemandirian Umat & Syariat (142–252)" },
    @{ Name = "Blok 5 (Ayat 253-286)"; Label = "Blok 5: Ayat Kursi & Tauhid Finansial (253–286)" }
)

foreach ($b in $blockDirs) {
    $bFiles = Get-ChildItem "$root\02 - Surah Al-Baqarah\$($b.Name)" -Filter "*.html" | Sort-Object Name
    foreach ($f in $bFiles) {
        $rel = "02 - Surah Al-Baqarah/$($b.Name)/$($f.Name)"
        $items.Add((Extract-Meta $f.FullName $rel "Surah Al-Baqarah" $b.Label))
    }
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine(@"
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MASTER PORTAL & INDEKS ENSIKLOPEDIA: VOLUME 1 | Hidup Bersama Al-Qur'an</title>
<style>
    :root {
        --primary-dark: #0f172a;
        --primary-navy: #1e3a8a;
        --primary-blue: #2563eb;
        --primary-accent: #0284c7;
        --gold-dark: #92400e;
        --gold-mid: #b45309;
        --gold-light: #fef3c7;
        --emerald-dark: #065f46;
        --emerald-light: #d1fae5;
        --bg-page: #f8fafc;
        --bg-card: #ffffff;
        --text-main: #1e293b;
        --text-muted: #64748b;
        --border-light: #e2e8f0;
    }
    * { box-sizing: border-box; }
    body {
        font-family: system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        line-height: 1.6;
        color: var(--text-main);
        background-color: var(--bg-page);
        margin: 0;
        padding: 0;
    }
    .hero {
        background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #0369a1 100%);
        color: #ffffff;
        padding: 55px 24px 45px 24px;
        text-align: center;
        box-shadow: 0 10px 25px rgba(15, 23, 42, 0.15);
    }
    .hero h1 {
        font-size: 34px;
        margin: 0 0 10px 0;
        letter-spacing: 0.5px;
        font-weight: 800;
        text-transform: uppercase;
    }
    .hero .tagline {
        font-size: 19px;
        color: #fde68a;
        font-weight: 600;
        margin-bottom: 8px;
    }
    .hero .author {
        font-size: 14px;
        color: #cbd5e1;
        margin-bottom: 22px;
    }
    .badge-container {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        gap: 10px;
        margin-top: 15px;
    }
    .hero-badge {
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(8px);
        border: 1px solid rgba(255, 255, 255, 0.25);
        color: #ffffff;
        padding: 6px 14px;
        border-radius: 999px;
        font-size: 13px;
        font-weight: 500;
    }
    .container {
        max-width: 1200px;
        margin: auto;
        padding: 30px 20px 80px 20px;
    }
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 16px;
        margin-top: -30px;
        margin-bottom: 35px;
    }
    .stat-card {
        background: var(--bg-card);
        padding: 22px 20px;
        border-radius: 12px;
        border: 1px solid var(--border-light);
        box-shadow: 0 4px 12px rgba(15, 23, 42, 0.05);
        text-align: center;
    }
    .stat-val {
        font-size: 28px;
        font-weight: 800;
        color: var(--primary-navy);
        line-height: 1.2;
    }
    .stat-label {
        font-size: 13px;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-top: 6px;
        font-weight: 600;
    }
    .section-card {
        background: var(--bg-card);
        padding: 28px 30px;
        border-radius: 12px;
        border: 1px solid var(--border-light);
        box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04);
        margin-bottom: 32px;
    }
    .section-card h2 {
        font-size: 20px;
        color: var(--primary-dark);
        margin: 0 0 14px 0;
        display: flex;
        align-items: center;
        gap: 10px;
        border-bottom: 2px solid #f1f5f9;
        padding-bottom: 10px;
    }
    .jilid-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 14px;
        margin-top: 15px;
    }
    .jilid-item {
        background: #f8fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 16px;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .jilid-item:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        border-color: #cbd5e1;
    }
    .jilid-tag {
        font-size: 11px;
        font-weight: 700;
        background: var(--gold-light);
        color: var(--gold-dark);
        padding: 3px 8px;
        border-radius: 4px;
        display: inline-block;
        margin-bottom: 8px;
        text-transform: uppercase;
    }
    .jilid-title {
        font-size: 14.5px;
        font-weight: 700;
        color: var(--primary-dark);
        margin-bottom: 6px;
    }
    .jilid-range {
        font-size: 12.5px;
        color: var(--text-muted);
    }
    .search-bar {
        background: #ffffff;
        padding: 20px;
        border-radius: 12px;
        border: 1px solid #cbd5e1;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04);
        margin-bottom: 25px;
        position: sticky;
        top: 15px;
        z-index: 100;
    }
    .search-input-wrapper {
        position: relative;
    }
    .search-input {
        width: 100%;
        padding: 14px 18px;
        font-size: 16px;
        border: 2px solid #cbd5e1;
        border-radius: 8px;
        outline: none;
        transition: border-color 0.2s;
    }
    .search-input:focus {
        border-color: var(--primary-blue);
    }
    .filter-tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 14px;
    }
    .tab-btn {
        background: #f1f5f9;
        border: 1px solid #e2e8f0;
        padding: 7px 14px;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        color: #475569;
        cursor: pointer;
        transition: all 0.2s;
    }
    .tab-btn:hover, .tab-btn.active {
        background: var(--primary-navy);
        color: #ffffff;
        border-color: var(--primary-navy);
    }
    .items-count-indicator {
        font-size: 13px;
        color: var(--text-muted);
        margin-top: 12px;
        font-weight: 500;
    }
    .ayat-list {
        display: grid;
        grid-template-columns: 1fr;
        gap: 12px;
    }
    .ayat-card {
        background: #ffffff;
        border: 1px solid var(--border-light);
        border-radius: 10px;
        padding: 16px 20px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 18px;
        transition: all 0.15s ease-in-out;
        text-decoration: none;
        color: inherit;
    }
    .ayat-card:hover {
        border-color: var(--primary-accent);
        background: #f0f9ff;
        transform: translateX(4px);
        box-shadow: 0 4px 12px rgba(2, 132, 199, 0.08);
    }
    .ayat-left {
        display: flex;
        align-items: center;
        gap: 16px;
        min-width: 0;
    }
    .ayat-num-badge {
        background: #f1f5f9;
        color: var(--primary-dark);
        border: 1px solid #cbd5e1;
        font-weight: 700;
        font-size: 13px;
        padding: 8px 12px;
        border-radius: 8px;
        min-width: 90px;
        text-align: center;
        flex-shrink: 0;
    }
    .ayat-card:hover .ayat-num-badge {
        background: var(--primary-accent);
        color: #ffffff;
        border-color: var(--primary-accent);
    }
    .ayat-content {
        min-width: 0;
    }
    .ayat-theme {
        font-size: 15px;
        font-weight: 600;
        color: #1e293b;
        margin-bottom: 4px;
        line-height: 1.4;
    }
    .ayat-meta {
        font-size: 12.5px;
        color: var(--text-muted);
        display: flex;
        gap: 12px;
        align-items: center;
    }
    .ayat-btn-open {
        background: #e0f2fe;
        color: #0369a1;
        font-weight: 700;
        font-size: 12.5px;
        padding: 8px 16px;
        border-radius: 6px;
        flex-shrink: 0;
        display: flex;
        align-items: center;
        gap: 6px;
    }
    .ayat-card:hover .ayat-btn-open {
        background: #0284c7;
        color: #ffffff;
    }
    .hidden {
        display: none !important;
    }
    footer {
        text-align: center;
        margin-top: 50px;
        padding-top: 25px;
        border-top: 1px solid var(--border-light);
        font-size: 13px;
        color: var(--text-muted);
    }
</style>
</head>
<body>

<header class="hero">
    <div class="tagline">Hidup Bersama Al-Qur'an: Dari Ayat, Menjadi Cara Berpikir, Menjadi Cara Hidup</div>
    <h1>MASTER PORTAL ENSIKLOPEDIA &bull; VOLUME 1</h1>
    <div class="author">Kajian Komprehensif Berbasis Kerangka 7 Lensa (The 7-Lens Framework v2.0) &bull; Inisiator: Eizar Aswad</div>
    <div class="badge-container">
        <span class="hero-badge">📖 Surah Al-Fātihah & Surah Al-Baqarah</span>
        <span class="hero-badge">📜 295 Berkas Kajian Paripurna</span>
        <span class="hero-badge">🔤 ~2.090.000 Kata Eksegesis</span>
        <span class="hero-badge">⭐ Gold-Standard v2.0</span>
    </div>
</header>

<div class="container">

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-val">295</div>
            <div class="stat-label">Total Berkas Kajian</div>
        </div>
        <div class="stat-card">
            <div class="stat-val">2.09 Juta</div>
            <div class="stat-label">Estimasi Kata Teks</div>
        </div>
        <div class="stat-card">
            <div class="stat-val">7.112</div>
            <div class="stat-label">Rata-rata Kata / Ayat</div>
        </div>
        <div class="stat-card">
            <div class="stat-val">5 Sub-Jilid</div>
            <div class="stat-label">Rekomendasi Format Cetak</div>
        </div>
    </div>

    <section class="section-card">
        <h2>📚 Arsitektur Volume 1 & Rekomendasi 5 Sub-Jilid Cetak</h2>
        <p style="font-size: 14.5px; color: #475569; margin-top: 0;">
            Karena Volume 1 memiliki kedalaman luar biasa setara dengan ~5.970 halaman cetak, untuk edisi terbit fisik ensiklopedia dibagi menjadi 5 Sub-Jilid tematik:
        </p>
        <div class="jilid-grid">
            <div class="jilid-item">
                <span class="jilid-tag">Sub-Jilid 1A</span>
                <div class="jilid-title">Ummul Qur'ān & Tipologi Manusia</div>
                <div class="jilid-range">QS. Al-Fātihah [1:0–7] & Al-Baqarah [2:0–39]</div>
            </div>
            <div class="jilid-item">
                <span class="jilid-tag">Sub-Jilid 1B</span>
                <div class="jilid-title">Kritik Peradaban & Kiblat Ibrahim</div>
                <div class="jilid-range">QS. Al-Baqarah [2:40–141] (Bani Israil)</div>
            </div>
            <div class="jilid-item">
                <span class="jilid-tag">Sub-Jilid 1C</span>
                <div class="jilid-title">Kemandirian Umat & Syariat Ibadah</div>
                <div class="jilid-range">QS. Al-Baqarah [2:142–214] (Kiblat, Shaum, Haji)</div>
            </div>
            <div class="jilid-item">
                <span class="jilid-tag">Sub-Jilid 1D</span>
                <div class="jilid-title">Hukum Keluarga & Solidaritas Sosial</div>
                <div class="jilid-range">QS. Al-Baqarah [2:215–252] (Infaq, Nikah, Thalaq)</div>
            </div>
            <div class="jilid-item">
                <span class="jilid-tag">Sub-Jilid 1E</span>
                <div class="jilid-title">Ayat Kursi & Tauhid Finansial</div>
                <div class="jilid-range">QS. Al-Baqarah [2:253–286] (Infaq vs Riba & Doa)</div>
            </div>
        </div>
    </section>

    <!-- SEARCH & FILTER BAR -->
    <div class="search-bar">
        <div class="search-input-wrapper">
            <input type="text" id="searchInput" class="search-input" placeholder="🔍 Cari nomor ayat (misal: 255, 183) atau kata kunci tema (misal: infaq, riba, ibrahim, adam, shalat, takwa)...">
        </div>
        <div class="filter-tabs">
            <button class="tab-btn active" data-filter="all">Semua Ayat (295)</button>
            <button class="tab-btn" data-filter="fatihah">QS. Al-Fātihah (8)</button>
            <button class="tab-btn" data-filter="blok1">Al-Baqarah Blok 1 (21)</button>
            <button class="tab-btn" data-filter="blok2">Blok 2 (19)</button>
            <button class="tab-btn" data-filter="blok3">Blok 3 (102)</button>
            <button class="tab-btn" data-filter="blok4">Blok 4 (111)</button>
            <button class="tab-btn" data-filter="blok5">Blok 5 (34)</button>
        </div>
        <div class="items-count-indicator" id="countIndicator">Menampilkan 295 dari 295 berkas kajian</div>
    </div>

    <!-- LIST OF AYAT -->
    <div class="ayat-list" id="ayatList">
"@)

foreach ($item in $items) {
    $category = "all"
    if ($item.Surah -match "Fātihah") {
        $category = "fatihah"
    } elseif ($item.Block -match "Pengantar|Blok 1") {
        $category = "blok1"
    } elseif ($item.Block -match "Blok 2") {
        $category = "blok2"
    } elseif ($item.Block -match "Blok 3") {
        $category = "blok3"
    } elseif ($item.Block -match "Blok 4") {
        $category = "blok4"
    } elseif ($item.Block -match "Blok 5") {
        $category = "blok5"
    }

    $badgeLabel = ""
    if ($item.Surah -match "Fātihah") {
        if ($item.Ayat -eq 0) { $badgeLabel = "QS. 1:0 (Maqasid)" } else { $badgeLabel = "QS. 1:$($item.Ayat)" }
    } else {
        if ($item.Ayat -eq 0) { $badgeLabel = "QS. 2:0 (Maqasid)" } else { $badgeLabel = "QS. 2:$($item.Ayat)" }
    }

    $themeText = $item.ThematicTitle
    if (-not $themeText) { $themeText = $item.Title }
    $escapedTheme = [System.Net.WebUtility]::HtmlEncode($themeText)
    $escapedBlock = [System.Net.WebUtility]::HtmlEncode($item.Block)
    $escapedSurah = [System.Net.WebUtility]::HtmlEncode($item.Surah)
    $escapedRel   = [System.Net.WebUtility]::HtmlEncode($item.RelPath)

    [void]$sb.AppendLine(@"
        <a href="$escapedRel" class="ayat-card" data-category="$category" data-keywords="$badgeLabel $escapedTheme $escapedBlock $escapedSurah">
            <div class="ayat-left">
                <div class="ayat-num-badge">$badgeLabel</div>
                <div class="ayat-content">
                    <div class="ayat-theme">$escapedTheme</div>
                    <div class="ayat-meta">
                        <span><strong>Surah:</strong> $escapedSurah</span>
                        <span>&bull;</span>
                        <span><strong>Blok:</strong> $escapedBlock</span>
                    </div>
                </div>
            </div>
            <div class="ayat-btn-open">Buka Kajian &rarr;</div>
        </a>
"@)
}

[void]$sb.AppendLine(@"
    </div>

    <footer>
        <p><strong>Proyek Ensiklopedis Hidup Bersama Al-Qur'an</strong> &bull; Edisi Gold-Standard v2.0</p>
        <p>Kerangka 7 Lensa: Dari Ayat, Menjadi Cara Berpikir, Menjadi Cara Hidup &bull; Hak Cipta &copy; 2026 Eizar Aswad</p>
    </footer>

</div>

<script>
    const searchInput = document.getElementById('searchInput');
    const tabButtons = document.querySelectorAll('.tab-btn');
    const cards = document.querySelectorAll('.ayat-card');
    const countIndicator = document.getElementById('countIndicator');

    let currentCategory = 'all';

    function filterItems() {
        const query = searchInput.value.toLowerCase().trim();
        let visibleCount = 0;

        cards.forEach(card => {
            const category = card.getAttribute('data-category');
            const keywords = card.getAttribute('data-keywords').toLowerCase();

            const matchesCategory = (currentCategory === 'all') || (category === currentCategory);
            const matchesQuery = (query === '') || keywords.includes(query);

            if (matchesCategory && matchesQuery) {
                card.classList.remove('hidden');
                visibleCount++;
            } else {
                card.classList.add('hidden');
            }
        });

        countIndicator.textContent = `Menampilkan ${visibleCount} dari ${cards.length} berkas kajian`;
    }

    searchInput.addEventListener('input', filterItems);

    tabButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            tabButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentCategory = btn.getAttribute('data-filter');
            filterItems();
        });
    });
</script>

</body>
</html>
"@)

[System.IO.File]::WriteAllText("$root\Volume_1_Master_Index.html", $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "SUCCESS: Volume_1_Master_Index.html written! Bytes: $((Get-Item "$root\Volume_1_Master_Index.html").Length)"
