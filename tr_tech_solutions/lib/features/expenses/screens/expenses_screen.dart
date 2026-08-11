import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';

final expensesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getExpenses();
});

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Expenses',
            subtitle: 'Track business expenses',
            action: ElevatedButton.icon(
              onPressed: () => _showExpenseDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Expense'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: expensesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(expensesProvider)),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return EmptyState(
                    icon: Icons.money_off_outlined,
                    title: 'No expenses recorded',
                    actionLabel: 'Add Expense',
                    onAction: () => _showExpenseDialog(context, ref),
                  );
                }

                return ResponsiveRecordList(
                  table: DataTable(
                    columns: const [
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Vendor')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: expenses.map((e) {
                      return DataRow(cells: [
                        DataCell(Text(e['description'] as String? ?? '-')),
                        DataCell(Text(e['category'] as String? ?? '-')),
                        DataCell(Text(Formatters.formatCurrency((e['amount'] as num).toDouble()))),
                        DataCell(Text(e['vendor'] as String? ?? '-')),
                        DataCell(Text(Formatters.formatDate(
                            e['expense_date'] != null ? DateTime.parse(e['expense_date'] as String) : null))),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: expenses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final e = expenses[index];
                      return MobileRecordTile(
                        title: e['description'] as String? ?? 'Expense',
                        subtitle: [
                          e['category'] as String? ?? '-',
                          Formatters.formatCurrency((e['amount'] as num).toDouble()),
                          if ((e['vendor'] as String?)?.isNotEmpty == true) e['vendor'] as String,
                          Formatters.formatDate(
                              e['expense_date'] != null ? DateTime.parse(e['expense_date'] as String) : null),
                        ].join(' · '),
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

  Future<void> _showExpenseDialog(BuildContext context, WidgetRef ref) async {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final vendorController = TextEditingController();
    var category = 'other';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Text('Add Expense'),
          content: responsiveDialogBody(
            ctx,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description *')),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount *', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'hosting', child: Text('Hosting')),
                    DropdownMenuItem(value: 'domain', child: Text('Domain')),
                    DropdownMenuItem(value: 'software', child: Text('Software')),
                    DropdownMenuItem(value: 'salary', child: Text('Salary')),
                    DropdownMenuItem(value: 'marketing', child: Text('Marketing')),
                    DropdownMenuItem(value: 'office', child: Text('Office')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => category = v ?? 'other'),
                ),
                const SizedBox(height: 12),
                TextField(controller: vendorController, decoration: const InputDecoration(labelText: 'Vendor')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (descController.text.isEmpty || amountController.text.isEmpty) return;
                await ref.read(dataServiceProvider)?.createExpense({
                  'description': descController.text.trim(),
                  'amount': double.tryParse(amountController.text) ?? 0,
                  'category': category,
                  'vendor': vendorController.text.trim().isEmpty ? null : vendorController.text.trim(),
                });
                ref.invalidate(expensesProvider);
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
