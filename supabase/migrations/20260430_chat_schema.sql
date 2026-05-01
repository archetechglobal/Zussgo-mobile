-- Chat messages table (if not already created)
create table if not exists public.messages (
  id            uuid primary key default gen_random_uuid(),
  connection_id uuid not null references public.connections(id) on delete cascade,
  sender_id     uuid not null references auth.users(id) on delete cascade,
  content       text not null,
  type          text not null default 'text',
  read_at       timestamptz,
  created_at    timestamptz not null default now()
);

-- Index for fast per-connection message loading
create index if not exists messages_connection_created
  on public.messages (connection_id, created_at asc);

-- RLS
alter table public.messages enable row level security;

-- Only parties in the connection can read messages
create policy "Connection members can read messages"
  on public.messages for select
  using (
    exists (
      select 1 from public.connections c
      where c.id = messages.connection_id
        and (c.requester_id = auth.uid() or c.receiver_id = auth.uid())
        and c.status = 'accepted'
    )
  );

-- Only the sender can insert
create policy "Sender can insert message"
  on public.messages for insert
  with check (
    sender_id = auth.uid()
    and exists (
      select 1 from public.connections c
      where c.id = messages.connection_id
        and (c.requester_id = auth.uid() or c.receiver_id = auth.uid())
        and c.status = 'accepted'
    )
  );

-- Enable Realtime for messages table
alter publication supabase_realtime add table public.messages;
