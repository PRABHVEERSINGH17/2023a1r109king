import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/kpi_card.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

class MonthlyRevenue {
  final DateTime month;
  final double amount;
  final int paymentCount;

  const MonthlyRevenue({
    required this.month,
    required this.amount,
    required this.paymentCount,
  });

  String get label => DateFormat('MMM yyyy').format(month);
  String get shortLabel => DateFormat('MMM').format(month);
}

class SalesReportData {
  final List<MonthlyRevenue> months;
  final double thisMonth;
  final double lastMonth;
  final double yearToDate;
  final double growthPercent;

  const SalesReportData({
    required this.months,
    required this.thisMonth,
    required this.lastMonth,
    required this.yearToDate,
    required this.growthPercent,
  });
}

final salesReportProvider = FutureProvider<SalesReportData>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) {
    return const SalesReportData(
      months: [],
      thisMonth: 0,
      lastMonth: 0,
      yearToDate: 0,
      growthPercent: 0,
    );
  }

  final payments = await service.getPayments();
  final now = DateTime.now();
  final currentMonth = DateTime(now.year, now.month);
  final previousMonth = DateTime(now.year, now.month - 1);
  final yearStart = DateTime(now.year, 1);

  // Build last 12 months buckets
  final buckets = <DateTime, MonthlyRevenue>{};
  for (var i = 11; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i);
    final key = DateTime(m.year, m.month);
    buckets[key] = MonthlyRevenue(month: key, amount: 0, paymentCount: 0);
  }

  for (final payment in payments) {
    final paidAtRaw = payment['paid_at'] ?? payment['created_at'];
    if (paidAtRaw == null) continue;
    final paidAt = DateTime.tryParse(paidAtRaw.toString());
    if (paidAt == null) continue;

    final key = DateTime(paidAt.year, paidAt.month);
    final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
    final existing = buckets[key];
    if (existing != null) {
      buckets[key] = MonthlyRevenue(
        month: key,
        amount: existing.amount + amount,
        paymentCount: existing.paymentCount + 1,
      );
    }
  }

  final months = buckets.values.toList()
    ..sort((a, b) => a.month.compareTo(b.month));

  final thisMonth = buckets[currentMonth]?.amount ?? 0;
  final lastMonth = buckets[previousMonth]?.amount ?? 0;
  final yearToDate = payments.fold<double>(0, (sum, p) {
    final paidAtRaw = p['paid_at'] ?? p['created_at'];
    final paidAt = paidAtRaw != null ? DateTime.tryParse(paidAtRaw.toString()) : null;
    if (paidAt == null || paidAt.isBefore(yearStart)) return sum;
    return sum + ((p['amount'] as num?)?.toDouble() ?? 0);
  });

  final growth = lastMonth == 0
      ? (thisMonth > 0 ? 100.0 : 0.0)
      : ((thisMonth - lastMonth) / lastMonth) * 100;

  return SalesReportData(
    months: months,
    thisMonth: thisMonth,
    lastMonth: lastMonth,
    yearToDate: yearToDate,
    growthPercent: growth,
  );
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(salesReportProvider);
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: AppBreakpoints.pagePadding(context),
      child: reportAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(salesReportProvider),
        ),
        data: (report) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Sales Report',
                subtitle: 'Monthly revenue performance',
                action: IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(salesReportProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: 24),
              _buildKpiRow(report, isWide),
              const SizedBox(height: 24),
              _MonthlyRevenueChart(report: report),
              const SizedBox(height: 24),
              _MonthlyBreakdownTable(report: report),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(SalesReportData report, bool isWide) {
    final growthLabel =
        '${report.growthPercent >= 0 ? '+' : ''}${report.growthPercent.toStringAsFixed(1)}%';
    final cards = [
      KpiCard(
        title: 'This Month Revenue',
        value: Formatters.formatCurrency(report.thisMonth),
        icon: Icons.calendar_month,
        color: AppColors.primary,
        trend: growthLabel,
      ),
      KpiCard(
        title: 'Last Month Revenue',
        value: Formatters.formatCurrency(report.lastMonth),
        icon: Icons.history,
        color: AppColors.info,
      ),
      KpiCard(
        title: 'Year to Date',
        value: Formatters.formatCurrency(report.yearToDate),
        icon: Icons.payments,
        color: AppColors.success,
      ),
      KpiCard(
        title: 'MoM Growth',
        value: growthLabel,
        subtitle: 'vs previous month',
        icon: Icons.trending_up,
        color: report.growthPercent >= 0 ? AppColors.success : AppColors.danger,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: c,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: cards
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: c,
            ),
          )
          .toList(),
    );
  }
}

class _MonthlyRevenueChart extends StatelessWidget {
  final SalesReportData report;

  const _MonthlyRevenueChart({required this.report});

  @override
  Widget build(BuildContext context) {
    final maxY = report.months.fold<double>(
      0,
      (m, e) => e.amount > m ? e.amount : m,
    );
    final chartMax = maxY <= 0 ? 10000.0 : maxY * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'Last 12 months sales from recorded payments',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),
            if (report.months.every((m) => m.amount == 0))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No payment data yet. Record payments to see monthly revenue.',
                    style: TextStyle(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              SizedBox(
                height: 260,
                child: BarChart(
                  BarChartData(
                    maxY: chartMax,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.border.withOpacity(0.5),
                        strokeWidth: 0.5,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 48,
                          getTitlesWidget: (value, _) => Text(
                            '₹${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            final i = value.toInt();
                            if (i < 0 || i >= report.months.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                report.months[i].shortLabel,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(report.months.length, (i) {
                      final month = report.months[i];
                      final isCurrent = month.month.year == DateTime.now().year &&
                          month.month.month == DateTime.now().month;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: month.amount,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            color: isCurrent ? AppColors.primary : AppColors.info,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBreakdownTable extends StatelessWidget {
  final SalesReportData report;

  const _MonthlyBreakdownTable({required this.report});

  @override
  Widget build(BuildContext context) {
    final rows = report.months.reversed.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (rows.every((m) => m.amount == 0))
              const Text(
                'No monthly sales recorded yet.',
                style: TextStyle(color: AppColors.textMuted),
              )
            else if (AppBreakpoints.isPhone(context))
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final m = rows[index];
                  final share = report.yearToDate <= 0
                      ? 0.0
                      : (m.amount / report.yearToDate) * 100;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m.label),
                    subtitle: Text('${m.paymentCount} payments · ${share.toStringAsFixed(1)}% of YTD'),
                    trailing: Text(
                      Formatters.formatCurrency(m.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Month')),
                    DataColumn(label: Text('Revenue')),
                    DataColumn(label: Text('Payments')),
                    DataColumn(label: Text('Share of YTD')),
                  ],
                  rows: rows.map((m) {
                    final share = report.yearToDate <= 0
                        ? 0.0
                        : (m.amount / report.yearToDate) * 100;
                    return DataRow(
                      cells: [
                        DataCell(Text(m.label)),
                        DataCell(Text(
                          Formatters.formatCurrency(m.amount),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )),
                        DataCell(Text('${m.paymentCount}')),
                        DataCell(Text('${share.toStringAsFixed(1)}%')),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
