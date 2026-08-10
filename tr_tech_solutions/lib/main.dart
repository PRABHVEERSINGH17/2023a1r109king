import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_theme.dart';
import 'package:tr_tech_solutions/router/app_router.dart';
import 'package:tr_tech_solutions/shared/services/demo_persistence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore Demo Mode + saved clients/invoices before the first frame.
  await DemoPersistence.init();

  // Optional live backend keys. Demo Mode works with or without this file.
  try {
    await dotenv.load(fileName: 'assets/supabase.env');
  } catch (_) {
    // Continue — Demo Mode remains fully usable.
  }

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
      );
    } catch (_) {
      // Continue — Demo Mode remains fully usable.
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        // Keep the user in Demo Mode across browser/app refresh.
        demoModeProvider.overrideWith((ref) => DemoPersistence.isDemoMode),
      ],
      child: const TrTechApp(),
    ),
  );
}

class TrTechApp extends ConsumerWidget {
  const TrTechApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'TR Technology Solutions',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
