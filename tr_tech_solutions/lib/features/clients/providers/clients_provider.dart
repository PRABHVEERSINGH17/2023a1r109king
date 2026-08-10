import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';

final clientsProvider = FutureProvider<List<ClientModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getClients();
});
