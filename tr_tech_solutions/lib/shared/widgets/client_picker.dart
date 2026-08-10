import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/shared/models/client.dart';

/// Dropdown to link a record to an existing CRM client.
class ClientPickerField extends ConsumerWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool required;
  final String label;

  const ClientPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.required = true,
    this.label = 'Client',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsProvider);

    return clientsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Could not load clients: $e'),
      data: (clients) {
        if (clients.isEmpty) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: 'Add a client first in Clients module',
            ),
            child: const Text('No clients available'),
          );
        }

        final active = clients.where((c) => c.status == 'active').toList();
        final options = active.isNotEmpty ? active : clients;

        return DropdownButtonFormField<String>(
          value: options.any((c) => c.id == value) ? value : null,
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
          ),
          items: options
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(_label(c), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Select a client' : null
              : null,
        );
      },
    );
  }

  String _label(ClientModel c) {
    if (c.company != null && c.company!.isNotEmpty) {
      return '${c.name} · ${c.company}';
    }
    return c.name;
  }
}
