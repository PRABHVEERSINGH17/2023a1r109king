# Go Online (leave Demo Mode)

Follow these steps exactly. No coding needed.

## In the app (1 minute)

1. Open the live CRM  
2. If you are in Demo Mode, go to **Settings**  
3. Tap **Exit Demo Mode & Go Online**  
4. Tap **Create Online Account**  
5. Enter your name, email, password → **Create Account**  
6. Sign in with that email/password  

Your clients will now save to the cloud (Supabase).

You can also tap **Exit Demo — Go Online** on the login screen.

---

## One-time Supabase setup (required for online data)

Do this once in a browser:

### A) Turn off email confirmation (easiest)

1. Open https://supabase.com/dashboard  
2. Open your project  
3. **Authentication** → **Providers** → **Email**  
4. Disable **Confirm email** → Save  

### B) Create database tables

1. In Supabase: **SQL Editor** → **New query**  
2. Open this file on your computer:  
   `tr_tech_solutions/supabase/schema.sql`  
3. Copy all → paste into SQL Editor → **Run**  
4. Open `tr_tech_solutions/supabase/fix_missing.sql`  
5. Copy all → paste → **Run**  

### C) Allow your website to log in

1. **Authentication** → **URL Configuration**  
2. Add redirect URLs:

```text
http://localhost:*
com.trtechsolutions.app://login-callback/
https://*.trycloudflare.com/**
https://*.netlify.app/**
```

---

## Social login (optional)

See `SOCIAL_LOGIN.md` to enable Google / Apple / LinkedIn.

---

## If something fails

- Stay productive with **Demo Mode** anytime  
- Settings → **Switch to Demo Mode**  
- Online mode needs the SQL files above or screens may look empty
