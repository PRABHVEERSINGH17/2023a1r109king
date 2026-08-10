import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final leadsProvider = FutureProvider<List<LeadModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getLeads();
});

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Leads',
            subtitle: 'Track your sales pipeline',
            action: ElevatedButton.icon(
              onPressed: () => _showLeadDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Lead'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: leadsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(leadsProvider)),
              data: (leads) {
                if (leads.isEmpty) {
                  return EmptyState(
                    icon: Icons.trending_up_outlined,
                    title: 'No leads yet',
                    actionLabel: 'Add Lead',
                    onAction: () => _showLeadDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Company')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Value')),
                        DataColumn(label: Text('Stage')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: leads.map((lead) {
                        return DataRow(cells: [
                          DataCell(Text(lead.name)),
                          DataCell(Text(lead.company ?? '-')),
                          DataCell(Text(lead.email ?? '-')),
                          DataCell(Text(Formatters.formatCurrency(lead.value))),
                          DataCell(StatusBadge(status: lead.stage, compact: true)),
                          DataCell(Row(children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onSelected: (stage) async {
                                await ref.read(dataServiceProvider)?.updateLeadStage(lead.id, stage);
                                ref.invalidate(leadsProvider);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'new', child: Text('New')),
                                PopupMenuItem(value: 'contacted', child: Text('Contacted')),
                                PopupMenuItem(value: 'proposal', child: Text('Proposal')),
                                PopupMenuItem(value: 'negotiation', child: Text('Negotiation')),
                                PopupMenuItem(value: 'won', child: Text('Won')),
                                PopupMenuItem(value: 'lost', child: Text('Lost')),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              onPressed: () async {
                                await ref.read(dataServiceProvider)?.deleteLead(lead.id);
                                ref.invalidate(leadsProvider);
                              },
                            ),
                          ])),
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

  Future<void> _showLeadDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final valueController = TextEditingController();
    var stage = 'new';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Lead'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *')),
                const SizedBox(height: 12),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
                const SizedBox(height: 12),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Value', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: stage,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  items: const [
                    DropdownMenuItem(value: 'new', child: Text('New')),
                    DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                    DropdownMenuItem(value: 'proposal', child: Text('Proposal Sent')),
                    DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                  ],
                  onChanged: (v) => setState(() => stage = v ?? 'new'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                await ref.read(dataServiceProvider)?.createLead({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  'company': companyController.text.trim().isEmpty ? null : companyController.text.trim(),
                  'value': double.tryParse(valueController.text) ?? 0,
                  'stage': stage,
                });
                ref.invalidate(leadsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
