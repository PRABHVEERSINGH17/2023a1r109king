# Make TR Tech a fully LIVE app

You do **not** need Google Client ID for a live app.  
Live = **Supabase email Sign Up / Sign In** + cloud CRM tables.

Your project is already connected:
`https://izpxnkovciqjotfbofkc.supabase.co`

CRM tables (`clients`, `invoices`, …) are already present.

---

## The one setting that is blocking you

Supabase still has **Confirm email = ON**.  
That means Sign Up never returns a live session (and hits email rate limits).

### Fix it (2 minutes)

1. Open https://supabase.com/dashboard  
2. Open project **izpxnkovciqjotfbofkc**  
3. Left menu → **Authentication** → **Providers**  
4. Click **Email**  
5. Find **Confirm email** → turn it **OFF**  
6. Click **Save**

Screenshot path:  
`Authentication` → `Providers` → `Email` → disable Confirm email → Save

---

## Then create your live account in the app

1. Open the app  
2. Tap **Exit Demo — Go Online** (or `/login?mode=online`)  
3. Tap **Create Online Account**  
4. Use a **real email** (Gmail etc.) + password (6+ chars)  
5. Create Account  

Settings → Workspace Mode should say:  
**Online — live Supabase backend**

Add a client → it saves in Supabase (not only on the phone).

---

## Do NOT use for now

- Continue with Google / Apple / LinkedIn  
  (providers are off — optional later, see `SOCIAL_LOGIN.md`)

---

## If Sign Up still fails

| Message | What to do |
|---------|------------|
| Confirm email / no session | Confirm email is still ON — repeat steps above |
| email rate limit | Same fix — turn Confirm email OFF (stops sending mail) |
| Invalid credentials | Create Online Account first, then Sign In |
| provider is not enabled | Ignore social buttons — use email |

---

## Optional SQL (only if screens look empty online)

In Supabase → **SQL Editor**, run:

1. `tr_tech_solutions/supabase/schema.sql`  
2. `tr_tech_solutions/supabase/fix_missing.sql`  

(Your project already returned OK for `clients` / `invoices`, so this may already be done.)

---

## After Confirm email is OFF

Reply here: **“confirm email is off”**  
We will verify live Sign Up against your Supabase project.
