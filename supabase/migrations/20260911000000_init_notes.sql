create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text,
  created_at timestamptz not null default now()
);

alter table public.notes enable row level security;

create policy "Anyone can read notes"
  on public.notes
  for select
  using (true);

create policy "Anyone can insert notes"
  on public.notes
  for insert
  with check (true);
