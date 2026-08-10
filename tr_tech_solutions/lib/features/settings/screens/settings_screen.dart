import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/leads/screens/leads_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _invalidateAll(WidgetRef ref) {
    ref.invalidate(clientsProvider);
    ref.invalidate(leadsProvider);
    ref.invalidate(projectsProvider);
    ref.invalidate(invoicesProvider);
    ref.invalidate(paymentsProvider);
    ref.invalidate(servicesProvider);
    ref.invalidate(ticketsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authServiceProvider).currentUserEmail ?? 'Not logged in';
    final isDemo = ref.watch(demoModeProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: ListView(
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Account, workspace mode, and app info',
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Account'),
                  subtitle: Text(email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text('Company'),
                  subtitle: const Text('TR Technology Solutions LLP'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    isDemo ? Icons.science_outlined : Icons.cloud_done_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Workspace Mode'),
                  subtitle: Text(
                    isDemo
                        ? 'Demo Mode — full sample CRM (recommended)'
                        : SupabaseConfig.isConfigured
                            ? 'Live Supabase backend'
                            : 'Supabase not configured — use Demo Mode',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Reset Demo Workspace'),
                  subtitle: const Text('Reload sample clients, invoices, payments & more'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await ref.read(authServiceProvider).enterDemoMode(resetWorkspace: true);
                    _invalidateAll(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo workspace reset — sample data loaded')),
                      );
                      context.go('/dashboard');
                    }
                  },
                ),
                if (!isDemo) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bolt_rounded),
                    title: const Text('Switch to Demo Mode'),
                    subtitle: const Text('Use the fully working sample CRM'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref.read(authServiceProvider).enterDemoMode(resetWorkspace: true);
                      _invalidateAll(ref);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demo Mode enabled')),
                        );
                        context.go('/dashboard');
                      }
                    },
                  ),
                ],
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
                  onTap: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('TR Technology Solutions LLP', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    'Business Management Platform v1.0.0\n'
                    'Modules: Dashboard, Clients, Leads, Services, Projects,\n'
                    'Invoices, Payments, Expenses, Tickets, Reports',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
