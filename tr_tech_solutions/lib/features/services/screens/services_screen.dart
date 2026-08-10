import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/service.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getServices();
});

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Services',
            subtitle: 'Manage domains, hosting, and other services',
            action: ElevatedButton.icon(
              onPressed: () => showLinkedServiceDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Service'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: servicesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(servicesProvider)),
              data: (services) {
                if (services.isEmpty) {
                  return EmptyState(
                    icon: Icons.dns_outlined,
                    title: 'No services yet',
                    actionLabel: 'Add Service',
                    onAction: () => showLinkedServiceDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Service Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Expiry Date')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: services.map((s) {
                        return DataRow(cells: [
                          DataCell(Text(s.name)),
                          DataCell(Text(s.type)),
                          DataCell(Text(s.clientName ?? '-')),
                          DataCell(Text(Formatters.formatDate(s.expiryDate))),
                          DataCell(StatusBadge(status: s.status, compact: true)),
                          DataCell(Row(children: [
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              onPressed: () async {
                                await ref.read(dataServiceProvider)?.deleteService(s.id);
                                ref.invalidate(servicesProvider);
                              },
                            ),
                          ])),
                        ]);
                      }).toList(),
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
