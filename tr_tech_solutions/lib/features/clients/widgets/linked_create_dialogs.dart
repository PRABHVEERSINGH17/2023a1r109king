import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/client_picker.dart';

String _lockedClientLabel(WidgetRef ref, String clientId) {
  final clients = ref.read(clientsProvider).valueOrNull ?? const [];
  for (final c in clients) {
    if (c.id == clientId) {
      if (c.company != null && c.company!.isNotEmpty) {
        return '${c.name} · ${c.company}';
      }
      return c.name;
    }
  }
  return 'Selected client';
}

Future<void> showLinkedProjectDialog(
  BuildContext context,
  WidgetRef ref, {
  String? clientId,
}) async {
  final titleController = TextEditingController();
  final budgetController = TextEditingController();
  var status = 'in_progress';
  var selectedClientId = clientId;
  DateTime? dueDate;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Add Project'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(ctx).width - 48).clamp(260.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clientId == null)
                  ClientPickerField(
                    value: selectedClientId,
                    onChanged: (v) => setState(() => selectedClientId = v),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Client'),
                    child: Text(_lockedClientLabel(ref, clientId)),
                  ),
                const SizedBox(height: 12),
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title *')),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget', prefixText: '₹ '),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'planning', child: Text('Planning')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'review', child: Text('Review')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'in_progress'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(dueDate == null ? 'Select Due Date' : 'Due: ${Formatters.formatDate(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => dueDate = date);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || selectedClientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a client and enter a title')),
                );
                return;
              }
              await ref.read(dataServiceProvider)?.createProject({
                'client_id': selectedClientId,
                'title': titleController.text.trim(),
                'budget': double.tryParse(budgetController.text) ?? 0,
                'status': status,
                'due_date': dueDate?.toIso8601String().split('T').first,
              });
              ref.invalidate(projectsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showLinkedInvoiceDialog(
  BuildContext context,
  WidgetRef ref, {
  String? clientId,
}) async {
  final numberController =
      TextEditingController(text: 'INV-${DateTime.now().millisecondsSinceEpoch % 10000}');
  final amountController = TextEditingController();
  var status = 'pending';
  var selectedClientId = clientId;
  DateTime? dueDate = DateTime.now().add(const Duration(days: 30));

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Create Invoice'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(ctx).width - 48).clamp(260.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clientId == null)
                  ClientPickerField(
                    value: selectedClientId,
                    onChanged: (v) => setState(() => selectedClientId = v),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Client'),
                    child: Text(_lockedClientLabel(ref, clientId)),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Invoice Number *'),
                ),
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
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (numberController.text.isEmpty ||
                  amountController.text.isEmpty ||
                  selectedClientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a client and fill invoice details')),
                );
                return;
              }
              await ref.read(dataServiceProvider)?.createInvoice({
                'client_id': selectedClientId,
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

Future<void> showLinkedPaymentDialog(
  BuildContext context,
  WidgetRef ref, {
  String? clientId,
}) async {
  final amountController = TextEditingController();
  final referenceController = TextEditingController();
  var method = 'bank_transfer';
  var selectedClientId = clientId;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Record Payment'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(ctx).width - 48).clamp(260.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clientId == null)
                  ClientPickerField(
                    value: selectedClientId,
                    onChanged: (v) => setState(() => selectedClientId = v),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Client'),
                    child: Text(_lockedClientLabel(ref, clientId)),
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
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(labelText: 'Reference'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty || selectedClientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a client and enter amount')),
                );
                return;
              }
              await ref.read(dataServiceProvider)?.createPayment({
                'client_id': selectedClientId,
                'amount': double.tryParse(amountController.text) ?? 0,
                'method': method,
                'reference':
                    referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
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

Future<void> showLinkedServiceDialog(
  BuildContext context,
  WidgetRef ref, {
  String? clientId,
}) async {
  final nameController = TextEditingController();
  final providerController = TextEditingController();
  var type = 'domain';
  var status = 'active';
  var selectedClientId = clientId;
  DateTime? expiryDate;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Add Service'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(ctx).width - 48).clamp(260.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clientId == null)
                  ClientPickerField(
                    value: selectedClientId,
                    onChanged: (v) => setState(() => selectedClientId = v),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Client'),
                    child: Text(_lockedClientLabel(ref, clientId)),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'domain', child: Text('Domain')),
                    DropdownMenuItem(value: 'hosting', child: Text('Hosting')),
                    DropdownMenuItem(value: 'website', child: Text('Website')),
                    DropdownMenuItem(value: 'ssl', child: Text('SSL Certificate')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? 'domain'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: providerController,
                  decoration: const InputDecoration(labelText: 'Provider'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    expiryDate == null ? 'Select Expiry Date' : Formatters.formatDate(expiryDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) setState(() => expiryDate = date);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'expiring', child: Text('Expiring')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (v) => setState(() => status = v ?? 'active'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || selectedClientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a client and enter service name')),
                );
                return;
              }
              await ref.read(dataServiceProvider)?.createService({
                'client_id': selectedClientId,
                'name': nameController.text.trim(),
                'type': type,
                'provider':
                    providerController.text.trim().isEmpty ? null : providerController.text.trim(),
                'expiry_date': expiryDate?.toIso8601String().split('T').first,
                'status': status,
              });
              ref.invalidate(servicesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showLinkedTicketDialog(
  BuildContext context,
  WidgetRef ref, {
  String? clientId,
}) async {
  final numberController =
      TextEditingController(text: 'TKT-${DateTime.now().millisecondsSinceEpoch % 10000}');
  final subjectController = TextEditingController();
  final descController = TextEditingController();
  var priority = 'medium';
  var selectedClientId = clientId;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Create Ticket'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(ctx).width - 48).clamp(260.0, 420.0),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clientId == null)
                  ClientPickerField(
                    value: selectedClientId,
                    onChanged: (v) => setState(() => selectedClientId = v),
                  )
                else
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Client'),
                    child: Text(_lockedClientLabel(ref, clientId)),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Ticket Number *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
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
              if (subjectController.text.isEmpty || selectedClientId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select a client and enter subject')),
                );
                return;
              }
              await ref.read(dataServiceProvider)?.createTicket({
                'client_id': selectedClientId,
                'ticket_number': numberController.text.trim(),
                'subject': subjectController.text.trim(),
                'description':
                    descController.text.trim().isEmpty ? null : descController.text.trim(),
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
