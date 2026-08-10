import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

final monthlyRevenueProvider = FutureProvider<List<FlSpot>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return const [];
  final payments = await service.getPayments();
  final now = DateTime.now();
  final totals = List<double>.filled(6, 0);
  for (final payment in payments) {
    final raw = payment['paid_at'] ?? payment['created_at'];
    final paidAt = raw != null ? DateTime.tryParse(raw.toString()) : null;
    if (paidAt == null) continue;
    for (var i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - (5 - i));
      if (paidAt.year == month.year && paidAt.month == month.month) {
        totals[i] += (payment['amount'] as num?)?.toDouble() ?? 0;
      }
    }
  }
  return List.generate(6, (i) => FlSpot(i.toDouble(), totals[i]));
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _go(BuildContext context, String route) => context.go(route);

  void _refresh(WidgetRef ref) {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(recentInvoicesProvider);
    ref.invalidate(upcomingRenewalsProvider);
    ref.invalidate(recentProjectsProvider);
    ref.invalidate(leadsPipelineProvider);
    ref.invalidate(servicesDistributionProvider);
    ref.invalidate(monthlyRevenueProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return statsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => _refresh(ref),
      ),
      data: (stats) => RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(
                          'Tap any card or list item to manage it.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh dashboard',
                    onPressed: () => _refresh(ref),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _QuickActions(onNavigate: (route) => _go(context, route)),
              const SizedBox(height: 24),
              _buildKpiRow(context, stats, isWide),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _RevenueChart(onOpen: () => _go(context, '/reports'))),
                    const SizedBox(width: 16),
                    Expanded(child: _ServicesChart(onOpen: () => _go(context, '/services'))),
                  ],
                )
              else ...[
                _RevenueChart(onOpen: () => _go(context, '/reports')),
                const SizedBox(height: 16),
                _ServicesChart(onOpen: () => _go(context, '/services')),
              ],
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _LeadsPipeline(onOpen: () => _go(context, '/leads'))),
                    const SizedBox(width: 16),
                    Expanded(child: _UpcomingRenewals(onOpen: () => _go(context, '/services'))),
                  ],
                )
              else ...[
                _LeadsPipeline(onOpen: () => _go(context, '/leads')),
                const SizedBox(height: 16),
                _UpcomingRenewals(onOpen: () => _go(context, '/services')),
              ],
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _RecentInvoices(onOpen: () => _go(context, '/invoices'))),
                    const SizedBox(width: 16),
                    Expanded(child: _RecentProjects(onOpen: () => _go(context, '/projects'))),
                  ],
                )
              else ...[
                _RecentInvoices(onOpen: () => _go(context, '/invoices')),
                const SizedBox(height: 16),
                _RecentProjects(onOpen: () => _go(context, '/projects')),
              ],
              const SizedBox(height: 24),
              _AlertsSection(
                openTickets: stats.openTickets,
                overdueCount: stats.overdueInvoicesCount,
                onTickets: () => _go(context, '/tickets'),
                onInvoices: () => _go(context, '/invoices'),
                onPayments: () => _go(context, '/payments'),
                onExpenses: () => _go(context, '/expenses'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, DashboardStats stats, bool isWide) {
    final cards = [
      KpiCard(
        title: 'Total Revenue',
        value: Formatters.formatCurrency(stats.totalRevenue),
        icon: Icons.currency_rupee,
        color: AppColors.primary,
        trend: 'View report',
        onTap: () => _go(context, '/reports'),
      ),
      KpiCard(
        title: 'Total Clients',
        value: '${stats.totalClients}',
        icon: Icons.people,
        color: AppColors.info,
        trend: 'Manage',
        onTap: () => _go(context, '/clients'),
      ),
      KpiCard(
        title: 'Active Services',
        value: '${stats.activeServices}',
        icon: Icons.dns,
        color: AppColors.success,
        trend: 'Manage',
        onTap: () => _go(context, '/services'),
      ),
      KpiCard(
        title: 'Pending Invoices',
        value: Formatters.formatCurrency(stats.pendingInvoicesAmount),
        subtitle: '${stats.pendingInvoicesCount} invoices',
        icon: Icons.receipt_long,
        color: AppColors.warning,
        onTap: () => _go(context, '/invoices'),
      ),
      KpiCard(
        title: 'Overdue Invoices',
        value: Formatters.formatCurrency(stats.overdueInvoicesAmount),
        subtitle: '${stats.overdueInvoicesCount} invoices',
        icon: Icons.warning_amber,
        color: AppColors.danger,
        onTap: () => _go(context, '/invoices'),
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(padding: const EdgeInsets.only(right: 12), child: c),
                ))
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

class _QuickActions extends StatelessWidget {
  final void Function(String route) onNavigate;

  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.person_add_alt_1, 'Add Client', '/clients', AppColors.info),
      (Icons.note_add, 'New Invoice', '/invoices', AppColors.primary),
      (Icons.support_agent, 'New Ticket', '/tickets', AppColors.warning),
      (Icons.trending_up, 'Add Lead', '/leads', AppColors.success),
      (Icons.bar_chart, 'Sales Report', '/reports', AppColors.primaryLight),
      (Icons.settings, 'Settings', '/settings', AppColors.textSecondary),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((a) {
        return ActionChip(
          avatar: Icon(a.$1, size: 18, color: a.$4),
          label: Text(a.$2),
          onPressed: () => onNavigate(a.$3),
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _RevenueChart extends ConsumerWidget {
  final VoidCallback onOpen;

  const _RevenueChart({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsync = ref.watch(monthlyRevenueProvider);
    final now = DateTime.now();
    final labels = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      return DateFormat('MMM').format(m);
    });

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Revenue Overview', actionLabel: 'Open report', onAction: onOpen),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: spotsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('No data')),
                  data: (spots) {
                    final hasData = spots.any((s) => s.y > 0);
                    if (!hasData) {
                      return const Center(
                        child: Text('No revenue yet — tap to open sales report',
                            style: TextStyle(color: AppColors.textMuted)),
                      );
                    }
                    return LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchCallback: (event, response) {
                            if (event is FlTapUpEvent) onOpen();
                          },
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.border.withOpacity(0.5),
                            strokeWidth: 0.5,
                          ),
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
                                final i = v.toInt();
                                if (i < 0 || i >= labels.length) return const SizedBox();
                                return Text(labels[i],
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
                            spots: spots,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicesChart extends ConsumerWidget {
  final VoidCallback onOpen;

  const _ServicesChart({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distAsync = ref.watch(servicesDistributionProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Services Overview', actionLabel: 'Manage', onAction: onOpen),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: distAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('No data')),
                  data: (dist) {
                    if (dist.isEmpty) {
                      return const Center(
                        child: Text('No services yet — tap to add',
                            style: TextStyle(color: AppColors.textMuted)),
                      );
                    }
                    final colors = [
                      AppColors.primary,
                      AppColors.info,
                      AppColors.success,
                      AppColors.warning,
                      AppColors.danger,
                    ];
                    final entries = dist.entries.toList();
                    return Column(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  if (event is FlTapUpEvent) onOpen();
                                },
                              ),
                              sections: List.generate(entries.length, (i) {
                                final total = dist.values.fold(0, (a, b) => a + b);
                                final pct = (entries[i].value / total * 100).round();
                                return PieChartSectionData(
                                  value: entries[i].value.toDouble(),
                                  title: '$pct%',
                                  color: colors[i % colors.length],
                                  radius: 48,
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: List.generate(entries.length, (i) {
                            return Text(
                              '${entries[i].key}: ${entries[i].value}',
                              style: TextStyle(fontSize: 11, color: colors[i % colors.length]),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadsPipeline extends ConsumerWidget {
  final VoidCallback onOpen;

  const _LeadsPipeline({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pipelineAsync = ref.watch(leadsPipelineProvider);
    const stages = ['new', 'contacted', 'proposal', 'negotiation', 'won'];
    const labels = ['New Leads', 'Contacted', 'Proposal', 'Negotiation', 'Won'];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Sales Pipeline', actionLabel: 'Open leads', onAction: onOpen),
            const SizedBox(height: 12),
            pipelineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (pipeline) {
                if (pipeline.isEmpty) {
                  return TextButton(
                    onPressed: onOpen,
                    child: const Text('No leads yet — add your first lead'),
                  );
                }
                final maxVal = pipeline.values.fold(1, (a, b) => a > b ? a : b);
                return Column(
                  children: List.generate(stages.length, (i) {
                    final count = pipeline[stages[i]] ?? 0;
                    return InkWell(
                      onTap: onOpen,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                labels[i],
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
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
                            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                          ],
                        ),
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
  final VoidCallback onOpen;

  const _UpcomingRenewals({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renewalsAsync = ref.watch(upcomingRenewalsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Upcoming Renewals', actionLabel: 'All services', onAction: onOpen),
            const SizedBox(height: 8),
            renewalsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (services) {
                if (services.isEmpty) {
                  return TextButton(
                    onPressed: onOpen,
                    child: const Text('No renewals — manage services'),
                  );
                }
                return Column(
                  children: services.map((s) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: onOpen,
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
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatDate(s.expiryDate),
                            style: const TextStyle(color: AppColors.warning, fontSize: 12),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
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

class _RecentInvoices extends ConsumerWidget {
  final VoidCallback onOpen;

  const _RecentInvoices({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(recentInvoicesProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Recent Invoices', actionLabel: 'View all', onAction: onOpen),
            const SizedBox(height: 8),
            invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return TextButton(
                    onPressed: onOpen,
                    child: const Text('No invoices — create one'),
                  );
                }
                return Column(
                  children: invoices.map((inv) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: onOpen,
                      title: Text(inv.invoiceNumber, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(inv.clientName ?? 'No client', style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Formatters.formatCurrency(inv.total),
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          StatusBadge(status: inv.status, compact: true),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
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
  final VoidCallback onOpen;

  const _RecentProjects({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(recentProjectsProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Recent Projects', actionLabel: 'View all', onAction: onOpen),
            const SizedBox(height: 8),
            projectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('No data'),
              data: (projects) {
                if (projects.isEmpty) {
                  return TextButton(
                    onPressed: onOpen,
                    child: const Text('No projects — create one'),
                  );
                }
                return Column(
                  children: projects.map((p) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: onOpen,
                      title: Text(p.title, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(p.clientName ?? 'No client', style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(status: p.status, compact: true),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
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

class _AlertsSection extends StatelessWidget {
  final int openTickets;
  final int overdueCount;
  final VoidCallback onTickets;
  final VoidCallback onInvoices;
  final VoidCallback onPayments;
  final VoidCallback onExpenses;

  const _AlertsSection({
    required this.openTickets,
    required this.overdueCount,
    required this.onTickets,
    required this.onInvoices,
    required this.onPayments,
    required this.onExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick Links & Alerts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent, color: AppColors.warning),
              title: Text('$openTickets open support tickets'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onTickets,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.warning_amber, color: AppColors.danger),
              title: Text('$overdueCount overdue invoices'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onInvoices,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.payment, color: AppColors.success),
              title: const Text('Record a payment'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onPayments,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.money_off, color: AppColors.info),
              title: const Text('Track an expense'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onExpenses,
            ),
          ],
        ),
      ),
    );
  }
}
