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

## Setup

### 1. Supabase Database

1. Create a project at [supabase.com](https://supabase.com)
2. Go to **SQL Editor** and run the entire contents of [`supabase/schema.sql`](supabase/schema.sql)
3. Go to **Settings → API** and copy your **Project URL** and **anon public key**

### 2. Configure Credentials

Edit `assets/.env` with your Supabase credentials:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Enable Email Auth in Supabase

1. Go to **Authentication → Providers → Email**
2. Enable **Email** provider
3. For development, you can disable **Confirm email** under Email settings

### 4. Run the App

```bash
cd tr_tech_solutions
flutter pub get
flutter run -d chrome    # Web
flutter run              # Mobile/Desktop
```

Or pass credentials via dart-define:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-key
```

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
