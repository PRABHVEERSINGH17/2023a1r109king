import 'package:flutter_test/flutter_test.dart';
import 'package:tr_tech_solutions/shared/services/demo_repository.dart';

void main() {
  test('demo repository returns seeded clients and stats', () async {
    final repo = DemoRepository();
    final clients = await repo.getClients();
    final stats = await repo.getDashboardStats();
    final invoices = await repo.getInvoices();
    final leads = await repo.getLeads();
    final services = await repo.getServices();
    final tickets = await repo.getTickets();

    expect(clients.length, greaterThanOrEqualTo(4));
    expect(stats.totalClients, greaterThan(0));
    expect(stats.totalRevenue, greaterThan(0));
    expect(invoices, isNotEmpty);
    expect(leads, isNotEmpty);
    expect(services, isNotEmpty);
    expect(tickets, isNotEmpty);
  });

  test('demo repository supports CRUD for clients', () async {
    final repo = DemoRepository();
    final before = await repo.getClients();

    final created = await repo.createClient({
      'name': 'Test Client',
      'email': 'test@example.com',
      'status': 'active',
      'bootstrap_related': false,
    });
    expect(created.name, 'Test Client');

    final afterCreate = await repo.getClients();
    expect(afterCreate.length, before.length + 1);

    await repo.deleteClient(created.id);
    final afterDelete = await repo.getClients();
    expect(afterDelete.length, before.length);
  });

  test('creating a client auto-creates lead and related records', () async {
    final repo = DemoRepository();
    final client = await repo.createClient({
      'name': 'Auto Client',
      'email': 'auto@example.com',
      'company': 'Auto Co',
      'status': 'active',
    });

    final leads = await repo.getLeads();
    final projects = await repo.getProjects();
    final invoices = await repo.getInvoices();
    final services = await repo.getServices();
    final tickets = await repo.getTickets();
    final payments = await repo.getPayments();

    expect(leads.where((l) => l.clientId == client.id), isNotEmpty);
    expect(projects.where((p) => p.clientId == client.id), isNotEmpty);
    expect(invoices.where((i) => i.clientId == client.id), isNotEmpty);
    expect(services.where((s) => s.clientId == client.id), isNotEmpty);
    expect(tickets.where((t) => t.clientId == client.id), isNotEmpty);
    expect(payments.where((p) => p['client_id'] == client.id), isNotEmpty);

    final lead = leads.firstWhere((l) => l.clientId == client.id);
    expect(lead.name, 'Auto Client');
    expect(lead.stage, 'won');
  });

  test('creating project/payment/invoice links to client', () async {
    final repo = DemoRepository();
    final client = await repo.createClient({
      'name': 'Linked Client',
      'status': 'active',
      'bootstrap_related': false,
    });

    final project = await repo.createProject({
      'client_id': client.id,
      'title': 'Website Redesign',
      'budget': 50000,
      'status': 'in_progress',
    });
    expect(project.clientId, client.id);
    expect(project.clientName, 'Linked Client');

    final invoice = await repo.createInvoice({
      'client_id': client.id,
      'invoice_number': 'INV-TEST-1',
      'amount': 10000,
      'status': 'pending',
    });
    expect(invoice.clientId, client.id);
    expect(invoice.clientName, 'Linked Client');

    await repo.createPayment({
      'client_id': client.id,
      'amount': 10000,
      'method': 'upi',
      'reference': 'UPI-1',
    });
    final payments = await repo.getPayments();
    final linked = payments.firstWhere((p) => p['client_id'] == client.id);
    expect(linked['clients']['name'], 'Linked Client');
  });
}
