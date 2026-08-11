-- Optional: restore PostgREST embeds (app works without this now)
ALTER TABLE public.payments DROP CONSTRAINT IF EXISTS payments_client_id_fkey;
ALTER TABLE public.payments
  ADD CONSTRAINT payments_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

ALTER TABLE public.invoices DROP CONSTRAINT IF EXISTS invoices_client_id_fkey;
ALTER TABLE public.invoices
  ADD CONSTRAINT invoices_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

ALTER TABLE public.services DROP CONSTRAINT IF EXISTS services_client_id_fkey;
ALTER TABLE public.services
  ADD CONSTRAINT services_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

ALTER TABLE public.projects DROP CONSTRAINT IF EXISTS projects_client_id_fkey;
ALTER TABLE public.projects
  ADD CONSTRAINT projects_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

ALTER TABLE public.tickets DROP CONSTRAINT IF EXISTS tickets_client_id_fkey;
ALTER TABLE public.tickets
  ADD CONSTRAINT tickets_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

ALTER TABLE public.leads DROP CONSTRAINT IF EXISTS leads_client_id_fkey;
ALTER TABLE public.leads
  ADD CONSTRAINT leads_client_id_fkey
  FOREIGN KEY (client_id) REFERENCES public.clients(id) ON DELETE SET NULL;

NOTIFY pgrst, 'reload schema';
