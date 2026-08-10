import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/features/auth/screens/login_screen.dart';
import 'package:tr_tech_solutions/features/auth/screens/signup_screen.dart';
import 'package:tr_tech_solutions/features/clients/screens/clients_screen.dart';
import 'package:tr_tech_solutions/features/dashboard/screens/dashboard_screen.dart';
import 'package:tr_tech_solutions/features/expenses/screens/expenses_screen.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/leads/screens/leads_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/reports/screens/reports_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/settings/screens/settings_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = SupabaseConfig.isConfigured &&
          authState.valueOrNull?.session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!SupabaseConfig.isConfigured) {
        return state.matchedLocation == '/login' ? null : '/login';
      }

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
          GoRoute(path: '/leads', builder: (_, __) => const LeadsScreen()),
          GoRoute(path: '/services', builder: (_, __) => const ServicesScreen()),
          GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen()),
          GoRoute(path: '/invoices', builder: (_, __) => const InvoicesScreen()),
          GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
          GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
          GoRoute(path: '/tickets', builder: (_, __) => const TicketsScreen()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
