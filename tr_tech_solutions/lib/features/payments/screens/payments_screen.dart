import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';

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
      padding: AppBreakpoints.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Payments',
            subtitle: 'Track received payments',
            action: ElevatedButton.icon(
              onPressed: () => showLinkedPaymentDialog(context, ref),
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
                    onAction: () => showLinkedPaymentDialog(context, ref),
                  );
                }

                String? clientNameOf(Map<String, dynamic> p) => p['clients'] != null
                    ? (p['clients'] as Map)['name'] as String?
                    : null;

                return ResponsiveRecordList(
                  table: DataTable(
                    columns: const [
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Method')),
                      DataColumn(label: Text('Client')),
                      DataColumn(label: Text('Reference')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: payments.map((p) {
                      return DataRow(cells: [
                        DataCell(Text(Formatters.formatCurrency((p['amount'] as num).toDouble()))),
                        DataCell(Text(p['method'] as String? ?? '-')),
                        DataCell(Text(clientNameOf(p) ?? '-')),
                        DataCell(Text(p['reference'] as String? ?? '-')),
                        DataCell(Text(Formatters.formatDate(
                            p['paid_at'] != null ? DateTime.parse(p['paid_at'] as String) : null))),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = payments[index];
                      final amount = Formatters.formatCurrency((p['amount'] as num).toDouble());
                      final method = p['method'] as String? ?? '-';
                      final refText = p['reference'] as String? ?? '-';
                      final date = Formatters.formatDate(
                          p['paid_at'] != null ? DateTime.parse(p['paid_at'] as String) : null);
                      return MobileRecordTile(
                        title: amount,
                        subtitle: '${clientNameOf(p) ?? 'No client'} · $method · $refText · $date',
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
