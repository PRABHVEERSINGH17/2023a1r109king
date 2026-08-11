# Authentication — how to sign in

TR Tech CRM supports three working auth paths.

## Fastest (works now)

### Demo Mode
1. Open the app  
2. Tap **Continue with Demo Mode**  
3. You are in with sample clients / invoices  

**Or** Sign In with:

| Field | Value |
|-------|--------|
| Email | `admin@trtechsolutions.com` |
| Password | `demo1234` |

---

### Your own email (Sign Up → Sign In)

1. On login → **Exit Demo — Go Online** (or Settings → **Exit Demo Mode & Go Online**)  
2. Tap **Create Online Account**  
3. Enter **name**, **email**, **password** (6+ characters) → Create Account  
4. You land on the dashboard signed in  

Next time: use the same email/password on **Sign In**.

This works even if cloud email confirmation is blocked — the account is saved on this device.

---

## Cloud Supabase (optional)

Already wired via `assets/supabase.env`.

For cloud sessions + cloud data:

1. Supabase Dashboard → **Authentication** → **Providers** → **Email**  
2. Turn **Confirm email** **OFF** → Save  
3. Run `supabase/schema.sql` and `supabase/fix_missing.sql` (see `GO_ONLINE.md`)  

Then Sign Up / Sign In uses the live backend when the cloud accepts the login.

---

## Social login (optional)

Google / Apple / LinkedIn buttons are in the UI.

If you see:

```text
Unsupported provider: provider is not enabled
```

that provider is **off** in Supabase. Do **not** use those buttons yet.

Use instead:

1. **Create Online Account** (email Sign Up), or  
2. **Continue with Demo Mode**

To turn social login on later, follow `SOCIAL_LOGIN.md`.

---

## Check you’re signed in

**Settings → Account** shows your email.  
**Workspace Mode** shows:

- Demo Mode  
- Signed in on this device  
- Online — live Supabase backend  
