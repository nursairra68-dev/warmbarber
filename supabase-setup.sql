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
  scheduled_at timestamptz,
  cancelled boolean not null default false,
  created_at timestamptz not null default now()
);

alter table bookings enable row level security;
alter table bookings add column if not exists scheduled_at timestamptz;
alter table bookings add column if not exists cancelled boolean not null default false;

-- Elak dua tempahan untuk barber + tarikh + masa yang sama (double-booking).
-- Barber lain masih boleh ditempah pada masa yang sama -- hanya slot
-- barber yang SAMA pada masa yang SAMA yang disekat. Guna unique index
-- SEPARUH (partial) supaya slot yang DIBATALKAN terbuka semula untuk
-- ditempah orang lain.
alter table bookings
  drop constraint if exists bookings_date_time_unique;
alter table bookings
  drop constraint if exists bookings_barber_date_time_unique;
create unique index if not exists bookings_barber_date_time_active_unique
  on bookings (barber_name, date_full, time)
  where (cancelled = false);

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
-- sudah penuh (untuk papar butang masa yang "disabled"). Tempahan yang
-- sudah DIBATALKAN tidak dikira -- slot tu terbuka semula.
create or replace view public_booked_slots as
  select date_full, time, barber_name from bookings where cancelled = false;
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

-- ====================================================================
-- STATUS KEDAI (buka / tutup sementara) -- untuk ciri "Pengurusan Kedai"
-- dalam tab Profil app. Sesiapa boleh BACA status ni (supaya app tahu
-- nak papar/sekat tempahan), tapi hanya boleh TUKAR melalui fungsi
-- set_shop_status() yang disekat dengan PIN rahsia.
-- ====================================================================
create table if not exists shop_status (
  id smallint primary key default 1,
  is_open boolean not null default true,
  note text,
  updated_at timestamptz not null default now(),
  constraint single_row check (id = 1)
);
insert into shop_status (id, is_open, note) values (1, true, null) on conflict (id) do nothing;

alter table shop_status enable row level security;

create policy "Public can read shop status"
  on shop_status for select
  to anon
  using (true);

-- TUKAR '267910' kepada PIN pilihan awak sendiri sebelum guna secara
-- production -- ini PIN lalai yang Claude jana untuk awak.
create or replace function set_shop_status(p_is_open boolean, p_note text, p_pin text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_pin is distinct from '267910' then
    return false;
  end if;
  update shop_status set is_open = p_is_open, note = p_note, updated_at = now() where id = 1;
  return true;
end;
$$;
grant execute on function set_shop_status(boolean, text, text) to anon;

-- ====================================================================
-- BATAL TEMPAHAN SENDIRI (pelanggan) -- hanya dibenarkan kalau masih
-- 30 minit ATAU LEBIH sebelum masa tempahan. Guna "soft cancel"
-- (tanda cancelled=true) bukan padam terus, supaya rekod kekal untuk
-- rujukan pemilik kedai.
-- ====================================================================
create or replace function cancel_my_booking(p_booking_id uuid, p_phone text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sched timestamptz;
  v_cancelled boolean;
begin
  select scheduled_at, cancelled into v_sched, v_cancelled from bookings
    where id = p_booking_id and customer_phone = p_phone;
  if v_sched is null or v_cancelled is null then
    return false;
  end if;
  if v_cancelled then
    return false;
  end if;
  if now() > (v_sched - interval '30 minutes') then
    return false;
  end if;
  update bookings set cancelled = true where id = p_booking_id and customer_phone = p_phone;
  return true;
end;
$$;
grant execute on function cancel_my_booking(uuid, text) to anon;
