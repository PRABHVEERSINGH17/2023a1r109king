import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/providers/local_auth_provider.dart';
import 'package:tr_tech_solutions/core/theme/app_theme.dart';
import 'package:tr_tech_solutions/router/app_router.dart';
import 'package:tr_tech_solutions/shared/services/demo_persistence.dart';
import 'package:tr_tech_solutions/shared/services/local_account_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore Demo Mode / local accounts before the first frame.
  await DemoPersistence.init();
  await LocalAccountStore.init();

  // Optional live backend keys. Demo Mode + local accounts work without this.
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
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
    } catch (_) {
      // Continue — Demo Mode / local auth remain fully usable.
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        demoModeProvider.overrideWith((ref) => DemoPersistence.isDemoMode),
        localAuthProvider.overrideWith((ref) => LocalAccountStore.hasSession),
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
