import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

class ClientDetailScreen extends ConsumerWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final invoicesAsync = ref.watch(invoicesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final ticketsAsync = ref.watch(ticketsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);

    return clientsAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (clients) {
        ClientModel? client;
        for (final c in clients) {
          if (c.id == clientId) {
            client = c;
            break;
          }
        }
        if (client == null) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Client not found',
            subtitle: 'This client may have been deleted',
          );
        }

        final projects = projectsAsync.valueOrNull
                ?.where((p) => p.clientId == clientId)
                .toList() ??
            const [];
        final invoices = invoicesAsync.valueOrNull
                ?.where((i) => i.clientId == clientId)
                .toList() ??
            const [];
        final services = servicesAsync.valueOrNull
                ?.where((s) => s.clientId == clientId)
                .toList() ??
            const [];
        final tickets = ticketsAsync.valueOrNull
                ?.where((t) => t.clientId == clientId)
                .toList() ??
            const [];
        final payments = paymentsAsync.valueOrNull
                ?.where((p) => p['client_id'] == clientId)
                .toList() ??
            const [];

        final paidTotal = payments.fold<double>(
          0,
          (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0),
        );

        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/clients'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.display,
                            letterSpacing: -0.6,
                          ),
                        ),
                        Text(
                          [
                            if (client.company != null && client.company!.isNotEmpty) client.company!,
                            if (client.email != null) client.email!,
                            if (client.phone != null) client.phone!,
                          ].join(' · '),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: client.status),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Projects', value: '${projects.length}'),
                  _StatChip(label: 'Invoices', value: '${invoices.length}'),
                  _StatChip(label: 'Services', value: '${services.length}'),
                  _StatChip(label: 'Tickets', value: '${tickets.length}'),
                  _StatChip(label: 'Payments', value: Formatters.formatCurrency(paidTotal)),
                ],
              ),
              const SizedBox(height: 28),
              _Section(
                title: 'Projects',
                empty: projects.isEmpty,
                children: projects
                    .map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(p.title),
                        subtitle: Text('Budget ${Formatters.formatCurrency(p.budget)}'),
                        trailing: StatusBadge(status: p.status, compact: true),
                      ),
                    )
                    .toList(),
              ),
              _Section(
                title: 'Invoices',
                empty: invoices.isEmpty,
                children: invoices
                    .map(
                      (i) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(i.invoiceNumber),
                        subtitle: Text(Formatters.formatCurrency(i.total)),
                        trailing: StatusBadge(status: i.status, compact: true),
                      ),
                    )
                    .toList(),
              ),
              _Section(
                title: 'Services',
                empty: services.isEmpty,
                children: services
                    .map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.name),
                        subtitle: Text('${s.type} · expires ${Formatters.formatDate(s.expiryDate)}'),
                        trailing: StatusBadge(status: s.status, compact: true),
                      ),
                    )
                    .toList(),
              ),
              _Section(
                title: 'Payments',
                empty: payments.isEmpty,
                children: payments
                    .map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(Formatters.formatCurrency((p['amount'] as num?)?.toDouble() ?? 0)),
                        subtitle: Text(p['method']?.toString() ?? '-'),
                        trailing: Text(
                          Formatters.formatDate(
                            p['paid_at'] != null ? DateTime.tryParse(p['paid_at'].toString()) : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              _Section(
                title: 'Tickets',
                empty: tickets.isEmpty,
                children: tickets
                    .map(
                      (t) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.subject),
                        subtitle: Text(t.ticketNumber),
                        trailing: StatusBadge(status: t.status, compact: true),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.display,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final bool empty;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.empty,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.display,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (empty)
            const Text('No linked records yet', style: TextStyle(color: AppColors.textMuted))
          else
            ...children,
        ],
      ),
    );
  }
}
