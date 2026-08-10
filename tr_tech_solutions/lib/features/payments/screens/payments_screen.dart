import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/client_picker.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

final paymentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getPayments();
});

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Payments',
            subtitle: 'Track received payments',
            action: ElevatedButton.icon(
              onPressed: () => _showPaymentDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Record Payment'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: paymentsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(paymentsProvider)),
              data: (payments) {
                if (payments.isEmpty) {
                  return EmptyState(
                    icon: Icons.payment_outlined,
                    title: 'No payments recorded',
                    actionLabel: 'Record Payment',
                    onAction: () => _showPaymentDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Method')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Reference')),
                        DataColumn(label: Text('Date')),
                      ],
                      rows: payments.map((p) {
                        final clientName = p['clients'] != null
                            ? (p['clients'] as Map)['name'] as String?
                            : null;
                        return DataRow(cells: [
                          DataCell(Text(Formatters.formatCurrency((p['amount'] as num).toDouble()))),
                          DataCell(Text(p['method'] as String? ?? '-')),
                          DataCell(Text(clientName ?? '-')),
                          DataCell(Text(p['reference'] as String? ?? '-')),
                          DataCell(Text(Formatters.formatDate(
                              p['paid_at'] != null ? DateTime.parse(p['paid_at'] as String) : null))),
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

  Future<void> _showPaymentDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    var method = 'bank_transfer';
    String? clientId;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Record Payment'),
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
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount *', prefixText: '₹ '),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: method,
                    decoration: const InputDecoration(labelText: 'Method'),
                    items: const [
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI')),
                      DropdownMenuItem(value: 'cash', child: Text('Cash')),
                      DropdownMenuItem(value: 'card', child: Text('Card')),
                      DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    ],
                    onChanged: (v) => setState(() => method = v ?? 'bank_transfer'),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: referenceController, decoration: const InputDecoration(labelText: 'Reference')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isEmpty || clientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a client and enter amount')),
                  );
                  return;
                }
                await ref.read(dataServiceProvider)?.createPayment({
                  'client_id': clientId,
                  'amount': double.tryParse(amountController.text) ?? 0,
                  'method': method,
                  'reference': referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                });
                ref.invalidate(paymentsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }
}
