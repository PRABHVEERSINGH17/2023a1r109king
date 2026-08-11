# Make TR Tech a fully LIVE app

## Already verified

- Confirm email is **OFF**
- Live Sign Up / Sign In work

## Required now (tables still wrong)

Your Supabase tables are still the old shape (no `user_id` on clients).  
Until this SQL runs, **Add Client** cannot save to the cloud.

### Run this (safer ALTER script)

1. Open https://supabase.com/dashboard → project **izpxnkovciqjotfbofkc**
2. **SQL Editor** → **New query**
3. Open this file in the repo:

`tr_tech_solutions/supabase/align_existing_schema.sql`

Or download raw:

https://raw.githubusercontent.com/PRABHVEERSINGH17/2023a1r109king/cursor/clickable-dashboard-2b7a/tr_tech_solutions/supabase/align_existing_schema.sql

4. Copy **ALL** text → paste in SQL Editor → **Run**
5. You should see green **Success**
6. Run this check query:

```sql
select column_name
from information_schema.columns
where table_schema = 'public' and table_name = 'clients'
order by 1;
```

You must see **`user_id`** and **`company`** in the list.

7. Reply: **schema aligned**

---

## Then in the app

1. Exit Demo → Go Online  
2. Create Online Account / Sign In  
3. Clients → Add Client  
4. Settings should say **Online — live Supabase backend**
