# PANDUAN PRAKTIS & KUMPULAN PROMPT MASTER NOTEBOOKLM (KERANGKA 7 LENSA)
**Proyek: Hidup Bersama Al-Qur'an: Dari Ayat, Menjadi Cara Berpikir, Menjadi Cara Hidup**
*Lokasi Sumber Lokal: `Documents/Hidup Bersama Al-Qur'an/00 - Master Blueprint & Arsitektur/NotebookLM_Hub/`*

---

## 1. Panduan Setup Cepat Google NotebookLM (Hanya 3 Menit)

1. Buka peramban (browser) dan akses: **[https://notebooklm.google.com/](https://notebooklm.google.com/)**
2. Klik tombol **"+ New Notebook"** (Buat Notebook Baru).
3. Beri nama notebook sesuai surah yang sedang dikaji, contoh:
   - `HBQ - 02. Surah Al-Baqarah (Grounding 7 Lensa)`
   - `HBQ - 03. Surah Ali 'Imran (Grounding 7 Lensa)`
4. Unggah berkas sumber yang telah disiapkan di folder `NotebookLM_Hub/`:
   - `01_Tafsir_Komparatif/002_Tafsir_Kemenag_Surah_Al-Baqarah.md`
   - `03_Asbabun_Nuzul_Takhrij/002_Asbabun_Nuzul_Al-Baqarah.md`
   - `02_Leksikografi_Morfologi/000_Mu'jam_Maqayis_Lughah_Kaidah_Akar_Kata.md`
   - *(Opsional jika ada)*: PDF Tafsir Al-Azhar Hamka / Al-Mishbah Quraish Shihab bab terkait.

---

## 2. Kumpulan Master Prompt (Siap Salin-Tempel ke NotebookLM)

### PROMPT A: Ekstraksi Data Otentik Lensa 1, 2, 3, 4 (Fase Riset Mentah)
> Salin dan tempel prompt di bawah ini ke kolom chat NotebookLM untuk klaster ayat yang Anda inginkan (misal: QS. 2:1-10):

```markdown
Berdasarkan dokumen sumber yang saya unggah, tolong buatkan sintesis eksegesis komprehensif untuk QS. [NAMA_SURAH]: Ayat [NOMOR_AYAT] dengan struktur berikut:

1. ASBABUN NUZUL & KONTEKS HISTORIS (Lensa 3):
   - Apakah ayat ini memiliki sababun nuzul khusus dalam dokumen sumber? Jika ada, sebutkan riwayatnya, siapa sahabat yang meriwayatkan, dan dinamika sosial audiens pertamanya.
   - Bagaimana korelasi (munasabah) ayat ini dengan ayat sebelum dan sesudahnya?

2. TAFSIR KOMPARATIF ULAMA (Lensa 4):
   - Ringkas tafsir tahlili dari sumber Kemenag RI dan mufasir yang disebutkan.
   - Apa poin kesepakatan (ijma') para mufasir dan di mana letak perbedaan sudut pandang (ikhtilaf)?

3. ETIMOLOGI & KATA KUNCI (Lensa 2):
   - Identifikasi 2-3 kata kunci terpenting dalam ayat tersebut. 
   - Jelaskan makna akar kata aslinya (tsulatsi mujarrad) berdasarkan kaidah Ibnu Faris dalam dokumen sumber.

Berikan jawaban terstruktur dengan sitasi langsung ke dokumen sumber.
```

---

### PROMPT B: Perumusan Mental Model & Kognisi Qur'ani (Lensa 5)
> Gunakan prompt ini untuk mengubah pemahaman tafsir menjadi kaidah berpikir sistemik:

```markdown
Dari hasil tafsir ayat [NOMOR_AYAT] di atas, bantu saya merumuskan:
1. PEROMBAKAN POLA PIKIR:
   - Pola Pikir Lama (Mental Model Konvensional/Duniawi yang keliru) vs. Pola Pikir Qur'ani yang diajarkan ayat ini.
2. KAIDAH BERPIRKIR APLIKATIF (Mental Model):
   - Rumuskan 1 prinsip kognitif operasional singkat (maksimal 2 kalimat) yang bisa dijadikan pegangan dalam mengambil keputusan harian.
3. BIAS KOGNITIF & PSIKOLOGI:
   - Apa kecenderungan psikologis atau ilusi mental manusia (misal: bias kepemilikan, ketakutan akan kemiskinan, kepalsuan niat) yang dibongkar oleh ayat ini?
```

---

### PROMPT C: Rencana Aksi Nyata & Muhasabah (Lensa 6 & 7)
> Gunakan prompt ini untuk merumuskan praksis hidup abad ke-21:

```markdown
Berdasarkan nilai-nilai ayat [NOMOR_AYAT], rumuskan protokol praksis kontemporer:
1. DIAGNOSIS ZAMAN: Apa relevansi ayat ini terhadap tantangan modern manusia abad ke-21 (misal: kecemasan digital, materialisme, krisis integritas, burnout)?
2. TIGA TINDAKAN OPERASIONAL (Mikro-Habit < 5 menit): Berikan 3 langkah aksi terukur yang bisa dipraktikkan mulai hari ini.
3. TIGA PERTANYAAN REFLEKSI BATIN (Muhasabah Qalbiyyah): 3 pertanyaan tajam tanpa basa-basi untuk menguji keikhlasan hati di hadapan Allah.
```

---

### PROMPT D: Pembuatan Audio Overview (Podcast Diskusi Otomatis)
1. Pada panel kanan atas NotebookLM, cari menu **"Audio Overview"** (Deep Dive).
2. Klik tombol **"Customize"** (Kustomisasi) jika ingin memberi arahan gaya bicara:
   - Masukkan instruksi: *"Jadikan diskusi tadabbur yang hangat, menyentuh hati, ilmiah, dan berfokus pada transformasi cara hidup praktis sehari-hari."*
3. Klik **"Generate"**. Dalam 3-5 menit, NotebookLM akan menghasilkan obrolan audio berdurasi 10-15 menit layaknya podcast profesional yang siap Anda dengarkan kapan saja!
