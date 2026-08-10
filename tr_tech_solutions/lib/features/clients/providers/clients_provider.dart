import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';

/// Recently created/updated clients kept in memory so UI never "loses" them
/// during provider refresh races after Add Client.
final localClientsOverrideProvider =
    StateProvider<List<ClientModel>>((ref) => const []);

void rememberClient(WidgetRef ref, ClientModel client) {
  final current = ref.read(localClientsOverrideProvider);
  final next = <ClientModel>[
    client,
    ...current.where((c) => c.id != client.id),
  ];
  ref.read(localClientsOverrideProvider.notifier).state = next;
}

List<ClientModel> mergeClientsWithOverrides(
  List<ClientModel> fetched,
  List<ClientModel> overrides,
) {
  if (overrides.isEmpty) return fetched;
  final byId = <String, ClientModel>{
    for (final c in fetched) c.id: c,
  };
  for (final c in overrides.reversed) {
    byId[c.id] = c;
  }
  // Keep override-first order for brand-new clients, then remaining fetched.
  final ordered = <ClientModel>[];
  final seen = <String>{};
  for (final c in overrides) {
    ordered.add(byId[c.id]!);
    seen.add(c.id);
  }
  for (final c in fetched) {
    if (seen.add(c.id)) ordered.add(c);
  }
  return ordered;
}

final clientsProvider = FutureProvider<List<ClientModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  final overrides = ref.watch(localClientsOverrideProvider);
  if (service == null) return mergeClientsWithOverrides(const [], overrides);
  final fetched = await service.getClients();
  return mergeClientsWithOverrides(fetched, overrides);
});
