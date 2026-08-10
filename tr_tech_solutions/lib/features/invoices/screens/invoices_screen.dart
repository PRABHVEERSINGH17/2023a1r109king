import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final invoicesProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getInvoices();
});

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Invoices',
            subtitle: 'Manage billing and invoices',
            action: ElevatedButton.icon(
              onPressed: () => showLinkedInvoiceDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Invoice'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: invoicesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(invoicesProvider)),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No invoices yet',
                    actionLabel: 'Create Invoice',
                    onAction: () => showLinkedInvoiceDialog(context, ref),
                  );
                }

                Widget deleteBtn(InvoiceModel inv) => IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () async {
                        await ref.read(dataServiceProvider)?.deleteInvoice(inv.id);
                        ref.invalidate(invoicesProvider);
                      },
                    );

                return ResponsiveRecordList(
                  table: DataTable(
                    columns: const [
                      DataColumn(label: Text('Invoice #')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: invoices.map((inv) {
                      return DataRow(cells: [
                        DataCell(Text(inv.invoiceNumber)),
                        DataCell(Text(inv.clientName ?? '-')),
                        DataCell(Text(Formatters.formatCurrency(inv.total))),
                        DataCell(StatusBadge(status: inv.status, compact: true)),
                        DataCell(Text(Formatters.formatDate(inv.dueDate))),
                        DataCell(deleteBtn(inv)),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final inv = invoices[index];
                      return MobileRecordTile(
                        title: inv.invoiceNumber,
                        subtitle:
                            '${inv.clientName ?? 'No client'} · ${Formatters.formatCurrency(inv.total)} · Due ${Formatters.formatDate(inv.dueDate)}',
                        badge: StatusBadge(status: inv.status, compact: true),
                        actions: [deleteBtn(inv)],
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
