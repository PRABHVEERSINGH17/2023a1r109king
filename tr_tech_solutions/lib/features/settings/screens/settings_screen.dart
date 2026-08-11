import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = ref.watch(authServiceProvider).currentUserEmail ?? 'Not logged in';
    final isDemo = ref.watch(demoModeProvider);

    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: ListView(
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Account and app info',
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
                const ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Company'),
                  subtitle: Text('TR Technology Solutions LLP'),
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
                        ? 'Demo leftover — sign out and create a live account'
                        : SupabaseConfig.isConfigured
                            ? 'Online — live Supabase backend'
                            : 'Configure Supabase to sync data',
                  ),
                ),
                if (isDemo) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.public_rounded, color: AppColors.primary),
                    title: const Text('Switch to live account'),
                    subtitle: const Text('Sign out and create / sign in with email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref.read(authServiceProvider).exitDemoAndGoOnline();
                      if (context.mounted) context.go('/login');
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
                    'Live cloud authentication via Supabase',
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
