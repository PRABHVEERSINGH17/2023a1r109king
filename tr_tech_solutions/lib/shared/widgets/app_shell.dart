import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/providers/data_bootstrap_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/shared/widgets/sidebar.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _navItems = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard', route: '/dashboard'),
    (icon: Icons.people_outline, activeIcon: Icons.people, label: 'Clients', route: '/clients'),
    (icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up, label: 'Leads', route: '/leads'),
    (icon: Icons.dns_outlined, activeIcon: Icons.dns, label: 'Services', route: '/services'),
    (icon: Icons.folder_outlined, activeIcon: Icons.folder, label: 'Projects', route: '/projects'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Invoices', route: '/invoices'),
    (icon: Icons.payment_outlined, activeIcon: Icons.payment, label: 'Payments', route: '/payments'),
    (icon: Icons.money_off_outlined, activeIcon: Icons.money_off, label: 'Expenses', route: '/expenses'),
    (icon: Icons.support_agent_outlined, activeIcon: Icons.support_agent, label: 'Tickets', route: '/tickets'),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reports', route: '/reports'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dataBootstrapProvider);

    final currentRoute = GoRouterState.of(context).uri.path;
    final isWide = MediaQuery.of(context).size.width >= 900;
    final isDemo = ref.watch(demoModeProvider);
    final email = ref.watch(authServiceProvider).currentUserEmail ?? 'User';
    final displayEmail = isDemo ? '$email · Demo' : email;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Sidebar(
              currentRoute: currentRoute,
              navItems: _navItems,
              onSignOut: () => _signOut(context, ref),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.canvasGradient,
                  ),
                ),
                child: Column(
                  children: [
                    _HeaderBar(email: displayEmail, onSignOut: () => _signOut(context, ref)),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('TR Tech Solutions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          PopupMenuButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(enabled: false, child: Text(displayEmail)),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: () => _signOut(context, ref),
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.canvasGradient,
          ),
        ),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mobileIndex(currentRoute),
        onDestinationSelected: (i) => context.go(_navItems[i].route),
        destinations: _navItems.take(4).map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMobileMenu(context),
        child: const Icon(Icons.menu_rounded),
      ),
    );
  }

  int _mobileIndex(String route) {
    final index = _navItems.indexWhere((item) => item.route == route);
    return index >= 0 && index < 4 ? index : 0;
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            ..._navItems.skip(4).map((item) {
              return ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.label, style: const TextStyle(fontFamily: AppTypography.body)),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.route);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).signOut();
    if (context.mounted) context.go('/login');
  }
}

class _HeaderBar extends StatelessWidget {
  final String email;
  final VoidCallback onSignOut;

  const _HeaderBar({required this.email, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.86),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search clients, invoices, tickets…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Badge(
              backgroundColor: AppColors.accent,
              label: const Text('3'),
              child: const Icon(Icons.notifications_none_rounded),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            offset: const Offset(0, 48),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.brand,
                    child: Icon(Icons.person_rounded, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Super Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          fontFamily: AppTypography.body,
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontFamily: AppTypography.body,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              const PopupMenuItem<void>(
                child: Row(children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 8), Text('Profile')]),
              ),
              PopupMenuItem<void>(
                onTap: () => context.go('/settings'),
                child: const Row(children: [Icon(Icons.settings_outlined, size: 18), SizedBox(width: 8), Text('Settings')]),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: onSignOut,
                child: const Row(
                  children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('Sign Out')],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
