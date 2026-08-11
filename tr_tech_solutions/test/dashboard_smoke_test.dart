import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/features/dashboard/screens/dashboard_screen.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/services/demo_repository.dart';

void main() {
  testWidgets('dashboard renders KPIs and module shortcuts in demo mode', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoModeProvider.overrideWith((ref) => true),
          demoRepositoryProvider.overrideWithValue(DemoRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DashboardScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Go to module'), findsOneWidget);
    expect(find.text('Clients'), findsWidgets);
    expect(find.text('Total Revenue'), findsOneWidget);
    expect(find.text('Total Clients'), findsOneWidget);
    expect(find.text('Revenue Overview'), findsOneWidget);
  });
}
