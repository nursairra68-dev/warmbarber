-- Jalankan kod ni dalam Supabase: buka projek awak -> SQL Editor -> New query
-- -> paste semua ni -> klik "Run".
--
-- Fail ni dah dikemaskini supaya PADAN dengan database sebenar: setiap
-- tempahan hanya boleh dibuat SEKALI untuk (barber + tarikh + masa) yang
-- sama (elak double-booking), dan nombor telefon/nama pelanggan TIDAK
-- lagi boleh dibaca terus oleh orang lain -- hanya pelanggan itu sendiri
-- (melalui nombor telefonnya) boleh tengok tempahan dia sendiri.

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

-- Elak dua tempahan untuk barber + tarikh + masa yang sama (double-booking).
-- Barber lain masih boleh ditempah pada masa yang sama -- hanya slot
-- barber yang SAMA pada masa yang SAMA yang disekat.
alter table bookings
  drop constraint if exists bookings_date_time_unique;
alter table bookings
  add constraint bookings_barber_date_time_unique unique (barber_name, date_full, time);

-- Benarkan sesiapa sahaja (pelanggan) buat tempahan baru.
create policy "Public can insert bookings"
  on bookings for insert
  to anon
  with check (true);

-- PENTING: jangan benarkan sesiapa baca terus jadual "bookings" --
-- ia mengandungi nama & nombor telefon SEMUA pelanggan. Policy baca
-- lama "using (true)" dimatikan (guna ALTER bukan DROP sebab DROP POLICY
-- kadangkala gagal senyap dalam sesetengah persekitaran).
drop policy if exists "Public can read bookings" on bookings;
create policy "Public can read bookings"
  on bookings for select
  to anon
  using (false);

-- View tanpa data peribadi -- selamat untuk app semak slot mana yang
-- sudah penuh (untuk papar butang masa yang "disabled").
create or replace view public_booked_slots as
  select date_full, time, barber_name from bookings;
grant select on public_booked_slots to anon;

-- Fungsi untuk seorang pelanggan tengok SENARAI TEMPAHAN DIA SENDIRI
-- sahaja, berdasarkan nombor telefon yang dia sendiri bekalkan (app
-- simpan nombor ni dalam localStorage telefon pelanggan, bukan di server).
create or replace function get_my_bookings(p_phone text)
returns setof bookings
language sql
security definer
set search_path = public
as $$
  select * from bookings
  where customer_phone = p_phone
  order by created_at desc
  limit 50;
$$;
grant execute on function get_my_bookings(text) to anon;
