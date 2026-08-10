import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Manage your account and preferences',
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
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Email and push notification preferences'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined),
                  title: const Text('Appearance'),
                  subtitle: const Text('Modern light workspace'),
                  trailing: Switch(value: false, onChanged: null),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('Backend Mode'),
                  subtitle: Text(
                    isDemo
                        ? 'Demo mode (local sample data)'
                        : SupabaseConfig.isConfigured
                            ? 'Connected to Supabase'
                            : 'Not configured - update assets/supabase.env',
                    style: TextStyle(
                      color: isDemo || SupabaseConfig.isConfigured
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
                if (!isDemo) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.science_outlined),
                    title: const Text('Load Demo Clients'),
                    subtitle: const Text('Switch to sample data with 5 clients'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref.read(authServiceProvider).enterDemoMode();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo Mode enabled — sample clients loaded'),
                          ),
                        );
                        context.go('/clients');
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
                  Text('Business Management Platform v1.0.0',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
