import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final clientsProvider = FutureProvider<List<ClientModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getClients();
});

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Clients',
            subtitle: 'Manage your client relationships',
            action: ElevatedButton.icon(
              onPressed: () => _showClientDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Client'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: clientsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(clientsProvider),
              ),
              data: (clients) {
                if (clients.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No clients yet',
                    subtitle: 'Add your first client to get started',
                    actionLabel: 'Add Client',
                    onAction: () => _showClientDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                        return DataRow(cells: [
                          DataCell(Text(client.name)),
                          DataCell(Text(client.email ?? '-')),
                          DataCell(Text(client.phone ?? '-')),
                          DataCell(Text(client.company ?? '-')),
                          DataCell(StatusBadge(status: client.status, compact: true)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _showClientDialog(context, ref, client: client),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                onPressed: () => _deleteClient(context, ref, client.id),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
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

                if (client == null) {
                  await service.createClient(data);
                } else {
                  await service.updateClient(client.id, data);
                }

                ref.invalidate(clientsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
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
      await ref.read(dataServiceProvider)?.deleteClient(id);
      ref.invalidate(clientsProvider);
    }
  }
}
