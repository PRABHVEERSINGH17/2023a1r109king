import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_theme.dart';
import 'package:tr_tech_solutions/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  final url = SupabaseConfig.url;
  final anonKey = SupabaseConfig.anonKey;

  if (url.isNotEmpty && anonKey.isNotEmpty && !url.contains('YOUR_SUPABASE')) {
    await Supabase.initialize(url: url, anonKey: anonKey); // ignore: deprecated_member_use
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
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
