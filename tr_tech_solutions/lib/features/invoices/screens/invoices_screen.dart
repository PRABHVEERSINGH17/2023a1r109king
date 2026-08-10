import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Invoices',
            subtitle: 'Manage billing and invoices',
            action: ElevatedButton.icon(
              onPressed: () => _showInvoiceDialog(context, ref),
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
                    onAction: () => _showInvoiceDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
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
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () async {
                              await ref.read(dataServiceProvider)?.deleteInvoice(inv.id);
                              ref.invalidate(invoicesProvider);
                            },
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

  Future<void> _showInvoiceDialog(BuildContext context, WidgetRef ref) async {
    final numberController = TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch % 10000}');
    final amountController = TextEditingController();
    var status = 'pending';
    DateTime? dueDate = DateTime.now().add(const Duration(days: 30));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create Invoice'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Invoice Number *')),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount *', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'pending'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Due: ${Formatters.formatDate(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => dueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (numberController.text.isEmpty || amountController.text.isEmpty) return;
                await ref.read(dataServiceProvider)?.createInvoice({
                  'invoice_number': numberController.text.trim(),
                  'amount': double.tryParse(amountController.text) ?? 0,
                  'status': status,
                  'due_date': dueDate?.toIso8601String().split('T').first,
                });
                ref.invalidate(invoicesProvider);
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
