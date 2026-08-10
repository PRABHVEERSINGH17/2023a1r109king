import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';
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
      padding: AppBreakpoints.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Support Tickets',
            subtitle: 'Manage client support requests',
            action: ElevatedButton.icon(
              onPressed: () => showLinkedTicketDialog(context, ref),
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
                    onAction: () => showLinkedTicketDialog(context, ref),
                  );
                }

                Widget statusMenu(TicketModel t) => PopupMenuButton<String>(
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
                    );

                Widget deleteBtn(TicketModel t) => IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () async {
                        await ref.read(dataServiceProvider)?.deleteTicket(t.id);
                        ref.invalidate(ticketsProvider);
                      },
                    );

                return ResponsiveRecordList(
                  table: DataTable(
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
                        DataCell(Row(children: [statusMenu(t), deleteBtn(t)])),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = tickets[index];
                      return MobileRecordTile(
                        title: t.subject,
                        subtitle:
                            '${t.ticketNumber} · ${t.clientName ?? 'No client'} · ${Formatters.formatDate(t.createdAt)}',
                        badge: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            StatusBadge(status: t.priority, compact: true),
                            StatusBadge(status: t.status, compact: true),
                          ],
                        ),
                        actions: [statusMenu(t), deleteBtn(t)],
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
}
