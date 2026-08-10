-- Missing pieces for TR Tech app (run in Supabase SQL Editor)
-- Safe to re-run

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tickets table (missing from current project)
CREATE TABLE IF NOT EXISTS tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
  ticket_number TEXT NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_id ON tickets(user_id);

ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own tickets" ON tickets;
CREATE POLICY "Users manage own tickets" ON tickets
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP TRIGGER IF EXISTS tickets_updated_at ON tickets;
CREATE TRIGGER tickets_updated_at
  BEFORE UPDATE ON tickets
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Dashboard stats RPC
CREATE OR REPLACE FUNCTION get_dashboard_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_revenue', COALESCE((SELECT SUM(amount) FROM payments WHERE user_id = p_user_id), 0),
    'total_clients', COALESCE((SELECT COUNT(*) FROM clients WHERE user_id = p_user_id AND status = 'active'), 0),
    'active_services', COALESCE((SELECT COUNT(*) FROM services WHERE user_id = p_user_id AND status = 'active'), 0),
    'pending_invoices_count', COALESCE((SELECT COUNT(*) FROM invoices WHERE user_id = p_user_id AND status = 'pending'), 0),
    'pending_invoices_amount', COALESCE((SELECT SUM(total) FROM invoices WHERE user_id = p_user_id AND status = 'pending'), 0),
    'overdue_invoices_count', COALESCE((SELECT COUNT(*) FROM invoices WHERE user_id = p_user_id AND status = 'overdue'), 0),
    'overdue_invoices_amount', COALESCE((SELECT SUM(total) FROM invoices WHERE user_id = p_user_id AND status = 'overdue'), 0),
    'open_tickets', COALESCE((SELECT COUNT(*) FROM tickets WHERE user_id = p_user_id AND status IN ('open', 'in_progress')), 0),
    'total_leads', COALESCE((SELECT COUNT(*) FROM leads WHERE user_id = p_user_id), 0)
  ) INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ensure profile auto-create trigger exists
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'admin'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
