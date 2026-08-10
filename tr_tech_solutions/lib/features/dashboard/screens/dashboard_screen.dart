import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_motion.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/screens/clients_screen.dart';
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
  try {
    return await service.getDashboardStats();
  } catch (_) {
    // Live backend failed — fall back to demo seed so the dashboard still works.
    if (!ref.read(demoModeProvider)) {
      Future.microtask(() {
        if (!ref.read(demoModeProvider)) {
          ref.read(demoModeProvider.notifier).state = true;
        }
      });
    }
    return ref.read(demoRepositoryProvider).getDashboardStats();
  }
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

  void _goClients(BuildContext context, WidgetRef ref) {
    ref.invalidate(clientsProvider);
    _go(context, '/clients');
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
              FadeInUp(
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppTypography.display,
                              letterSpacing: -0.8,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap any module, KPI, or chart to jump in.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontFamily: AppTypography.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Refresh dashboard',
                      onPressed: () => _refresh(ref),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: _ModuleGrid(onNavigate: (route) => _go(context, route)),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 140),
                child: _buildKpiRow(context, ref, stats, isWide),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _RevenueChart(onOpen: () => _go(context, '/reports')),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ServicesChart(onOpen: () => _go(context, '/services')),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _RevenueChart(onOpen: () => _go(context, '/reports')),
                          const SizedBox(height: 16),
                          _ServicesChart(onOpen: () => _go(context, '/services')),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _LeadsPipeline(onOpen: () => _go(context, '/leads'))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _UpcomingRenewals(onOpen: () => _go(context, '/services')),
                    ),
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
                    Expanded(
                      child: _RecentInvoices(onOpen: () => _go(context, '/invoices')),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RecentProjects(onOpen: () => _go(context, '/projects')),
                    ),
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
                onReports: () => _go(context, '/reports'),
                onSettings: () => _go(context, '/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(
    BuildContext context,
    WidgetRef ref,
    DashboardStats stats,
    bool isWide,
  ) {
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
        onTap: () => _goClients(context, ref),
      ),
      KpiCard(
        title: 'Active Leads',
        value: '${stats.totalLeads}',
        icon: Icons.trending_up,
        color: AppColors.primaryLight,
        trend: 'Pipeline',
        onTap: () => _go(context, '/leads'),
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
      KpiCard(
        title: 'Open Tickets',
        value: '${stats.openTickets}',
        icon: Icons.support_agent,
        color: AppColors.warning,
        trend: 'Support',
        onTap: () => _go(context, '/tickets'),
      ),
    ];

    if (isWide) {
      return SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => SizedBox(width: 228, child: cards[i]),
        ),
      );
    }

    return Column(
      children: cards
          .map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c))
          .toList(),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  final void Function(String route) onNavigate;

  const _ModuleGrid({required this.onNavigate});

  static const _modules = [
    (Icons.people, 'Clients', '/clients', AppColors.info),
    (Icons.trending_up, 'Leads', '/leads', AppColors.success),
    (Icons.dns, 'Services', '/services', AppColors.primary),
    (Icons.folder, 'Projects', '/projects', AppColors.primaryLight),
    (Icons.receipt_long, 'Invoices', '/invoices', AppColors.warning),
    (Icons.payment, 'Payments', '/payments', AppColors.success),
    (Icons.money_off, 'Expenses', '/expenses', AppColors.info),
    (Icons.support_agent, 'Tickets', '/tickets', AppColors.warning),
    (Icons.bar_chart, 'Reports', '/reports', AppColors.primary),
    (Icons.settings, 'Settings', '/settings', AppColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 1100
        ? 5
        : width >= 700
            ? 4
            : width >= 500
                ? 3
                : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Go to module',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.display,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _modules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.45,
          ),
          itemBuilder: (context, index) {
            final m = _modules[index];
            return Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onNavigate(m.$3),
                borderRadius: BorderRadius.circular(14),
                mouseCursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: m.$4.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(m.$1, color: m.$4, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            fontFamily: AppTypography.body,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(actionLabel),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClickableCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _ClickableCard({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
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

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Revenue Overview', actionLabel: 'Open report', onAction: onOpen),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: spotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: TextButton(onPressed: onOpen, child: const Text('Open sales report')),
              ),
              data: (spots) {
                final hasData = spots.any((s) => s.y > 0);
                if (!hasData) {
                  return Center(
                    child: TextButton(
                      onPressed: onOpen,
                      child: const Text('No revenue yet — open sales report'),
                    ),
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
                            return Text(
                              labels[i],
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                            );
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
    );
  }
}

class _ServicesChart extends ConsumerWidget {
  final VoidCallback onOpen;

  const _ServicesChart({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distAsync = ref.watch(servicesDistributionProvider);

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Services Overview', actionLabel: 'Manage', onAction: onOpen),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: distAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: TextButton(onPressed: onOpen, child: const Text('Open services')),
              ),
              data: (dist) {
                if (dist.isEmpty) {
                  return Center(
                    child: TextButton(
                      onPressed: onOpen,
                      child: const Text('No services yet — tap to add'),
                    ),
                  );
                }
                    final colors = [
                      AppColors.chart1,
                      AppColors.chart2,
                      AppColors.chart3,
                      AppColors.chart4,
                      AppColors.chart5,
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

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Sales Pipeline', actionLabel: 'Open leads', onAction: onOpen),
          const SizedBox(height: 12),
          pipelineAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => TextButton(onPressed: onOpen, child: const Text('Open leads')),
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
                  return Padding(
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
                        Text(
                          '$count',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
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

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Upcoming Renewals', actionLabel: 'All services', onAction: onOpen),
          const SizedBox(height: 8),
          renewalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => TextButton(onPressed: onOpen, child: const Text('Open services')),
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
                    dense: true,
                    mouseCursor: SystemMouseCursors.click,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.dns, color: AppColors.warning, size: 18),
                    ),
                    title: Text(s.name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      '${s.type} • ${s.clientName ?? "No client"}',
                      style: const TextStyle(fontSize: 12),
                    ),
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
    );
  }
}

class _RecentInvoices extends ConsumerWidget {
  final VoidCallback onOpen;

  const _RecentInvoices({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(recentInvoicesProvider);

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Recent Invoices', actionLabel: 'View all', onAction: onOpen),
          const SizedBox(height: 8),
          invoicesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => TextButton(onPressed: onOpen, child: const Text('Open invoices')),
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
                    dense: true,
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(inv.invoiceNumber, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      inv.clientName ?? 'No client',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(inv.total),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
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
    );
  }
}

class _RecentProjects extends ConsumerWidget {
  final VoidCallback onOpen;

  const _RecentProjects({required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(recentProjectsProvider);

    return _ClickableCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Recent Projects', actionLabel: 'View all', onAction: onOpen),
          const SizedBox(height: 8),
          projectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => TextButton(onPressed: onOpen, child: const Text('Open projects')),
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
                    dense: true,
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(p.title, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      p.clientName ?? 'No client',
                      style: const TextStyle(fontSize: 12),
                    ),
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
  final VoidCallback onReports;
  final VoidCallback onSettings;

  const _AlertsSection({
    required this.openTickets,
    required this.overdueCount,
    required this.onTickets,
    required this.onInvoices,
    required this.onPayments,
    required this.onExpenses,
    required this.onReports,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.support_agent, AppColors.warning, '$openTickets open support tickets', onTickets),
      (Icons.warning_amber, AppColors.danger, '$overdueCount overdue invoices', onInvoices),
      (Icons.payment, AppColors.success, 'Record a payment', onPayments),
      (Icons.money_off, AppColors.info, 'Track an expense', onExpenses),
      (Icons.bar_chart, AppColors.primary, 'Open sales report', onReports),
      (Icons.settings, AppColors.textSecondary, 'Open settings', onSettings),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Links & Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                mouseCursor: SystemMouseCursors.click,
                leading: Icon(item.$1, color: item.$2),
                title: Text(item.$3),
                trailing: const Icon(Icons.chevron_right),
                onTap: item.$4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
