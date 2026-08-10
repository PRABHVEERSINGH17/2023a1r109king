import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      (icon: Icons.currency_rupee, title: 'Revenue Report', desc: 'Monthly and yearly revenue analysis', color: AppColors.primary),
      (icon: Icons.trending_up, title: 'Sales Report', desc: 'Lead conversion and pipeline metrics', color: AppColors.info),
      (icon: Icons.people, title: 'Client Report', desc: 'Client growth and retention stats', color: AppColors.success),
      (icon: Icons.dns, title: 'Services Report', desc: 'Service renewals and distribution', color: AppColors.warning),
      (icon: Icons.receipt_long, title: 'Invoice Report', desc: 'Invoice status and aging analysis', color: AppColors.danger),
      (icon: Icons.support_agent, title: 'Support Report', desc: 'Ticket resolution and response times', color: AppColors.primaryLight),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Reports & Analytics',
            subtitle: 'Business intelligence and insights',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width >= 900 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${report.title} - Coming soon')),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: report.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(report.icon, color: report.color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(report.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(report.desc,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
                        ],
                      ),
                    ),
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
