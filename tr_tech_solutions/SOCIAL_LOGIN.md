# Social Login — Google, Apple, LinkedIn

The app already has **Continue with Google / Apple / LinkedIn** buttons.

They work through **Supabase Auth**. You only need to turn each provider on in the Supabase dashboard (one-time setup).

Until that is done, use **Continue with Demo Mode**.

---

## 1. Open your Supabase project

1. Go to https://supabase.com/dashboard  
2. Open project `izpxnkovciqjotfbofkc` (or your project)  
3. Left menu → **Authentication** → **Providers**

---

## 2. Add redirect URLs (required)

Still in Authentication:

1. Open **URL Configuration**
2. **Site URL**: your live website (or `http://localhost:xxxx` while testing)
3. **Redirect URLs** — add all of these:

```text
http://localhost:*
com.trtechsolutions.app://login-callback/
https://*.trycloudflare.com/**
https://*.netlify.app/**
```

Save.

---

## 3. Enable Google

1. Providers → **Google** → Enable  
2. Create OAuth credentials in [Google Cloud Console](https://console.cloud.google.com/apis/credentials)  
   - Type: **Web application**  
   - Authorized redirect URI (copy from Supabase Google provider page):  
     `https://izpxnkovciqjotfbofkc.supabase.co/auth/v1/callback`
3. Paste **Client ID** + **Client Secret** into Supabase → Save  

---

## 4. Enable Apple

1. Providers → **Apple** → Enable  
2. Needs an [Apple Developer](https://developer.apple.com) account  
3. Create a Services ID + key, then paste Client ID / Secret into Supabase  
4. Official guide: https://supabase.com/docs/guides/auth/social-login/auth-apple  

---

## 5. Enable LinkedIn

1. Providers → **LinkedIn (OIDC)** → Enable  
2. Create an app at https://www.linkedin.com/developers/  
3. Add redirect URL from the Supabase LinkedIn provider page  
4. Paste Client ID + Secret into Supabase → Save  

---

## 6. Test in the app

```bash
cd tr_tech_solutions
flutter run -d chrome
```

On the login screen tap **Continue with Google** (or Apple / LinkedIn).

---

## Notes

- Demo Mode always works without any of the above.  
- Mobile apps return via deep link: `com.trtechsolutions.app://login-callback/`  
- If a provider is not enabled, the app shows a clear error and offers Demo Mode.
