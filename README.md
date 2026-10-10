# Warm Barber — Panduan Publish

App ni sekarang fail website biasa (HTML/CSS/JS) — tiada lagi had "view-only"
macam artifact Claude. Ikut langkah di bawah untuk letak ia live, boleh
diakses sesiapa sahaja, dengan tempahan yang betul-betul simpan.

## 1. Letak kod ni dalam GitHub (repo baru)

1. Pergi ke github.com -> log masuk -> klik **+** (penjuru atas kanan) -> **New repository**
2. Nama repo: `warm-barber` -> **Create repository**
3. Dalam page repo kosong tu, klik **"uploading an existing file"**
4. Drag & drop SEMUA fail dalam folder ni (`index.html`, `config.js`, `supabase-setup.sql`, `README.md`)
5. Klik **Commit changes**

Tak perlu guna command line / terminal langsung — semua boleh buat dari browser.

## 2. Sediakan pangkalan data (Supabase)

1. Buka supabase.com -> log masuk -> **New project**
2. Bagi nama (cth. `warm-barber`), tetapkan kata laluan database, pilih region
   Singapore (paling dekat) -> **Create new project** (ambil ~2 minit)
3. Lepas siap, pergi ke **SQL Editor** (menu kiri) -> **New query**
4. Buka fail `supabase-setup.sql` dalam repo GitHub awak, copy semua kandungannya,
   paste dalam SQL Editor -> klik **Run**
5. Pergi ke **Project Settings -> API** -> salin dua nilai ni:
   - **Project URL**
   - **anon public** key

## 3. Masukkan nilai Supabase ke dalam app

1. Dalam repo GitHub awak, buka fail `config.js` -> klik ikon pensel (Edit)
2. Ganti `YOUR-PROJECT-ID...` dengan **Project URL** tadi
3. Ganti `YOUR-ANON-PUBLIC-KEY` dengan **anon public** key tadi
4. Klik **Commit changes**

## 4. Hos di Vercel (dapat pautan live, percuma)

1. Buka vercel.com -> log masuk guna **Continue with GitHub**
2. Klik **Add New -> Project**
3. Pilih repo `warm-barber` -> klik **Import**
4. Tak perlu ubah apa-apa setting -> klik **Deploy**
5. Lepas siap (~1 minit), Vercel bagi pautan macam `warm-barber.vercel.app`
   — itulah website kedai awak, LIVE dan boleh sesiapa saja guna.

Lepas tu, setiap kali awak edit fail terus dalam GitHub (cth. tukar harga
khidmat), Vercel automatik publish semula dalam beberapa saat — tak perlu
upload manual lagi.

## 5. Kod QR

Buka website yang live tu -> tab Utama -> ikon QR di penjuru atas, atau
Profil -> "Kongsi App (Kod QR)". Kod QR automatik ikut pautan sebenar
(`warm-barber.vercel.app`) — boleh screenshot/cetak terus untuk letak kat
kaunter kedai.

## Apa yang dah berfungsi penuh sekarang

- Tempahan pelanggan SIMPAN betul-betul dalam pangkalan data (Supabase),
  bukan sekadar dalam skrin
- Sesiapa sahaja boleh buka pautan & buat tempahan sendiri (tiada had
  "view-only" lagi)
- Bila ada tempahan baru, sesiapa yang ada app tu terbuka (kedai/staff)
  nampak terus secara live tanpa refresh

## Nak domain sendiri (cth. warmbarber.com) kemudian?

Dalam Vercel: Project -> Settings -> Domains -> tambah domain yang awak
beli (dari mana-mana penyedia domain), ikut arahan DNS yang Vercel bagi.
Boleh buat bila-bila masa, tak perlu buat sekarang.
