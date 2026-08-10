import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/client_picker.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/status_badge.dart';

final projectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final service = ref.watch(dataServiceProvider);
  if (service == null) return [];
  return service.getProjects();
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Projects',
            subtitle: 'Track project progress and deliverables',
            action: ElevatedButton.icon(
              onPressed: () => _showProjectDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Project'),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: projectsAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => AppErrorWidget(message: e.toString(), onRetry: () => ref.invalidate(projectsProvider)),
              data: (projects) {
                if (projects.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_outlined,
                    title: 'No projects yet',
                    actionLabel: 'Add Project',
                    onAction: () => _showProjectDialog(context, ref),
                  );
                }
                return DataListCard(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Due Date')),
                        DataColumn(label: Text('Budget')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: projects.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p.title)),
                          DataCell(Text(p.clientName ?? '-')),
                          DataCell(StatusBadge(status: p.status, compact: true)),
                          DataCell(Text(Formatters.formatDate(p.dueDate))),
                          DataCell(Text(Formatters.formatCurrency(p.budget))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () async {
                              await ref.read(dataServiceProvider)?.deleteProject(p.id);
                              ref.invalidate(projectsProvider);
                            },
                          )),
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

  Future<void> _showProjectDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final budgetController = TextEditingController();
    var status = 'in_progress';
    String? clientId;
    DateTime? dueDate;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Project'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClientPickerField(
                    value: clientId,
                    onChanged: (v) => setState(() => clientId = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title *')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Budget', prefixText: '₹ '),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'planning', child: Text('Planning')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'review', child: Text('Review')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    ],
                    onChanged: (v) => setState(() => status = v ?? 'in_progress'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(dueDate == null ? 'Select Due Date' : 'Due: ${Formatters.formatDate(dueDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => dueDate = date);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || clientId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select a client and enter a title')),
                  );
                  return;
                }
                await ref.read(dataServiceProvider)?.createProject({
                  'client_id': clientId,
                  'title': titleController.text.trim(),
                  'budget': double.tryParse(budgetController.text) ?? 0,
                  'status': status,
                  'due_date': dueDate?.toIso8601String().split('T').first,
                });
                ref.invalidate(projectsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
