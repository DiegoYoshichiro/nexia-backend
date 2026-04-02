-- ============================================================
--  NexIA — Cole este SQL no Supabase e clique em RUN
--  Supabase → SQL Editor → New Query → Cole aqui → Run
-- ============================================================

create table if not exists clients (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  segment          text,
  phone            text,
  status           text default 'active',
  plan             text default 'basic',
  system_prompt    text,
  zapi_instance    text,
  zapi_token       text,
  created_at       timestamptz default now()
);

create table if not exists messages (
  id            uuid primary key default gen_random_uuid(),
  client_id     uuid references clients(id) on delete cascade,
  phone         text not null,
  user_message  text not null,
  bot_reply     text not null,
  created_at    timestamptz default now()
);

create index if not exists idx_messages_client_phone
  on messages(client_id, phone);

create index if not exists idx_messages_created_at
  on messages(created_at desc);

-- ============================================================
--  IMPORTANTE: Substitua os valores abaixo antes de executar
-- ============================================================

insert into clients (name, segment, status, plan, system_prompt, zapi_instance, zapi_token)
values (
  'Meu Primeiro Cliente',
  'Teste',
  'active',
  'basic',
  '# IDENTIDADE
Você é Sofia, assistente virtual. Seja cordial e objetiva.

# OBJETIVO
Responder dúvidas e agendar atendimentos.

# REGRAS
- Mensagens curtas e diretas
- Encaminhe para humano se não souber responder',
  'COLE_AQUI_O_INSTANCE_ID_DA_ZAPI',
  'COLE_AQUI_O_TOKEN_DA_ZAPI'
);

-- Após executar, rode esta query para ver o ID do cliente:
-- select id, name from clients;
