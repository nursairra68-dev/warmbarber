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

## 6. Dapat notifikasi (bunyi + naik atas skrin) bila ada tempahan baru

Guna servis percuma **ntfy.sh** — tak perlu daftar akaun, tak perlu
bayar:

1. Pasang app **"ntfy"** kat telefon awak (ada dalam App Store / Play Store)
2. Buka app tu -> tekan **"+"** (subscribe ke topik baru)
3. Masukkan topik ini (dah sedia dalam `config.js`): `warmbarber-89375760fd`
   — atau tukar kepada topik rahsia lain kalau nak, asalkan sama macam
   dalam `window.NTFY_TOPIC` di `config.js`
4. Siap! Setiap kali pelanggan buat tempahan, telefon awak akan terima
   push notification (ada bunyi + naik atas skrin) dengan nama, no fon,
   khidmat & masa tempahan tu.

Boleh subscribe topik yang sama dalam beberapa telefon (cth. awak +
pekerja) kalau nak semua orang terima notifikasi yang sama.

## 7. Elak double-booking (slot sama tak boleh ditempah 2 kali)

Dah automatik — pangkalan data (Supabase) sendiri yang jaga: kalau dua
pelanggan cuba tempah barber yang SAMA, tarikh & masa yang SAMA, orang
kedua akan nampak mesej "slot ni baru sahaja diambil orang lain" dan
disuruh pilih masa lain. Barber lain masih boleh ditempah pada masa yang
sama — hanya slot barber yang sama yang disekat.

## 8. Pelanggan perlu "daftar" (nama + no fon) untuk guna app

Bila pelanggan buka app kali pertama, mereka akan diminta isi **nama +
no telefon** sahaja (tiada SMS OTP, tiada emel/password — ringkas &
percuma). Maklumat ni disimpan terus dalam telefon pelanggan tu sendiri
(bukan dalam pangkalan data), supaya lain kali mereka buka app, app
terus ingat & terus boleh tempah/tengok tempahan lama mereka tanpa isi
semula. Pelanggan boleh "Log keluar" dalam tab Profil untuk padam
maklumat ni dari telefon mereka.

## Apa yang dah berfungsi penuh sekarang

- Tempahan pelanggan SIMPAN betul-betul dalam pangkalan data (Supabase),
  bukan sekadar dalam skrin
- Sesiapa sahaja boleh buka pautan & buat tempahan sendiri (tiada had
  "view-only" lagi)
- Awak (pemilik kedai) terima notifikasi bunyi + naik atas skrin di
  telefon setiap kali ada tempahan baru (via app ntfy — lihat #6)
- Slot yang sama (barber + tarikh + masa) tak boleh ditempah dua kali
- Pelanggan daftar ringkas (nama + no fon) dan hanya boleh tengok
  tempahan dia sendiri — nama & no fon pelanggan lain TIDAK boleh dibaca
  oleh sesiapa pun melalui app ni

## Nak domain sendiri (cth. warmbarber.com) kemudian?

Dalam Vercel: Project -> Settings -> Domains -> tambah domain yang awak
beli (dari mana-mana penyedia domain), ikut arahan DNS yang Vercel bagi.
Boleh buat bila-bila masa, tak perlu buat sekarang.
