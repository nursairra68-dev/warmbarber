-- Jalankan kod ni dalam Supabase: buka projek awak -> SQL Editor -> New query
-- -> paste semua ni -> klik "Run".

create extension if not exists pgcrypto;

create table if not exists bookings (
  id uuid primary key default gen_random_uuid(),
  ref text not null,
  services text[] not null,
  mins int not null,
  barber_name text not null,
  date_full text not null,
  time text not null,
  total int not null,
  customer_name text,
  customer_phone text,
  created_at timestamptz not null default now()
);

alter table bookings enable row level security;

-- Benarkan sesiapa sahaja (pelanggan) buat tempahan baru
create policy "Public can insert bookings"
  on bookings for insert
  to anon
  with check (true);

-- Benarkan sesiapa sahaja baca senarai tempahan (supaya app boleh papar
-- dalam tab "Janji Temu Saya"). Kalau awak nak sorok nombor telefon
-- pelanggan daripada orang luar, buang baris ni dan guna akaun admin
-- berasingan untuk kedai sahaja -- bagitahu Claude kalau nak versi tu.
create policy "Public can read bookings"
  on bookings for select
  to anon
  using (true);
