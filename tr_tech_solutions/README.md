# TR Technology Solutions LLP

A full-featured business management platform built with **Flutter** and **Supabase**. Manage clients, leads, services, projects, invoices, payments, expenses, and support tickets from a single dark-themed dashboard.

## Features

- **Authentication** — Email/password sign up and sign in via Supabase Auth
- **Dashboard** — KPI cards, revenue chart, services donut chart, sales pipeline, renewals, recent invoices & projects
- **Clients** — Full CRUD with status tracking
- **Leads** — Sales pipeline with stage management
- **Services** — Domains, hosting, websites, SSL, email tracking with expiry dates
- **Projects** — Project tracking with status and budgets
- **Invoices** — Create and manage invoices with status (pending, paid, overdue)
- **Payments** — Record payments with multiple methods (UPI, bank transfer, etc.)
- **Expenses** — Track business expenses by category
- **Support Tickets** — Helpdesk with priority and status workflow
- **Reports** — Report module placeholders
- **Responsive UI** — Desktop sidebar + mobile bottom navigation

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+)
- A [Supabase](https://supabase.com) project

## Quick start (works immediately — no Supabase needed)

```bash
cd tr_tech_solutions
flutter pub get
flutter run -d chrome
```

On the login screen:
- Click **Explore Demo Dashboard**, or
- Sign in with the pre-filled demo credentials (`admin@trtechsolutions.com` / `demo1234`)

The app ships with full sample data (clients, invoices, leads, services, tickets, etc.) so every screen works out of the box.

## Connect your Supabase backend

Credentials go in `assets/.env` (gitignored):

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Database setup

1. Create a project at [supabase.com](https://supabase.com)
2. Run [`supabase/schema.sql`](supabase/schema.sql) in **SQL Editor**
3. If tables already exist, run [`supabase/fix_missing.sql`](supabase/fix_missing.sql) for tickets + dashboard stats
4. Enable Email auth: Authentication → Providers → Email
5. For faster local testing, disable **Confirm email** under Auth settings

Then restart:

```bash
flutter run -d chrome
```

With credentials configured, login uses real Supabase Auth and all CRUD hits your database.

## Project Structure

```
lib/
├── main.dart                 # App entry + Supabase init
├── core/                     # Theme, config, utils
├── features/                 # Feature modules
│   ├── auth/                 # Login & signup
│   ├── dashboard/            # Main dashboard
│   ├── clients/              # Client management
│   ├── leads/                # Sales pipeline
│   ├── services/             # Service tracking
│   ├── projects/             # Project management
│   ├── invoices/             # Billing
│   ├── payments/             # Payment records
│   ├── expenses/             # Expense tracking
│   ├── tickets/              # Support tickets
│   ├── reports/              # Analytics
│   └── settings/             # App settings
├── shared/                   # Models, widgets, services
└── router/                   # GoRouter navigation
supabase/
└── schema.sql                # Database schema + RLS
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.24 |
| State Management | Riverpod |
| Navigation | GoRouter |
| Charts | fl_chart |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| Fonts | Material / platform fonts |
| Android ID | `com.trtechsolutions.app` |
| Release | Google Play AAB (`PLAY_STORE.md`) |

## Security

- Row Level Security (RLS) enabled on all tables
- Each user can only access their own data
- Supabase Auth handles session management

## License

Private — TR Technology Solutions LLP
