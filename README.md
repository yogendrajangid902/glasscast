# Glasscast

Glasscast is a minimal SwiftUI weather app with Supabase auth + favorites, OpenWeather forecasts, and a polished Liquid Glass UI.

## Features
- Email/password auth with Supabase
- Favorite cities stored in Postgres (RLS-enabled)
- Current weather + 5-day forecast
- City search via OpenWeather Geocoding
- Temperature unit toggle (°C/°F)
- Dynamic background and glass UI

## Tech Stack
- SwiftUI (iOS 26 target)
- MVVM + async/await
- Supabase (Auth + Postgres)
- OpenWeatherMap API

## Setup
1. Add the Supabase Swift package in Xcode:
   - `https://github.com/supabase/supabase-swift`
2. Add Info.plist keys (target → Info):
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `OPENWEATHER_API_KEY`
3. Create the database table + RLS policies (Supabase SQL Editor):

```sql
create table if not exists public.favorite_cities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  city_name text not null,
  lat double precision not null,
  lon double precision not null,
  created_at timestamptz not null default now()
);

alter table public.favorite_cities enable row level security;

create policy "Favorite cities read own"
on public.favorite_cities
for select
using (auth.uid() = user_id);

create policy "Favorite cities insert own"
on public.favorite_cities
for insert
with check (auth.uid() = user_id);

create policy "Favorite cities delete own"
on public.favorite_cities
for delete
using (auth.uid() = user_id);
```

## Run
- Build and run on an iOS 26 simulator/device.
- Flow: sign up/login → add favorite city → view weather → toggle units → sign out.

## Notes
- Forecast excludes the current day to show the next 5 days.
- UV index uses OpenWeather `/data/2.5/uvi` (may require plan access).
