import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/models/dashboard_stats.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/models/lead.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/models/ticket.dart';

abstract class AppRepository {
  Future<DashboardStats> getDashboardStats();

  Future<List<ClientModel>> getClients();
  Future<ClientModel> createClient(Map<String, dynamic> data);
  Future<ClientModel> updateClient(String id, Map<String, dynamic> data);
  Future<void> deleteClient(String id);

  Future<List<ServiceModel>> getServices();
  Future<ServiceModel> createService(Map<String, dynamic> data);
  Future<void> deleteService(String id);

  Future<List<InvoiceModel>> getInvoices();
  Future<InvoiceModel> createInvoice(Map<String, dynamic> data);
  Future<void> deleteInvoice(String id);

  Future<List<LeadModel>> getLeads();
  Future<LeadModel> createLead(Map<String, dynamic> data);
  Future<void> updateLeadStage(String id, String stage);
  Future<void> deleteLead(String id);

  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(Map<String, dynamic> data);
  Future<void> deleteProject(String id);

  Future<List<TicketModel>> getTickets();
  Future<TicketModel> createTicket(Map<String, dynamic> data);
  Future<void> updateTicketStatus(String id, String status);
  Future<void> deleteTicket(String id);

  Future<List<Map<String, dynamic>>> getExpenses();
  Future<void> createExpense(Map<String, dynamic> data);

  Future<List<Map<String, dynamic>>> getPayments();
  Future<void> createPayment(Map<String, dynamic> data);
}
