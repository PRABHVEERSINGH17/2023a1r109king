import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';
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
      padding: AppBreakpoints.pagePadding(context),
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

                Widget stageMenu(LeadModel lead) => PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 18),
                      onSelected: (stage) async {
                        await ref.read(dataServiceProvider)?.updateLeadStage(lead.id, stage);
                        ref.invalidate(leadsProvider);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'contacted', child: Text('Contacted')),
                        PopupMenuItem(value: 'negotiation', child: Text('Negotiation')),
                        PopupMenuItem(value: 'won', child: Text('Won')),
                        PopupMenuItem(value: 'lost', child: Text('Lost')),
                      ],
                    );

                Widget deleteBtn(LeadModel lead) => IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () async {
                        await ref.read(dataServiceProvider)?.deleteLead(lead.id);
                        ref.invalidate(leadsProvider);
                      },
                    );

                return ResponsiveRecordList(
                  table: DataTable(
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
                        DataCell(Row(children: [stageMenu(lead), deleteBtn(lead)])),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: leads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final lead = leads[index];
                      return MobileRecordTile(
                        title: lead.name,
                        subtitle: [
                          if (lead.company != null && lead.company!.isNotEmpty) lead.company!,
                          if (lead.email != null && lead.email!.isNotEmpty) lead.email!,
                          Formatters.formatCurrency(lead.value),
                        ].join(' · '),
                        badge: StatusBadge(status: lead.stage, compact: true),
                        actions: [stageMenu(lead), deleteBtn(lead)],
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

  Future<void> _showLeadDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final companyController = TextEditingController();
    final valueController = TextEditingController();
    var stage = 'contacted';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Add Lead'),
          content: responsiveDialogBody(
            ctx,
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
                    DropdownMenuItem(value: 'contacted', child: Text('Contacted')),
                    DropdownMenuItem(value: 'negotiation', child: Text('Negotiation')),
                    DropdownMenuItem(value: 'won', child: Text('Won')),
                    DropdownMenuItem(value: 'lost', child: Text('Lost')),
                  ],
                  onChanged: (v) => setState(() => stage = v ?? 'contacted'),
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
