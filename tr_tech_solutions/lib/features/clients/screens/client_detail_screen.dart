import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_motion.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/features/invoices/screens/invoices_screen.dart';
import 'package:tr_tech_solutions/features/leads/screens/leads_screen.dart';
import 'package:tr_tech_solutions/features/payments/screens/payments_screen.dart';
import 'package:tr_tech_solutions/features/projects/screens/projects_screen.dart';
import 'package:tr_tech_solutions/features/services/screens/services_screen.dart';
import 'package:tr_tech_solutions/features/tickets/screens/tickets_screen.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/client_bootstrap.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _ensuring = false;
  bool _ensureAttempted = false;

  String get clientId => widget.clientId;

  Future<void> _refresh() async {
    ref.invalidate(projectsProvider);
    ref.invalidate(invoicesProvider);
    ref.invalidate(servicesProvider);
    ref.invalidate(ticketsProvider);
    ref.invalidate(paymentsProvider);
    ref.invalidate(leadsProvider);
    ref.invalidate(clientsProvider);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _ensureLinked(ClientModel client) async {
    if (_ensuring || _ensureAttempted) return;
    _ensureAttempted = true;
    final service = ref.read(dataServiceProvider);
    if (service == null) return;
    setState(() => _ensuring = true);
    try {
      final result = await ensureClientRelatedRecords(service, client);
      if (result.createdCount > 0) {
        await _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Linked ${result.createdTypes.join(', ')} to ${client.name}',
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _ensuring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final invoicesAsync = ref.watch(invoicesProvider);
    final servicesAsync = ref.watch(servicesProvider);
    final ticketsAsync = ref.watch(ticketsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);
    final leadsAsync = ref.watch(leadsProvider);

    final relatedLoading = projectsAsync.isLoading ||
        invoicesAsync.isLoading ||
        servicesAsync.isLoading ||
        ticketsAsync.isLoading ||
        paymentsAsync.isLoading ||
        leadsAsync.isLoading;

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

        final projects =
            projectsAsync.valueOrNull?.where((p) => p.clientId == clientId).toList() ?? const [];
        final invoices =
            invoicesAsync.valueOrNull?.where((i) => i.clientId == clientId).toList() ?? const [];
        final services =
            servicesAsync.valueOrNull?.where((s) => s.clientId == clientId).toList() ?? const [];
        final tickets =
            ticketsAsync.valueOrNull?.where((t) => t.clientId == clientId).toList() ?? const [];
        final payments = paymentsAsync.valueOrNull
                ?.where((p) => p['client_id']?.toString() == clientId)
                .toList() ??
            const [];
        final leads =
            leadsAsync.valueOrNull?.where((l) => l.clientId == clientId).toList() ?? const [];

        final allEmpty = projects.isEmpty &&
            invoices.isEmpty &&
            services.isEmpty &&
            tickets.isEmpty &&
            payments.isEmpty &&
            leads.isEmpty;

        if (!relatedLoading && allEmpty && !_ensureAttempted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _ensureLinked(client!);
          });
        }

        if ((relatedLoading || _ensuring) && allEmpty) {
          return const LoadingWidget();
        }

        final paidTotal = payments.fold<double>(
          0,
          (sum, p) => sum + ((p['amount'] as num?)?.toDouble() ?? 0),
        );

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FadeInUp(
              child: _HeroBanner(
                client: client,
                initials: _initials(client.name),
                onBack: () => context.go('/clients'),
              ),
            ),
            const SizedBox(height: 18),
            FadeInUp(
              delay: const Duration(milliseconds: 70),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await showLinkedInvoiceDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Add Invoice'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await showLinkedPaymentDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Add Payment'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await showLinkedProjectDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    icon: const Icon(Icons.folder, size: 18),
                    label: const Text('Add Project'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await showLinkedServiceDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    icon: const Icon(Icons.dns, size: 18),
                    label: const Text('Add Service'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await showLinkedTicketDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    icon: const Icon(Icons.support_agent, size: 18),
                    label: const Text('Add Ticket'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FadeInUp(
              delay: const Duration(milliseconds: 120),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatChip(label: 'Leads', value: '${leads.length}'),
                  _StatChip(label: 'Projects', value: '${projects.length}'),
                  _StatChip(label: 'Invoices', value: '${invoices.length}'),
                  _StatChip(label: 'Services', value: '${services.length}'),
                  _StatChip(label: 'Tickets', value: '${tickets.length}'),
                  _StatChip(label: 'Payments', value: Formatters.formatCurrency(paidTotal)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 160),
              child: Column(
                children: [
                  _Section(
                    title: 'Leads',
                    empty: leads.isEmpty,
                    children: leads
                        .map(
                          (l) => _RecordRow(
                            title: l.name,
                            subtitle:
                                '${l.source ?? 'lead'} · ${Formatters.formatCurrency(l.value)}',
                            trailing: StatusBadge(status: l.stage, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Projects',
                    empty: projects.isEmpty,
                    onAdd: () async {
                      await showLinkedProjectDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    children: projects
                        .map(
                          (p) => _RecordRow(
                            title: p.title,
                            subtitle: 'Budget ${Formatters.formatCurrency(p.budget)}',
                            trailing: StatusBadge(status: p.status, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Invoices',
                    empty: invoices.isEmpty,
                    onAdd: () async {
                      await showLinkedInvoiceDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    children: invoices
                        .map(
                          (i) => _RecordRow(
                            title: i.invoiceNumber,
                            subtitle: Formatters.formatCurrency(i.total),
                            trailing: StatusBadge(status: i.status, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Services',
                    empty: services.isEmpty,
                    onAdd: () async {
                      await showLinkedServiceDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    children: services
                        .map(
                          (s) => _RecordRow(
                            title: s.name,
                            subtitle: '${s.type} · expires ${Formatters.formatDate(s.expiryDate)}',
                            trailing: StatusBadge(status: s.status, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Payments',
                    empty: payments.isEmpty,
                    onAdd: () async {
                      await showLinkedPaymentDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    children: payments
                        .map(
                          (p) => _RecordRow(
                            title: Formatters.formatCurrency(
                              (p['amount'] as num?)?.toDouble() ?? 0,
                            ),
                            subtitle: p['method']?.toString() ?? '-',
                            trailing: Text(
                              Formatters.formatDate(
                                p['paid_at'] != null
                                    ? DateTime.tryParse(p['paid_at'].toString())
                                    : null,
                              ),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontFamily: AppTypography.body,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  _Section(
                    title: 'Tickets',
                    empty: tickets.isEmpty,
                    onAdd: () async {
                      await showLinkedTicketDialog(context, ref, clientId: clientId);
                      await _refresh();
                    },
                    children: tickets
                        .map(
                          (t) => _RecordRow(
                            title: t.subject,
                            subtitle: t.ticketNumber,
                            trailing: StatusBadge(status: t.status, compact: true),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final ClientModel client;
  final String initials;
  final VoidCallback onBack;

  const _HeroBanner({
    required this.client,
    required this.initials,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Spacer(),
                  StatusBadge(status: client.status),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: AppTypography.display,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLIENT HUB',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.body,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.display,
                            letterSpacing: -0.7,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (client.company != null && client.company!.isNotEmpty)
                              client.company!,
                            if (client.email != null) client.email!,
                            if (client.phone != null) client.phone!,
                          ].join(' · '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontFamily: AppTypography.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Linked lead, projects, invoices, payments, services, and tickets live here.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontFamily: AppTypography.body,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.panelGradient,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontFamily: AppTypography.body,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.display,
              fontSize: 17,
              letterSpacing: -0.3,
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
  final VoidCallback? onAdd;

  const _Section({
    required this.title,
    required this.empty,
    required this.children,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.panelGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.display,
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (onAdd != null)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (empty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No linked records yet — tap Add to create one for this client',
                style: TextStyle(color: AppColors.textMuted, fontFamily: AppTypography.body),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _RecordRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.body,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: AppTypography.body,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
