import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/utils/formatters.dart';
import 'package:tr_tech_solutions/features/clients/widgets/linked_create_dialogs.dart';
import 'package:tr_tech_solutions/shared/models/project.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/widgets/empty_state.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';
import 'package:tr_tech_solutions/shared/widgets/responsive_record_list.dart';
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
      padding: AppBreakpoints.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Projects',
            subtitle: 'Track project progress and deliverables',
            action: ElevatedButton.icon(
              onPressed: () => showLinkedProjectDialog(context, ref),
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
                    onAction: () => showLinkedProjectDialog(context, ref),
                  );
                }

                Widget deleteBtn(ProjectModel p) => IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () async {
                        await ref.read(dataServiceProvider)?.deleteProject(p.id);
                        ref.invalidate(projectsProvider);
                      },
                    );

                return ResponsiveRecordList(
                  table: DataTable(
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
                        DataCell(deleteBtn(p)),
                      ]);
                    }).toList(),
                  ),
                  list: ListView.separated(
                    itemCount: projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = projects[index];
                      return MobileRecordTile(
                        title: p.title,
                        subtitle:
                            '${p.clientName ?? 'No client'} · Budget ${Formatters.formatCurrency(p.budget)} · Due ${Formatters.formatDate(p.dueDate)}',
                        badge: StatusBadge(status: p.status, compact: true),
                        actions: [deleteBtn(p)],
                      );
                    },
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
