import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/app_repository.dart';

/// When a client is created, automatically seed linked starter records
/// (lead, project, service, invoice, payment, ticket) for that client.
Future<void> bootstrapRelatedRecordsForClient(
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

  await repo.createProject({
    'client_id': client.id,
    'title': '$label Onboarding',
    'description': 'Starter project created with this client',
    'budget': 25000,
    'status': 'planning',
    'due_date': dueStr,
  });

  await repo.createService({
    'client_id': client.id,
    'name': '$label Hosting',
    'type': 'hosting',
    'provider': 'TR Tech',
    'expiry_date': expiryStr,
    'status': 'active',
  });

  final invoice = await repo.createInvoice({
    'client_id': client.id,
    'invoice_number': 'INV-$stamp',
    'amount': 10000,
    'total': 10000,
    'status': 'pending',
    'due_date': dueStr,
    'notes': 'Starter invoice created with this client',
  });

  await repo.createPayment({
    'client_id': client.id,
    'invoice_id': invoice.id,
    'amount': 5000,
    'method': 'upi',
    'reference': 'AUTO-$stamp',
  });

  await repo.createTicket({
    'client_id': client.id,
    'ticket_number': 'TKT-$stamp',
    'subject': 'Welcome & onboarding',
    'description': 'Auto-created support ticket for new client setup',
    'priority': 'medium',
    'status': 'open',
  });
}
