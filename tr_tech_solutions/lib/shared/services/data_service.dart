import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/models/dashboard_stats.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';
import 'package:tr_tech_solutions/shared/services/app_repository.dart';
import 'package:tr_tech_solutions/shared/services/client_bootstrap.dart';
import 'package:tr_tech_solutions/shared/services/demo_repository.dart';

class SupabaseRepository implements AppRepository {
  final SupabaseClient _client;

  SupabaseRepository(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<DashboardStats> getDashboardStats() async {
    final userId = _userId;
    if (userId == null) return const DashboardStats();

    try {
      final result =
          await _client.rpc('get_dashboard_stats', params: {'p_user_id': userId});
      return DashboardStats.fromJson(result as Map<String, dynamic>);
    } catch (_) {
      // Fallback when RPC is not installed yet
      final clients = await getClients();
      final services = await getServices();
      final invoices = await getInvoices();
      final leads = await getLeads();
      final payments = await getPayments();
      List<TicketModel> tickets = const [];
      try {
        tickets = await getTickets();
      } catch (_) {}

      final pending = invoices.where((i) => i.status == 'pending');
      final overdue = invoices.where((i) => i.status == 'overdue');
      final revenue = payments.fold<double>(
        0,
        (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0),
      );

      return DashboardStats(
        totalRevenue: revenue,
        totalClients: clients.where((c) => c.status == 'active').length,
        activeServices: services.where((s) => s.status == 'active').length,
        pendingInvoicesCount: pending.length,
        pendingInvoicesAmount: pending.fold(0, (s, i) => s + i.total),
        overdueInvoicesCount: overdue.length,
        overdueInvoicesAmount: overdue.fold(0, (s, i) => s + i.total),
        openTickets: tickets
            .where((t) => t.status == 'open' || t.status == 'in_progress')
            .length,
        totalLeads: leads.length,
      );
    }
  }

  @override
  Future<List<ClientModel>> getClients() async {
    final response =
        await _client.from('clients').select().order('created_at', ascending: false);
    return (response as List)
        .map((e) => ClientModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }

  @override
  Future<ClientModel> createClient(Map<String, dynamic> data) async {
    final bootstrap = data.remove('bootstrap_related') as bool? ?? true;
    data['user_id'] = _userId;
    final response = await _client.from('clients').insert(data).select().single();
    final client = ClientModel.fromJson(response);
    if (bootstrap) {
      // Always attempt linked records; individual failures are handled inside.
      await bootstrapRelatedRecordsForClient(this, client);
    }
    return client;
  }

  @override
  Future<ClientModel> updateClient(String id, Map<String, dynamic> data) async {
    final response =
        await _client.from('clients').update(data).eq('id', id).select().single();
    return ClientModel.fromJson(response);
  }

  @override
  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  @override
  Future<List<ServiceModel>> getServices() async {
    final response = await _client
        .from('services')
        .select('*, clients(name)')
        .order('expiry_date', ascending: true);
    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  @override
  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('services').insert(data).select().single();
    return ServiceModel.fromJson(response);
  }

  @override
  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _client
        .from('invoices')
        .select('*, clients(name)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => InvoiceModel.fromJson(e)).toList();
  }

  @override
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('invoices').insert(data).select().single();
    return InvoiceModel.fromJson(response);
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _client.from('invoices').delete().eq('id', id);
  }

  @override
  Future<List<LeadModel>> getLeads() async {
    final response =
        await _client.from('leads').select().order('created_at', ascending: false);
    return (response as List).map((e) => LeadModel.fromJson(e)).toList();
  }

  @override
  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('leads').insert(data).select().single();
    return LeadModel.fromJson(response);
  }

  @override
  Future<void> updateLeadStage(String id, String stage) async {
    await _client.from('leads').update({'stage': stage}).eq('id', id);
  }

  @override
  Future<void> deleteLead(String id) async {
    await _client.from('leads').delete().eq('id', id);
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client
        .from('projects')
        .select('*, clients(name)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  @override
  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('projects').insert(data).select().single();
    return ProjectModel.fromJson(response);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  @override
  Future<List<TicketModel>> getTickets() async {
    try {
      final response = await _client
          .from('tickets')
          .select('*, clients(name)')
          .order('created_at', ascending: false);
      return (response as List).map((e) => TicketModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<TicketModel> createTicket(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('tickets').insert(data).select().single();
    return TicketModel.fromJson(response);
  }

  @override
  Future<void> updateTicketStatus(String id, String status) async {
    await _client.from('tickets').update({'status': status}).eq('id', id);
  }

  @override
  Future<void> deleteTicket(String id) async {
    await _client.from('tickets').delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response =
        await _client.from('expenses').select().order('expense_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> createExpense(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    await _client.from('expenses').insert(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await _client
        .from('payments')
        .select('*, clients(name), invoices(invoice_number)')
        .order('paid_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> createPayment(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    await _client.from('payments').insert(data);
  }
}

final demoRepositoryProvider = Provider<DemoRepository>((ref) {
  final repo = DemoRepository();
  // Keep the same seeded instance for the app lifetime.
  ref.keepAlive();
  return repo;
});

final appRepositoryProvider = Provider<AppRepository>((ref) {
  final isDemo = ref.watch(demoModeProvider);
  if (isDemo || !SupabaseConfig.isConfigured) {
    return ref.watch(demoRepositoryProvider);
  }
  return SupabaseRepository(Supabase.instance.client);
});

/// Backwards-compatible alias used by existing screens.
final dataServiceProvider = Provider<AppRepository?>((ref) {
  return ref.watch(appRepositoryProvider);
});
