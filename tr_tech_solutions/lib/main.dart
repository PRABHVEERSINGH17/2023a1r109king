import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_theme.dart';
import 'package:tr_tech_solutions/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: TrTechApp()));
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
