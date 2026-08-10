import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_motion.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/leads/screens/leads_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/client_bootstrap.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

export 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  Future<void> _loadDemoData(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider).enterDemoMode();
    ref.invalidate(clientsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loaded sample clients in Demo Mode')),
      );
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final isDemo = ref.watch(demoModeProvider);
    final wide = MediaQuery.of(context).size.width >= 980;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInUp(
            child: PageHeader(
              title: 'Clients',
              subtitle: isDemo
                  ? 'Add a client and related lead, invoice, payment & more appear automatically.'
                  : 'Your client hub — related records are created when you add someone new.',
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(clientsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showClientDialog(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Client'),
                  ),
                ],
              ),
            ),
          ),
          if (isDemo) ...[
            const SizedBox(height: 16),
            FadeInUp(
              delay: const Duration(milliseconds: 60),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primaryLight.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.22)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Demo Mode — new clients auto-create lead, project, invoice, payment, service & ticket.',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: AppTypography.body,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Expanded(
            child: clientsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: 'Could not load clients.\n$e',
                onRetry: () => ref.invalidate(clientsProvider),
                secondaryLabel: isDemo ? null : 'Load Demo Clients',
                onSecondary: isDemo ? null : () => _loadDemoData(context, ref),
              ),
              data: (clients) {
                if (clients.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No clients yet',
                    subtitle: isDemo
                        ? 'Add your first client to get started'
                        : 'Your live database has no clients yet. Load sample data or add a client.',
                    actionLabel: 'Add Client',
                    onAction: () => _showClientDialog(context, ref),
                    secondaryLabel: isDemo ? null : 'Load Demo Clients',
                    onSecondary: isDemo ? null : () => _loadDemoData(context, ref),
                  );
                }

                return FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = wide
                          ? (constraints.maxWidth > 1200 ? 3 : 2)
                          : 1;
                      if (crossAxisCount == 1) {
                        return ListView.separated(
                          itemCount: clients.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _ClientCard(
                                client: clients[index],
                                initials: _initials(clients[index].name),
                                onOpen: () => context.go('/clients/${clients[index].id}'),
                                onEdit: () =>
                                    _showClientDialog(context, ref, client: clients[index]),
                                onDelete: () =>
                                    _deleteClient(context, ref, clients[index].id),
                              ),
                        );
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.75,
                        ),
                        itemCount: clients.length,
                        itemBuilder: (context, index) => _ClientCard(
                          client: clients[index],
                          initials: _initials(clients[index].name),
                          onOpen: () => context.go('/clients/${clients[index].id}'),
                          onEdit: () =>
                              _showClientDialog(context, ref, client: clients[index]),
                          onDelete: () =>
                              _deleteClient(context, ref, clients[index].id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClientDialog(BuildContext context, WidgetRef ref, {ClientModel? client}) async {
    final nameController = TextEditingController(text: client?.name ?? '');
    final emailController = TextEditingController(text: client?.email ?? '');
    final phoneController = TextEditingController(text: client?.phone ?? '');
    final companyController = TextEditingController(text: client?.company ?? '');
    var status = client?.status ?? 'active';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(client == null ? 'Add Client' : 'Edit Client'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *')),
                const SizedBox(height: 12),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'active'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a client name')),
                  );
                  return;
                }
                final service = ref.read(dataServiceProvider);
                if (service == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('App data is not ready yet — try Demo Mode')),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  'company':
                      companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                  'status': status,
                };

                showDialog(
                  context: ctx,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                            SizedBox(width: 14),
                            Text('Creating client & related records…'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                try {
                  if (client == null) {
                    final created = await service.createClient(data);
                    await ensureClientRelatedRecords(service, created);
                    rememberClient(ref, created);

                    ref.invalidate(clientsProvider);
                    ref.invalidate(leadsProvider);
                    ref.invalidate(projectsProvider);
                    ref.invalidate(invoicesProvider);
                    ref.invalidate(paymentsProvider);
                    ref.invalidate(servicesProvider);
                    ref.invalidate(ticketsProvider);

                    // Wait until the clients list includes the new record.
                    await ref.read(clientsProvider.future);

                    if (ctx.mounted) {
                      Navigator.pop(ctx); // loading
                      Navigator.pop(ctx); // form
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${created.name} added — invoices, payments, services & more are linked',
                          ),
                        ),
                      );
                      context.go('/clients/${created.id}');
                    }
                  } else {
                    final updated = await service.updateClient(client.id, data);
                    rememberClient(ref, updated);
                    ref.invalidate(clientsProvider);
                    await ref.read(clientsProvider.future);
                    if (ctx.mounted) {
                      Navigator.pop(ctx); // loading
                      Navigator.pop(ctx); // form
                    }
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    Navigator.pop(ctx); // loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not save client: $e')),
                    );
                  }
                }
              },
              child: Text(client == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteClient(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client'),
        content: const Text('Are you sure you want to delete this client?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(dataServiceProvider)?.deleteClient(id);
        ref.invalidate(clientsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not delete client: $e')),
          );
        }
      }
    }
  }
}

class _ClientCard extends StatelessWidget {
  final ClientModel client;
  final String initials;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientCard({
    required this.client,
    required this.initials,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SoftTile(
      onTap: onOpen,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.brand.withOpacity(0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: AppTypography.display,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brand,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTypography.display,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      client.company?.isNotEmpty == true ? client.company! : 'No company',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: AppTypography.body,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: client.status, compact: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _contactLine(client),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
              height: 1.35,
              fontFamily: AppTypography.body,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: onOpen,
                child: const Text('Open hub'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _contactLine(ClientModel client) {
    final bits = <String>[
      if (client.email != null && client.email!.isNotEmpty) client.email!,
      if (client.phone != null && client.phone!.isNotEmpty) client.phone!,
    ];
    if (bits.isEmpty) return 'Open hub to manage invoices, payments & more';
    return bits.join(' · ');
  }
}
