import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/app_repository.dart';

class ClientBootstrapResult {
  final int createdCount;
  final List<String> createdTypes;
  final List<String> errors;

  const ClientBootstrapResult({
    required this.createdCount,
    required this.createdTypes,
    required this.errors,
  });

  bool get ok => createdCount > 0;
}

/// Creates linked starter records for a client (lead/project/service/invoice/payment/ticket).
/// Each type is created independently so one failure does not block the others.
Future<ClientBootstrapResult> bootstrapRelatedRecordsForClient(
  AppRepository repo,
  ClientModel client,
) async {
  final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
  final label = (client.company != null && client.company!.trim().isNotEmpty)
      ? client.company!.trim()
      : client.name;
  final due = DateTime.now().add(const Duration(days: 30));
  final expiry = DateTime.now().add(const Duration(days: 365));
  final dueStr = due.toIso8601String().split('T').first;
  final expiryStr = expiry.toIso8601String().split('T').first;

  final created = <String>[];
  final errors = <String>[];
  String? invoiceId;

  Future<void> step(String type, Future<void> Function() action) async {
    try {
      await action();
      created.add(type);
    } catch (e) {
      errors.add('$type: $e');
    }
  }

  await step('lead', () async {
    await repo.createLead({
      'client_id': client.id,
      'name': client.name,
      'email': client.email,
      'phone': client.phone,
      'company': client.company,
      'stage': 'won',
      'value': 25000,
      'source': 'client_signup',
      'notes': 'Auto-created when client was added',
    });
  });

  await step('project', () async {
    await repo.createProject({
      'client_id': client.id,
      'title': '$label Onboarding',
      'description': 'Starter project created with this client',
      'budget': 25000,
      'status': 'in_progress',
      'due_date': dueStr,
    });
  });

  await step('service', () async {
    await repo.createService({
      'client_id': client.id,
      'name': '$label Hosting',
      'type': 'hosting',
      'provider': 'TR Tech',
      'expiry_date': expiryStr,
      'status': 'active',
    });
  });

  await step('invoice', () async {
    // Do not send `total` — Supabase generates it from amount + tax.
    final invoice = await repo.createInvoice({
      'client_id': client.id,
      'invoice_number': 'INV-$stamp',
      'amount': 10000,
      'tax': 0,
      'status': 'pending',
      'due_date': dueStr,
      'notes': 'Starter invoice created with this client',
    });
    invoiceId = invoice.id;
  });

  await step('payment', () async {
    await repo.createPayment({
      'client_id': client.id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      'amount': 5000,
      'method': 'upi',
      'reference': 'AUTO-$stamp',
    });
  });

  await step('ticket', () async {
    await repo.createTicket({
      'client_id': client.id,
      'ticket_number': 'TKT-$stamp',
      'subject': 'Welcome & onboarding',
      'description': 'Auto-created support ticket for new client setup',
      'priority': 'medium',
      'status': 'open',
    });
  });

  return ClientBootstrapResult(
    createdCount: created.length,
    createdTypes: created,
    errors: errors,
  );
}

/// If this client is missing any linked module records, create the missing ones.
Future<ClientBootstrapResult> ensureClientRelatedRecords(
  AppRepository repo,
  ClientModel client,
) async {
  final leads =
      (await repo.getLeads()).where((l) => l.clientId == client.id).toList();
  final projects =
      (await repo.getProjects()).where((p) => p.clientId == client.id).toList();
  final services =
      (await repo.getServices()).where((s) => s.clientId == client.id).toList();
  final invoices =
      (await repo.getInvoices()).where((i) => i.clientId == client.id).toList();
  final tickets =
      (await repo.getTickets()).where((t) => t.clientId == client.id).toList();
  final payments = (await repo.getPayments())
      .where((p) => p['client_id']?.toString() == client.id)
      .toList();

  // Fully empty → create the full starter pack.
  if (leads.isEmpty &&
      projects.isEmpty &&
      services.isEmpty &&
      invoices.isEmpty &&
      tickets.isEmpty &&
      payments.isEmpty) {
    return bootstrapRelatedRecordsForClient(repo, client);
  }

  // Partial → fill only missing modules.
  final stamp = DateTime.now().millisecondsSinceEpoch % 100000;
  final label = (client.company != null && client.company!.trim().isNotEmpty)
      ? client.company!.trim()
      : client.name;
  final dueStr = DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T').first;
  final expiryStr =
      DateTime.now().add(const Duration(days: 365)).toIso8601String().split('T').first;

  final created = <String>[];
  final errors = <String>[];
  String? invoiceId = invoices.isNotEmpty ? invoices.first.id : null;

  Future<void> step(String type, Future<void> Function() action) async {
    try {
      await action();
      created.add(type);
    } catch (e) {
      errors.add('$type: $e');
    }
  }

  if (leads.isEmpty) {
    await step('lead', () async {
      await repo.createLead({
        'client_id': client.id,
        'name': client.name,
        'email': client.email,
        'phone': client.phone,
        'company': client.company,
        'stage': 'won',
        'value': 25000,
        'source': 'client_signup',
      });
    });
  }
  if (projects.isEmpty) {
    await step('project', () async {
      await repo.createProject({
        'client_id': client.id,
        'title': '$label Onboarding',
        'budget': 25000,
        'status': 'in_progress',
        'due_date': dueStr,
      });
    });
  }
  if (services.isEmpty) {
    await step('service', () async {
      await repo.createService({
        'client_id': client.id,
        'name': '$label Hosting',
        'type': 'hosting',
        'provider': 'TR Tech',
        'expiry_date': expiryStr,
        'status': 'active',
      });
    });
  }
  if (invoices.isEmpty) {
    await step('invoice', () async {
      final invoice = await repo.createInvoice({
        'client_id': client.id,
        'invoice_number': 'INV-$stamp',
        'amount': 10000,
        'tax': 0,
        'status': 'pending',
        'due_date': dueStr,
      });
      invoiceId = invoice.id;
    });
  }
  if (payments.isEmpty) {
    await step('payment', () async {
      await repo.createPayment({
        'client_id': client.id,
        if (invoiceId != null) 'invoice_id': invoiceId,
        'amount': 5000,
        'method': 'upi',
        'reference': 'AUTO-$stamp',
      });
    });
  }
  if (tickets.isEmpty) {
    await step('ticket', () async {
      await repo.createTicket({
        'client_id': client.id,
        'ticket_number': 'TKT-$stamp',
        'subject': 'Welcome & onboarding',
        'priority': 'medium',
        'status': 'open',
      });
    });
  }

  return ClientBootstrapResult(
    createdCount: created.length,
    createdTypes: created,
    errors: errors,
  );
}
