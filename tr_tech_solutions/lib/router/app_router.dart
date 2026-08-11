import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/providers/local_auth_provider.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/features/auth/screens/login_screen.dart';
import 'package:tr_tech_solutions/features/auth/screens/signup_screen.dart';
import 'package:tr_tech_solutions/features/clients/screens/client_detail_screen.dart';
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

bool _hasSupabaseSession() {
  if (!SupabaseConfig.isConfigured) return false;
  try {
    // Prefer the live client session — StreamProvider can lag one frame after login.
    return Supabase.instance.client.auth.currentSession != null;
  } catch (_) {
    return false;
  }
}

/// Stable GoRouter instance. Auth/demo changes refresh redirects without
/// recreating the router (recreating was resetting navigation and breaking
/// the dashboard).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isDemo = ref.read(demoModeProvider);
      final isLocal = ref.read(localAuthProvider);
      final authState = ref.read(authStateProvider);
      final streamSession = authState.valueOrNull?.session != null;
      final supabaseLoggedIn = _hasSupabaseSession() || streamSession;
      // Demo, device-local account, or cloud Supabase session all count.
      final isLoggedIn = isDemo || isLocal || supabaseLoggedIn;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/signup';

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
          GoRoute(
            path: '/clients/:id',
            builder: (_, state) => ClientDetailScreen(clientId: state.pathParameters['id']!),
          ),
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

  ref.onDispose(router.dispose);
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(demoModeProvider, (_, __) => notifyListeners());
    ref.listen(localAuthProvider, (_, __) => notifyListeners());
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    if (SupabaseConfig.isConfigured) {
      try {
        Supabase.instance.client.auth.onAuthStateChange.listen((_) {
          notifyListeners();
        });
      } catch (_) {}
    }
  }
}
