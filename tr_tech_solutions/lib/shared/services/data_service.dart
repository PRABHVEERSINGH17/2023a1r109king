import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/models/dashboard_stats.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';

class DataService {
  final SupabaseClient _client;

  DataService(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  // Dashboard
  Future<DashboardStats> getDashboardStats() async {
    final userId = _userId;
    if (userId == null) return const DashboardStats();

    final result = await _client.rpc('get_dashboard_stats', params: {'p_user_id': userId});
    return DashboardStats.fromJson(result as Map<String, dynamic>);
  }

  // Clients
  Future<List<ClientModel>> getClients() async {
    final response = await _client
        .from('clients')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel> createClient(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('clients').insert(data).select().single();
    return ClientModel.fromJson(response);
  }

  Future<ClientModel> updateClient(String id, Map<String, dynamic> data) async {
    final response = await _client.from('clients').update(data).eq('id', id).select().single();
    return ClientModel.fromJson(response);
  }

  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  // Services
  Future<List<ServiceModel>> getServices() async {
    final response = await _client
        .from('services')
        .select('*, clients(name)')
        .order('expiry_date', ascending: true);
    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> createService(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('services').insert(data).select().single();
    return ServiceModel.fromJson(response);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  // Invoices
  Future<List<InvoiceModel>> getInvoices() async {
    final response = await _client
        .from('invoices')
        .select('*, clients(name)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceModel> createInvoice(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('invoices').insert(data).select().single();
    return InvoiceModel.fromJson(response);
  }

  Future<void> deleteInvoice(String id) async {
    await _client.from('invoices').delete().eq('id', id);
  }

  // Leads
  Future<List<LeadModel>> getLeads() async {
    final response = await _client
        .from('leads')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => LeadModel.fromJson(e)).toList();
  }

  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('leads').insert(data).select().single();
    return LeadModel.fromJson(response);
  }

  Future<void> updateLeadStage(String id, String stage) async {
    await _client.from('leads').update({'stage': stage}).eq('id', id);
  }

  Future<void> deleteLead(String id) async {
    await _client.from('leads').delete().eq('id', id);
  }

  // Projects
  Future<List<ProjectModel>> getProjects() async {
    final response = await _client
        .from('projects')
        .select('*, clients(name)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => ProjectModel.fromJson(e)).toList();
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('projects').insert(data).select().single();
    return ProjectModel.fromJson(response);
  }

  Future<void> deleteProject(String id) async {
    await _client.from('projects').delete().eq('id', id);
  }

  // Tickets
  Future<List<TicketModel>> getTickets() async {
    final response = await _client
        .from('tickets')
        .select('*, clients(name)')
        .order('created_at', ascending: false);
    return (response as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<TicketModel> createTicket(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    final response = await _client.from('tickets').insert(data).select().single();
    return TicketModel.fromJson(response);
  }

  Future<void> updateTicketStatus(String id, String status) async {
    await _client.from('tickets').update({'status': status}).eq('id', id);
  }

  Future<void> deleteTicket(String id) async {
    await _client.from('tickets').delete().eq('id', id);
  }

  // Expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await _client
        .from('expenses')
        .select()
        .order('expense_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createExpense(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    await _client.from('expenses').insert(data);
  }

  // Payments
  Future<List<Map<String, dynamic>>> getPayments() async {
    final response = await _client
        .from('payments')
        .select('*, clients(name), invoices(invoice_number)')
        .order('paid_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createPayment(Map<String, dynamic> data) async {
    data['user_id'] = _userId;
    await _client.from('payments').insert(data);
  }
}

final dataServiceProvider = Provider<DataService?>((ref) {
  try {
    return DataService(Supabase.instance.client);
  } catch (_) {
    return null;
  }
});
