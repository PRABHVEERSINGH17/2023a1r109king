import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/dashboard_stats.dart';
import 'package:tr_tech_solutions/shared/models/invoice.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/kpi_card.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return const DashboardStats();
  return service.getDashboardStats();
});

final recentInvoicesProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  final invoices = await service.getInvoices();
  return invoices.take(5).toList();
});

final upcomingRenewalsProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  final services = await service.getServices();
  return services.where((s) => s.expiryDate != null).take(5).toList();
});

final recentProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  final projects = await service.getProjects();
  return projects.take(5).toList();
});

final leadsPipelineProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return {};
  final leads = await service.getLeads();
  final pipeline = <String, int>{};
  for (final lead in leads) {
    pipeline[lead.stage] = (pipeline[lead.stage] ?? 0) + 1;
  }
  return pipeline;
});

final servicesDistributionProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return {};
  final services = await service.getServices();
  final dist = <String, int>{};
  for (final s in services) {
    dist[s.type] = (dist[s.type] ?? 0) + 1;
  }
  return dist;
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return statsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(dashboardStatsProvider)),
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Welcome back! Here\'s your business overview.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            _buildKpiRow(stats, isWide),
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _RevenueChart()),
                  const SizedBox(width: 16),
                  Expanded(child: _ServicesChart()),
                ],
              )
            else ...[
              _RevenueChart(),
              const SizedBox(height: 16),
              _ServicesChart(),
            ],
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _LeadsPipeline()),
                  const SizedBox(width: 16),
                  Expanded(child: _UpcomingRenewals()),
                ],
              )
            else ...[
              _LeadsPipeline(),
              const SizedBox(height: 16),
              _UpcomingRenewals(),
            ],
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _RecentInvoices()),
                  const SizedBox(width: 16),
                  Expanded(child: _RecentProjects()),
                ],
              )
            else ...[
              _RecentInvoices(),
              const SizedBox(height: 16),
              _RecentProjects(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(DashboardStats stats, bool isWide) {
    final cards = [
      KpiCard(
        title: 'Total Revenue',
        value: Formatters.formatCurrency(stats.totalRevenue),
        icon: Icons.currency_rupee,
        color: AppColors.primary,
        trend: '+18.6%',
      ),
      KpiCard(
        title: 'Total Clients',
        value: '${stats.totalClients}',
        icon: Icons.people,
        color: AppColors.info,
        trend: '+24',
      ),
      KpiCard(
        title: 'Active Services',
        value: '${stats.activeServices}',
        icon: Icons.dns,
        color: AppColors.success,
        trend: '+56',
      ),
      KpiCard(
        title: 'Pending Invoices',
        value: Formatters.formatCurrency(stats.pendingInvoicesAmount),
        subtitle: '${stats.pendingInvoicesCount} invoices',
        icon: Icons.receipt_long,
        color: AppColors.warning,
      ),
      KpiCard(
        title: 'Overdue Invoices',
        value: Formatters.formatCurrency(stats.overdueInvoicesAmount),
        subtitle: '${stats.overdueInvoicesCount} invoices',
        icon: Icons.warning_amber,
        color: AppColors.danger,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
            .toList(),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
          .toList(),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Revenue Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.border.withOpacity(0.5), strokeWidth: 0.5),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (v, _) => Text(
                          '₹${(v / 1000).toInt()}k',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          final i = v.toInt();
                          if (i < 0 || i >= months.length) return const SizedBox();
                          return Text(months[i],
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10));
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 80000),
                        FlSpot(1, 95000),
                        FlSpot(2, 110000),
                        FlSpot(3, 105000),
                        FlSpot(4, 130000),
                        FlSpot(5, 145000),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distAsync = ref.watch(servicesDistributionProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Services Overview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: distAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('No data')),
                data: (dist) {
                  if (dist.isEmpty) {
                    return const Center(
                        child: Text('No services yet', style: TextStyle(color: AppColors.textMuted)));
                  }
                  final colors = [
                    AppColors.primary,
                    AppColors.info,
                    AppColors.success,
                    AppColors.warning,
                    AppColors.danger,
                  ];
                  final entries = dist.entries.toList();
                  return PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(entries.length, (i) {
                        final total = dist.values.fold(0, (a, b) => a + b);
                        final pct = (entries[i].value / total * 100).round();
                        return PieChartSectionData(
                          value: entries[i].value.toDouble(),
                          title: '$pct%',
                          color: colors[i % colors.length],
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadsPipeline extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(leadsPipelineProvider);
    const stages = ['new', 'contacted', 'proposal', 'negotiation', 'won'];
    const labels = ['New Leads', 'Contacted', 'Proposal', 'Negotiation', 'Won'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sales Pipeline',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            pipelineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (pipeline) {
                final maxVal = pipeline.values.fold(1, (a, b) => a > b ? a : b);
                return Column(
                  children: List.generate(stages.length, (i) {
                    final count = pipeline[stages[i]] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                              width: 100,
                              child: Text(labels[i],
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: count / maxVal,
                                minHeight: 20,
                                backgroundColor: AppColors.surfaceLight,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$count',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingRenewals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renewalsAsync = ref.watch(upcomingRenewalsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming Renewals',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            renewalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (services) {
                if (services.isEmpty) {
                  return const Text('No upcoming renewals',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return Column(
                  children: services.map((s) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.dns, color: AppColors.warning, size: 18),
                      ),
                      title: Text(s.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text('${s.type} • ${s.clientName ?? "No client"}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        Formatters.formatDate(s.expiryDate),
                        style: const TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentInvoices extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(recentInvoicesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Invoices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return const Text('No invoices yet',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return Column(
                  children: invoices.map((inv) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(inv.invoiceNumber, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(inv.clientName ?? 'No client',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Formatters.formatCurrency(inv.total),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          StatusBadge(status: inv.status, compact: true),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentProjects extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(recentProjectsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Projects',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (projects) {
                if (projects.isEmpty) {
                  return const Text('No projects yet',
                      style: TextStyle(color: AppColors.textMuted));
                }
                return Column(
                  children: projects.map((p) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.title, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(p.clientName ?? 'No client',
                          style: const TextStyle(fontSize: 12)),
                      trailing: StatusBadge(status: p.status, compact: true),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
