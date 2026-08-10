import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:tr_tech_solutions/shared/models/client.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final isDemo = ref.watch(demoModeProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Clients',
            subtitle: isDemo
                ? 'Add a client → lead, invoice, payment & more are created automatically'
                : 'Add a client → related lead, project, invoice, payment, service & ticket are created',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(clientsProvider),
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showClientDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Client'),
                ),
              ],
            ),
          ),
          if (isDemo) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.35)),
              ),
              child: const Text(
                'Demo Mode: Add a client and related lead/project/invoice/payment/service/ticket are created automatically.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),
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
                return DataListCard(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Company')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: clients.map((client) {
                                return DataRow(
                                  onSelectChanged: (_) => context.go('/clients/${client.id}'),
                                  cells: [
                                  DataCell(
                                    Text(client.name),
                                    onTap: () => context.go('/clients/${client.id}'),
                                  ),
                                  DataCell(Text(client.email ?? '-')),
                                  DataCell(Text(client.phone ?? '-')),
                                  DataCell(Text(client.company ?? '-')),
                                  DataCell(StatusBadge(status: client.status, compact: true)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Open client hub',
                                        icon: const Icon(Icons.open_in_new, size: 18),
                                        onPressed: () => context.go('/clients/${client.id}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 18),
                                        onPressed: () =>
                                            _showClientDialog(context, ref, client: client),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                        onPressed: () => _deleteClient(context, ref, client.id),
                                      ),
                                    ],
                                  )),
                                ],
                                );
                              }).toList(),
                            ),
                          ),
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
                if (nameController.text.isEmpty) return;
                final service = ref.read(dataServiceProvider);
                if (service == null) return;

                final data = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                  'company': companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                  'status': status,
                };

                try {
                  if (client == null) {
                    await service.createClient(data);
                    ref.invalidate(clientsProvider);
                    // Related modules are auto-created with the client.
                    ref.invalidate(leadsProvider);
                    ref.invalidate(projectsProvider);
                    ref.invalidate(invoicesProvider);
                    ref.invalidate(paymentsProvider);
                    ref.invalidate(servicesProvider);
                    ref.invalidate(ticketsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Client created — lead, project, invoice, payment, service & ticket were added automatically',
                          ),
                        ),
                      );
                    }
                  } else {
                    await service.updateClient(client.id, data);
                    ref.invalidate(clientsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                } catch (e) {
                  if (ctx.mounted) {
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
