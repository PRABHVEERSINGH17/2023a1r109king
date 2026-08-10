class DashboardStats {
  final double totalRevenue;
  final int totalClients;
  final int activeServices;
  final int pendingInvoicesCount;
  final double pendingInvoicesAmount;
  final int overdueInvoicesCount;
  final double overdueInvoicesAmount;
  final int openTickets;
  final int totalLeads;

  const DashboardStats({
    this.totalRevenue = 0,
    this.totalClients = 0,
    this.activeServices = 0,
    this.pendingInvoicesCount = 0,
    this.pendingInvoicesAmount = 0,
    this.overdueInvoicesCount = 0,
    this.overdueInvoicesAmount = 0,
    this.openTickets = 0,
    this.totalLeads = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalClients: (json['total_clients'] as num?)?.toInt() ?? 0,
      activeServices: (json['active_services'] as num?)?.toInt() ?? 0,
      pendingInvoicesCount: (json['pending_invoices_count'] as num?)?.toInt() ?? 0,
      pendingInvoicesAmount: (json['pending_invoices_amount'] as num?)?.toDouble() ?? 0,
      overdueInvoicesCount: (json['overdue_invoices_count'] as num?)?.toInt() ?? 0,
      overdueInvoicesAmount: (json['overdue_invoices_amount'] as num?)?.toDouble() ?? 0,
      openTickets: (json['open_tickets'] as num?)?.toInt() ?? 0,
      totalLeads: (json['total_leads'] as num?)?.toInt() ?? 0,
    );
  }
}
