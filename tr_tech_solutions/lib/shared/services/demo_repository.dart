import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/models/dashboard_stats.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';
import 'package:tr_tech_solutions/shared/services/app_repository.dart';
import 'package:uuid/uuid.dart';

class DemoRepository implements AppRepository {
  final _uuid = const Uuid();
  static const _userId = 'demo-user-001';

  late final List<ClientModel> _clients;
  late final List<ServiceModel> _services;
  late final List<InvoiceModel> _invoices;
  late final List<LeadModel> _leads;
  late final List<ProjectModel> _projects;
  late final List<TicketModel> _tickets;
  late final List<Map<String, dynamic>> _expenses;
  late final List<Map<String, dynamic>> _payments;

  DemoRepository() {
    _seed();
  }

  void _seed() {
    final now = DateTime.now();

    _clients = [
      ClientModel(
        id: 'c1',
        userId: _userId,
        name: 'Acme Corporation',
        email: 'contact@acme.com',
        phone: '+91 98765 43210',
        company: 'Acme Corp',
        status: 'active',
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      ClientModel(
        id: 'c2',
        userId: _userId,
        name: 'TechStart India',
        email: 'hello@techstart.in',
        phone: '+91 98123 45678',
        company: 'TechStart Pvt Ltd',
        status: 'active',
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      ClientModel(
        id: 'c3',
        userId: _userId,
        name: 'Global Softwares',
        email: 'info@globalsoft.com',
        phone: '+91 99887 76655',
        company: 'Global Softwares',
        status: 'active',
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      ClientModel(
        id: 'c4',
        userId: _userId,
        name: 'Digital Hub',
        email: 'admin@digitalhub.io',
        phone: '+91 97654 32109',
        company: 'Digital Hub LLP',
        status: 'inactive',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      ClientModel(
        id: 'c5',
        userId: _userId,
        name: 'Bright Future Schools',
        email: 'it@brightfuture.edu',
        phone: '+91 91234 56789',
        company: 'Bright Future',
        status: 'active',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    _services = [
      ServiceModel(
        id: 's1',
        userId: _userId,
        clientId: 'c1',
        name: 'acme.com',
        type: 'domain',
        provider: 'GoDaddy',
        expiryDate: now.add(const Duration(days: 7)),
        renewalCost: 1299,
        status: 'expiring',
        clientName: 'Acme Corporation',
      ),
      ServiceModel(
        id: 's2',
        userId: _userId,
        clientId: 'c1',
        name: 'Acme Hosting Pro',
        type: 'hosting',
        provider: 'AWS',
        expiryDate: now.add(const Duration(days: 45)),
        renewalCost: 8999,
        status: 'active',
        clientName: 'Acme Corporation',
      ),
      ServiceModel(
        id: 's3',
        userId: _userId,
        clientId: 'c2',
        name: 'techstart.in',
        type: 'domain',
        provider: 'Namecheap',
        expiryDate: now.add(const Duration(days: 14)),
        renewalCost: 899,
        status: 'expiring',
        clientName: 'TechStart India',
      ),
      ServiceModel(
        id: 's4',
        userId: _userId,
        clientId: 'c2',
        name: 'TechStart Website',
        type: 'website',
        provider: 'In-house',
        expiryDate: now.add(const Duration(days: 180)),
        renewalCost: 25000,
        status: 'active',
        clientName: 'TechStart India',
      ),
      ServiceModel(
        id: 's5',
        userId: _userId,
        clientId: 'c3',
        name: 'SSL - globalsoft.com',
        type: 'ssl',
        provider: 'Let\'s Encrypt',
        expiryDate: now.add(const Duration(days: 60)),
        renewalCost: 0,
        status: 'active',
        clientName: 'Global Softwares',
      ),
      ServiceModel(
        id: 's6',
        userId: _userId,
        clientId: 'c3',
        name: 'Corporate Email',
        type: 'email',
        provider: 'Google Workspace',
        expiryDate: now.add(const Duration(days: 90)),
        renewalCost: 5400,
        status: 'active',
        clientName: 'Global Softwares',
      ),
      ServiceModel(
        id: 's7',
        userId: _userId,
        clientId: 'c5',
        name: 'brightfuture.edu',
        type: 'domain',
        provider: 'GoDaddy',
        expiryDate: now.add(const Duration(days: 120)),
        renewalCost: 1499,
        status: 'active',
        clientName: 'Bright Future Schools',
      ),
      ServiceModel(
        id: 's8',
        userId: _userId,
        clientId: 'c5',
        name: 'School Portal Hosting',
        type: 'hosting',
        provider: 'DigitalOcean',
        expiryDate: now.add(const Duration(days: 30)),
        renewalCost: 4500,
        status: 'active',
        clientName: 'Bright Future Schools',
      ),
    ];

    _invoices = [
      InvoiceModel(
        id: 'i1',
        userId: _userId,
        clientId: 'c1',
        invoiceNumber: 'INV-1042',
        amount: 45000,
        tax: 8100,
        total: 53100,
        status: 'paid',
        dueDate: now.subtract(const Duration(days: 10)),
        issuedDate: now.subtract(const Duration(days: 40)),
        clientName: 'Acme Corporation',
      ),
      InvoiceModel(
        id: 'i2',
        userId: _userId,
        clientId: 'c2',
        invoiceNumber: 'INV-1043',
        amount: 28000,
        tax: 5040,
        total: 33040,
        status: 'pending',
        dueDate: now.add(const Duration(days: 15)),
        issuedDate: now.subtract(const Duration(days: 5)),
        clientName: 'TechStart India',
      ),
      InvoiceModel(
        id: 'i3',
        userId: _userId,
        clientId: 'c3',
        invoiceNumber: 'INV-1044',
        amount: 75000,
        tax: 13500,
        total: 88500,
        status: 'overdue',
        dueDate: now.subtract(const Duration(days: 20)),
        issuedDate: now.subtract(const Duration(days: 50)),
        clientName: 'Global Softwares',
      ),
      InvoiceModel(
        id: 'i4',
        userId: _userId,
        clientId: 'c5',
        invoiceNumber: 'INV-1045',
        amount: 55000,
        tax: 9900,
        total: 64900,
        status: 'pending',
        dueDate: now.add(const Duration(days: 7)),
        issuedDate: now.subtract(const Duration(days: 3)),
        clientName: 'Bright Future Schools',
      ),
      InvoiceModel(
        id: 'i5',
        userId: _userId,
        clientId: 'c1',
        invoiceNumber: 'INV-1041',
        amount: 12000,
        tax: 2160,
        total: 14160,
        status: 'paid',
        dueDate: now.subtract(const Duration(days: 60)),
        issuedDate: now.subtract(const Duration(days: 90)),
        clientName: 'Acme Corporation',
      ),
      InvoiceModel(
        id: 'i6',
        userId: _userId,
        clientId: 'c2',
        invoiceNumber: 'INV-1040',
        amount: 8500,
        tax: 1530,
        total: 10030,
        status: 'overdue',
        dueDate: now.subtract(const Duration(days: 5)),
        issuedDate: now.subtract(const Duration(days: 35)),
        clientName: 'TechStart India',
      ),
    ];

    _leads = [
      LeadModel(
        id: 'l1',
        userId: _userId,
        name: 'Rahul Sharma',
        email: 'rahul@startupx.com',
        company: 'StartupX',
        stage: 'new',
        value: 50000,
        source: 'Website',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      LeadModel(
        id: 'l2',
        userId: _userId,
        name: 'Priya Patel',
        email: 'priya@retailco.in',
        company: 'RetailCo',
        stage: 'contacted',
        value: 85000,
        source: 'Referral',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      LeadModel(
        id: 'l3',
        userId: _userId,
        name: 'Amit Kumar',
        email: 'amit@fintech.io',
        company: 'FinTech Solutions',
        stage: 'proposal',
        value: 150000,
        source: 'LinkedIn',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      LeadModel(
        id: 'l4',
        userId: _userId,
        name: 'Sneha Reddy',
        email: 'sneha@edutech.com',
        company: 'EduTech',
        stage: 'negotiation',
        value: 200000,
        source: 'Cold Call',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      LeadModel(
        id: 'l5',
        userId: _userId,
        name: 'Vikram Singh',
        email: 'vikram@logistics.in',
        company: 'Swift Logistics',
        stage: 'won',
        value: 120000,
        source: 'Website',
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      LeadModel(
        id: 'l6',
        userId: _userId,
        name: 'Neha Gupta',
        email: 'neha@healthplus.com',
        company: 'HealthPlus',
        stage: 'new',
        value: 45000,
        source: 'Trade Show',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      LeadModel(
        id: 'l7',
        userId: _userId,
        name: 'Karan Mehta',
        email: 'karan@buildcorp.in',
        company: 'BuildCorp',
        stage: 'contacted',
        value: 95000,
        source: 'Referral',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];

    _projects = [
      ProjectModel(
        id: 'p1',
        userId: _userId,
        clientId: 'c1',
        title: 'Acme Corporate Website Redesign',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 20)),
        budget: 150000,
        clientName: 'Acme Corporation',
      ),
      ProjectModel(
        id: 'p2',
        userId: _userId,
        clientId: 'c2',
        title: 'TechStart CRM Integration',
        status: 'review',
        dueDate: now.add(const Duration(days: 5)),
        budget: 80000,
        clientName: 'TechStart India',
      ),
      ProjectModel(
        id: 'p3',
        userId: _userId,
        clientId: 'c5',
        title: 'School Management Portal',
        status: 'in_progress',
        dueDate: now.add(const Duration(days: 45)),
        budget: 250000,
        clientName: 'Bright Future Schools',
      ),
      ProjectModel(
        id: 'p4',
        userId: _userId,
        clientId: 'c3',
        title: 'Global Softwares SEO Package',
        status: 'completed',
        dueDate: now.subtract(const Duration(days: 10)),
        budget: 35000,
        clientName: 'Global Softwares',
      ),
    ];

    _tickets = [
      TicketModel(
        id: 't1',
        userId: _userId,
        clientId: 'c1',
        ticketNumber: 'TKT-201',
        subject: 'Domain DNS not resolving',
        description: 'acme.com DNS records need update after migration',
        status: 'open',
        priority: 'high',
        createdAt: now.subtract(const Duration(hours: 5)),
        clientName: 'Acme Corporation',
      ),
      TicketModel(
        id: 't2',
        userId: _userId,
        clientId: 'c2',
        ticketNumber: 'TKT-202',
        subject: 'Email delivery issues',
        description: 'Outgoing emails going to spam',
        status: 'in_progress',
        priority: 'medium',
        createdAt: now.subtract(const Duration(days: 1)),
        clientName: 'TechStart India',
      ),
      TicketModel(
        id: 't3',
        userId: _userId,
        clientId: 'c5',
        ticketNumber: 'TKT-203',
        subject: 'SSL certificate renewal',
        description: 'Need help renewing SSL for school portal',
        status: 'resolved',
        priority: 'medium',
        createdAt: now.subtract(const Duration(days: 3)),
        clientName: 'Bright Future Schools',
      ),
      TicketModel(
        id: 't4',
        userId: _userId,
        clientId: 'c3',
        ticketNumber: 'TKT-204',
        subject: 'Hosting upgrade request',
        description: 'Need more RAM for production server',
        status: 'open',
        priority: 'urgent',
        createdAt: now.subtract(const Duration(hours: 2)),
        clientName: 'Global Softwares',
      ),
    ];

    _expenses = [
      {
        'id': 'e1',
        'description': 'AWS monthly hosting',
        'category': 'hosting',
        'amount': 12500.0,
        'vendor': 'Amazon Web Services',
        'expense_date': now.subtract(const Duration(days: 5)).toIso8601String().split('T').first,
      },
      {
        'id': 'e2',
        'description': 'Domain bulk renewal',
        'category': 'domain',
        'amount': 8999.0,
        'vendor': 'GoDaddy',
        'expense_date': now.subtract(const Duration(days: 15)).toIso8601String().split('T').first,
      },
      {
        'id': 'e3',
        'description': 'Google Workspace licenses',
        'category': 'software',
        'amount': 18000.0,
        'vendor': 'Google',
        'expense_date': now.subtract(const Duration(days: 2)).toIso8601String().split('T').first,
      },
      {
        'id': 'e4',
        'description': 'Office rent',
        'category': 'office',
        'amount': 35000.0,
        'vendor': 'Property Manager',
        'expense_date': now.subtract(const Duration(days: 1)).toIso8601String().split('T').first,
      },
    ];

    _payments = [
      {
        'id': 'pay1',
        'amount': 53100.0,
        'method': 'bank_transfer',
        'reference': 'NEFT-882341',
        'paid_at': now.subtract(const Duration(days: 8)).toIso8601String(),
        'clients': {'name': 'Acme Corporation'},
        'invoices': {'invoice_number': 'INV-1042'},
      },
      {
        'id': 'pay2',
        'amount': 14160.0,
        'method': 'upi',
        'reference': 'UPI-991122',
        'paid_at': now.subtract(const Duration(days: 55)).toIso8601String(),
        'clients': {'name': 'Acme Corporation'},
        'invoices': {'invoice_number': 'INV-1041'},
      },
      {
        'id': 'pay3',
        'amount': 25000.0,
        'method': 'upi',
        'reference': 'UPI-445566',
        'paid_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        'clients': {'name': 'Global Softwares'},
        'invoices': {'invoice_number': 'INV-1038'},
      },
    ];
  }

  Future<T> _delay<T>(T value) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return value;
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    final revenue = _payments.fold<double>(0, (s, p) => s + (p['amount'] as num).toDouble());
    final pending = _invoices.where((i) => i.status == 'pending');
    final overdue = _invoices.where((i) => i.status == 'overdue');

    return _delay(DashboardStats(
      totalRevenue: revenue,
      totalClients: _clients.where((c) => c.status == 'active').length,
      activeServices: _services.where((s) => s.status == 'active' || s.status == 'expiring').length,
      pendingInvoicesCount: pending.length,
      pendingInvoicesAmount: pending.fold(0, (s, i) => s + i.total),
      overdueInvoicesCount: overdue.length,
      overdueInvoicesAmount: overdue.fold(0, (s, i) => s + i.total),
      openTickets: _tickets.where((t) => t.status == 'open' || t.status == 'in_progress').length,
      totalLeads: _leads.length,
    ));
  }

  @override
  Future<List<ClientModel>> getClients() => _delay(List.from(_clients));

  @override
  Future<ClientModel> createClient(Map<String, dynamic> data) async {
    final client = ClientModel(
      id: _uuid.v4(),
      userId: _userId,
      name: data['name'] as String,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      company: data['company'] as String?,
      status: data['status'] as String? ?? 'active',
      createdAt: DateTime.now(),
    );
    _clients.insert(0, client);
    return _delay(client);
  }

  @override
  Future<ClientModel> updateClient(String id, Map<String, dynamic> data) async {
    final index = _clients.indexWhere((c) => c.id == id);
    if (index < 0) throw Exception('Client not found');
    final updated = _clients[index].copyWith(
      name: data['name'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      company: data['company'] as String?,
      status: data['status'] as String?,
    );
    _clients[index] = updated;
    return _delay(updated);
  }

  @override
  Future<void> deleteClient(String id) async {
    _clients.removeWhere((c) => c.id == id);
    await _delay(null);
  }

  @override
  Future<List<ServiceModel>> getServices() => _delay(List.from(_services));

  @override
  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    final service = ServiceModel(
      id: _uuid.v4(),
      userId: _userId,
      clientId: data['client_id'] as String?,
      name: data['name'] as String,
      type: data['type'] as String? ?? 'domain',
      provider: data['provider'] as String?,
      expiryDate: data['expiry_date'] != null
          ? DateTime.parse(data['expiry_date'] as String)
          : null,
      renewalCost: (data['renewal_cost'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'active',
    );
    _services.insert(0, service);
    return _delay(service);
  }

  @override
  Future<void> deleteService(String id) async {
    _services.removeWhere((s) => s.id == id);
    await _delay(null);
  }

  @override
  Future<List<InvoiceModel>> getInvoices() => _delay(List.from(_invoices));

  @override
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    final amount = (data['amount'] as num).toDouble();
    final tax = (data['tax'] as num?)?.toDouble() ?? 0;
    final invoice = InvoiceModel(
      id: _uuid.v4(),
      userId: _userId,
      clientId: data['client_id'] as String?,
      invoiceNumber: data['invoice_number'] as String,
      amount: amount,
      tax: tax,
      total: amount + tax,
      status: data['status'] as String? ?? 'pending',
      dueDate: data['due_date'] != null ? DateTime.parse(data['due_date'] as String) : null,
      issuedDate: DateTime.now(),
    );
    _invoices.insert(0, invoice);
    return _delay(invoice);
  }

  @override
  Future<void> deleteInvoice(String id) async {
    _invoices.removeWhere((i) => i.id == id);
    await _delay(null);
  }

  @override
  Future<List<LeadModel>> getLeads() => _delay(List.from(_leads));

  @override
  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    final lead = LeadModel(
      id: _uuid.v4(),
      userId: _userId,
      name: data['name'] as String,
      email: data['email'] as String?,
      company: data['company'] as String?,
      stage: data['stage'] as String? ?? 'new',
      value: (data['value'] as num?)?.toDouble() ?? 0,
      source: data['source'] as String?,
      createdAt: DateTime.now(),
    );
    _leads.insert(0, lead);
    return _delay(lead);
  }

  @override
  Future<void> updateLeadStage(String id, String stage) async {
    final index = _leads.indexWhere((l) => l.id == id);
    if (index < 0) return;
    final old = _leads[index];
    _leads[index] = LeadModel(
      id: old.id,
      userId: old.userId,
      clientId: old.clientId,
      name: old.name,
      email: old.email,
      phone: old.phone,
      company: old.company,
      stage: stage,
      value: old.value,
      source: old.source,
      notes: old.notes,
      createdAt: old.createdAt,
    );
    await _delay(null);
  }

  @override
  Future<void> deleteLead(String id) async {
    _leads.removeWhere((l) => l.id == id);
    await _delay(null);
  }

  @override
  Future<List<ProjectModel>> getProjects() => _delay(List.from(_projects));

  @override
  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    final project = ProjectModel(
      id: _uuid.v4(),
      userId: _userId,
      clientId: data['client_id'] as String?,
      title: data['title'] as String,
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'in_progress',
      dueDate: data['due_date'] != null ? DateTime.parse(data['due_date'] as String) : null,
      budget: (data['budget'] as num?)?.toDouble() ?? 0,
    );
    _projects.insert(0, project);
    return _delay(project);
  }

  @override
  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await _delay(null);
  }

  @override
  Future<List<TicketModel>> getTickets() => _delay(List.from(_tickets));

  @override
  Future<TicketModel> createTicket(Map<String, dynamic> data) async {
    final ticket = TicketModel(
      id: _uuid.v4(),
      userId: _userId,
      clientId: data['client_id'] as String?,
      ticketNumber: data['ticket_number'] as String,
      subject: data['subject'] as String,
      description: data['description'] as String?,
      status: data['status'] as String? ?? 'open',
      priority: data['priority'] as String? ?? 'medium',
      createdAt: DateTime.now(),
    );
    _tickets.insert(0, ticket);
    return _delay(ticket);
  }

  @override
  Future<void> updateTicketStatus(String id, String status) async {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index < 0) return;
    final old = _tickets[index];
    _tickets[index] = TicketModel(
      id: old.id,
      userId: old.userId,
      clientId: old.clientId,
      ticketNumber: old.ticketNumber,
      subject: old.subject,
      description: old.description,
      status: status,
      priority: old.priority,
      createdAt: old.createdAt,
      clientName: old.clientName,
    );
    await _delay(null);
  }

  @override
  Future<void> deleteTicket(String id) async {
    _tickets.removeWhere((t) => t.id == id);
    await _delay(null);
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenses() => _delay(List.from(_expenses));

  @override
  Future<void> createExpense(Map<String, dynamic> data) async {
    _expenses.insert(0, {
      'id': _uuid.v4(),
      'description': data['description'],
      'category': data['category'],
      'amount': data['amount'],
      'vendor': data['vendor'],
      'expense_date': data['expense_date'] ?? DateTime.now().toIso8601String().split('T').first,
    });
    await _delay(null);
  }

  @override
  Future<List<Map<String, dynamic>>> getPayments() => _delay(List.from(_payments));

  @override
  Future<void> createPayment(Map<String, dynamic> data) async {
    _payments.insert(0, {
      'id': _uuid.v4(),
      'amount': data['amount'],
      'method': data['method'],
      'reference': data['reference'],
      'paid_at': DateTime.now().toIso8601String(),
      'clients': null,
      'invoices': null,
    });
    await _delay(null);
  }
}
