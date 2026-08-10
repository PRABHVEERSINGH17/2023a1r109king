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

## Connect your Supabase backend (optional)

### 1. Run the database schema

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql)
3. Copy **Project URL** and **anon key** from **Settings → API**

### 2. Add credentials

Edit `assets/.env`:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Enable Email Auth

Authentication → Providers → Email → enable. Disable **Confirm email** for local development.

### 4. Restart the app

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
| Fonts | Google Fonts (Inter) |

## Security

- Row Level Security (RLS) enabled on all tables
- Each user can only access their own data
- Supabase Auth handles session management

## License

Private — TR Technology Solutions LLP
