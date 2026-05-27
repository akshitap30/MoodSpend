-- MOODSPEND SUPABASE SCHEMA
-- Paste this into your Supabase SQL Editor

-- 1. Users Table
create table public.users (
  id uuid references auth.users not null primary key,
  name text not null,
  email text not null,
  avatar_url text,
  hourly_wage numeric default 312,
  goal_type text default 'vacation',
  goal_amount numeric default 50000,
  goal_name text default 'Vacation Fund',
  onboarding_complete boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Habits Table
create table public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users not null,
  name text not null,
  category text not null,
  cost_per_instance numeric not null,
  frequency_per_month integer not null,
  trigger_time text,
  is_active boolean default true,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Mood Logs Table
create table public.mood_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users not null,
  timestamp timestamp with time zone default timezone('utc'::text, now()) not null,
  mood integer not null check (mood between 1 and 5),
  energy integer not null check (energy between 1 and 10),
  context_tags text[] default '{}',
  habit_id uuid references public.habits,
  amount numeric,
  note text,
  hour_of_day integer not null,
  day_of_week integer not null
);

-- 4. Patterns Table
create table public.patterns (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users not null,
  generated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  trigger_habit_id uuid references public.habits,
  trigger_habit_name text,
  trigger_mood_range integer[] default '{}',
  trigger_tags text[] default '{}',
  trigger_hour_start integer,
  trigger_hour_end integer,
  avg_spend numeric,
  occurrence_count integer,
  confidence_score numeric
);

-- 5. Challenges Table
create table public.challenges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users not null,
  week_start date not null,
  habit_id uuid references public.habits,
  habit_name text not null,
  trigger_description text not null,
  replacement_action text not null,
  target_saving numeric not null,
  status text default 'pending', -- pending | completed | skipped
  completed_at timestamp with time zone
);

-- 6. Saved Jar Table
create table public.saved_jar (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users not null,
  amount numeric not null,
  source_challenge_id uuid references public.challenges,
  note text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ── ROW LEVEL SECURITY (RLS) ──────────────────────────────────────────────────

alter table public.users enable row level security;
alter table public.habits enable row level security;
alter table public.mood_logs enable row level security;
alter table public.patterns enable row level security;
alter table public.challenges enable row level security;
alter table public.saved_jar enable row level security;

-- Policies: Users can only see/edit their own data
create policy "Users can view own profile" on public.users for select using (auth.uid() = id);
create policy "Users can update own profile" on public.users for update using (auth.uid() = id);

create policy "Users can manage own habits" on public.habits for all using (auth.uid() = user_id);
create policy "Users can manage own logs" on public.mood_logs for all using (auth.uid() = user_id);
create policy "Users can manage own patterns" on public.patterns for all using (auth.uid() = user_id);
create policy "Users can manage own challenges" on public.challenges for all using (auth.uid() = user_id);
create policy "Users can manage own jar" on public.saved_jar for all using (auth.uid() = user_id);
