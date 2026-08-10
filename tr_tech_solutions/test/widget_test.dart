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
    });
    expect(created.name, 'Test Client');

    final afterCreate = await repo.getClients();
    expect(afterCreate.length, before.length + 1);

    await repo.deleteClient(created.id);
    final afterDelete = await repo.getClients();
    expect(afterDelete.length, before.length);
  });
}
