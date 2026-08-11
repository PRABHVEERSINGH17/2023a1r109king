# Make TR Tech a fully LIVE app

## Done (verified)

- Confirm email is **OFF** (`mailer_autoconfirm: true`)
- Live **Sign Up** returns a session
- Live **Sign In** with password works

## One remaining step (required for saving clients)

Your old Supabase tables do **not** match the Flutter app  
(missing `user_id`, wrong invoice/project columns, no `tickets`).

### Run this SQL

1. Supabase → **SQL Editor** → **New query**  
2. Open: `tr_tech_solutions/supabase/rebuild_for_app.sql`  
3. Copy all → paste → **Run**  
4. Reply: **schema rebuilt**

This keeps auth users and rebuilds CRM tables to match the app.

---

## Then use the live app

1. Open the app → **Exit Demo — Go Online**  
2. **Create Online Account** (real email + password)  
   or **Sign In** if you already signed up  
3. **Settings** → Workspace Mode = **Online — live Supabase backend**  
4. **Clients → Add Client** → should save in the cloud  

Ignore Google / Apple / LinkedIn for now.
