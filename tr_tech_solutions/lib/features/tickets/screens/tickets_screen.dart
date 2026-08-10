import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/client_picker.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final ticketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getTickets();
});

class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Support Tickets',
            subtitle: 'Manage client support requests',
            action: ElevatedButton.icon(
              onPressed: () => _showTicketDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Ticket'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ticketsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(ticketsProvider)),
              data: (tickets) {
                if (tickets.isEmpty) {
                  return EmptyState(
                    icon: Icons.support_agent_outlined,
                    title: 'No tickets yet',
                    actionLabel: 'Create Ticket',
                    onAction: () => _showTicketDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Ticket #')),
                        DataColumn(label: Text('Subject')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: tickets.map((t) {
                        return DataRow(cells: [
                          DataCell(Text(t.ticketNumber)),
                          DataCell(Text(t.subject)),
                          DataCell(Text(t.clientName ?? '-')),
                          DataCell(StatusBadge(status: t.priority, compact: true)),
                          DataCell(StatusBadge(status: t.status, compact: true)),
                          DataCell(Text(Formatters.formatDate(t.createdAt))),
                          DataCell(Row(children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onSelected: (status) async {
                                await ref.read(dataServiceProvider)?.updateTicketStatus(t.id, status);
                                ref.invalidate(ticketsProvider);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'open', child: Text('Open')),
                                PopupMenuItem(value: 'in_progress', child: Text('In Progress')),
                                PopupMenuItem(value: 'resolved', child: Text('Resolved')),
                                PopupMenuItem(value: 'closed', child: Text('Closed')),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              onPressed: () async {
                                await ref.read(dataServiceProvider)?.deleteTicket(t.id);
                                ref.invalidate(ticketsProvider);
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

  Future<void> _showTicketDialog(BuildContext context, WidgetRef ref) async {
    final numberController = TextEditingController(text: 'TKT-${DateTime.now().millisecondsSinceEpoch % 10000}');
    final subjectController = TextEditingController();
    final descController = TextEditingController();
    var priority = 'medium';
    String? clientId;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create Ticket'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClientPickerField(
                    value: clientId,
                    onChanged: (v) => setState(() => clientId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Ticket Number *')),
                  const SizedBox(height: 12),
                  TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject *')),
                  const SizedBox(height: 12),
                  TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) => setState(() => priority = v ?? 'medium'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (subjectController.text.isEmpty || clientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a client and enter subject')),
                  );
                  return;
                }
                await ref.read(dataServiceProvider)?.createTicket({
                  'client_id': clientId,
                  'ticket_number': numberController.text.trim(),
                  'subject': subjectController.text.trim(),
                  'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
                  'priority': priority,
                });
                ref.invalidate(ticketsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
