-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run

create table if not exists members (
  id int primary key,
  name text default '',
  status text default 'not done',
  notes text default '',
  doc_link text default '',
  file_path text default '',
  file_name text default '',
  file_size bigint default 0,
  updated_at timestamptz default now()
);

insert into members (id, name)
select g, 'Member ' || g from generate_series(1,14) g
on conflict (id) do nothing;

alter table members enable row level security;
create policy "read" on members for select to anon using (true);
create policy "update" on members for update to anon using (true) with check (true);

-- live updates
alter publication supabase_realtime add table members;

-- public bucket for documents
insert into storage.buckets (id, name, public)
values ('submissions', 'submissions', true)
on conflict (id) do nothing;

create policy "files read" on storage.objects for select to anon using (bucket_id = 'submissions');
create policy "files upload" on storage.objects for insert to anon with check (bucket_id = 'submissions');
create policy "files delete" on storage.objects for delete to anon using (bucket_id = 'submissions');
