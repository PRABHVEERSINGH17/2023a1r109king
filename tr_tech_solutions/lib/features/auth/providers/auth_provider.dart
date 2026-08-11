import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/core/providers/local_auth_provider.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/services/demo_persistence.dart';
import 'package:tr_tech_solutions/shared/services/local_account_store.dart';

const kDemoEmail = 'admin@trtechsolutions.com';
const kDemoPassword = 'demo1234';

/// Thrown when live cloud auth cannot complete until Supabase is configured.
class LiveAuthSetupException implements Exception {
  final String title;
  final String steps;

  const LiveAuthSetupException({
    required this.title,
    required this.steps,
  });

  @override
  String toString() => '$title\n\n$steps';
}

const kLiveEmailConfirmSteps =
    'Open Supabase Dashboard → project izpxnkovciqjotfbofkc\n'
    '1. Authentication → Providers → Email\n'
    '2. Turn OFF "Confirm email" → Save\n'
    '3. Come back here and Sign Up again with a real email\n\n'
    'This one setting makes the app fully live (no Google Client ID needed).';

enum SocialAuthProvider { google, apple, linkedin }

final authStateProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(const AuthState(AuthChangeEvent.initialSession, null));
  }
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (!SupabaseConfig.isConfigured) return null;
  return Supabase.instance.client.auth.currentUser;
});

class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  bool get isDemoMode => _ref.read(demoModeProvider);
  bool get isLocalAuth => _ref.read(localAuthProvider);

  String? get currentUserEmail {
    if (isDemoMode) return kDemoEmail;
    if (isLocalAuth) return LocalAccountStore.sessionEmail ?? 'local-user';
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.email;
  }

  String? get currentUserId {
    if (isDemoMode) return 'demo-user-001';
    if (isLocalAuth) {
      final email = LocalAccountStore.sessionEmail ?? 'local';
      return 'local-${email.hashCode}';
    }
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.id;
  }

  bool _isDemoCredentials(String email, String password) {
    return email.trim().toLowerCase() == kDemoEmail && password == kDemoPassword;
  }

  Future<void> _activateLocalSession() async {
    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;
    _ref.read(localAuthProvider.notifier).state = true;
  }

  Future<void> enterDemoMode({bool resetWorkspace = false}) async {
    if (resetWorkspace) {
      await DemoPersistence.clearWorkspace();
      _ref.read(demoWorkspaceVersionProvider.notifier).state++;
      _ref.read(localClientsOverrideProvider.notifier).state = const [];
    }
    await LocalAccountStore.clearSession();
    _ref.read(localAuthProvider.notifier).state = false;
    await DemoPersistence.setPreferLive(false);
    await DemoPersistence.setDemoMode(true);
    _ref.read(demoModeProvider.notifier).state = true;
  }

  /// Leave Demo Mode and return to the online login screen.
  Future<void> exitDemoAndGoOnline() async {
    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;
    await LocalAccountStore.clearSession();
    _ref.read(localAuthProvider.notifier).state = false;
    _ref.read(localClientsOverrideProvider.notifier).state = const [];
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }

  Future<void> signIn(
    String email,
    String password, {
    bool requireCloud = false,
  }) async {
    // Built-in demo account always works (unless forcing live cloud).
    if (!requireCloud && _isDemoCredentials(email, password)) {
      await enterDemoMode(resetWorkspace: false);
      return;
    }

    // 1) Try Supabase cloud auth when configured.
    if (SupabaseConfig.isConfigured) {
      try {
        await DemoPersistence.setPreferLive(true);
        await DemoPersistence.setDemoMode(false);
        _ref.read(demoModeProvider.notifier).state = false;
        _ref.read(localAuthProvider.notifier).state = false;
        await LocalAccountStore.clearSession();

        await Supabase.instance.client.auth.signInWithPassword(
          email: email.trim(),
          password: password,
        );
        if (Supabase.instance.client.auth.currentSession != null) {
          return;
        }
        if (requireCloud) {
          throw const LiveAuthSetupException(
            title: 'Live sign-in needs email confirmation turned off',
            steps: kLiveEmailConfirmSteps,
          );
        }
      } catch (e) {
        if (requireCloud) {
          final msg = e.toString().toLowerCase();
          if (e is LiveAuthSetupException) rethrow;
          if (msg.contains('email not confirmed') ||
              msg.contains('confirm') ||
              msg.contains('rate limit') ||
              msg.contains('over_email')) {
            throw const LiveAuthSetupException(
              title: 'Live login is blocked by Supabase email settings',
              steps: kLiveEmailConfirmSteps,
            );
          }
          rethrow;
        }
      }
    } else if (requireCloud) {
      throw const LiveAuthSetupException(
        title: 'Supabase is not configured',
        steps: 'Add SUPABASE_URL and SUPABASE_ANON_KEY in assets/supabase.env',
      );
    }

    if (requireCloud) {
      throw const LiveAuthSetupException(
        title: 'Could not create a live session',
        steps: kLiveEmailConfirmSteps,
      );
    }

    // 2) Device-local account (offline / fallback).
    await LocalAccountStore.signIn(email: email, password: password);
    await _activateLocalSession();
  }

  Future<void> signUp(
    String email,
    String password,
    String fullName, {
    bool requireCloud = true,
  }) async {
    Object? cloudError;

    if (SupabaseConfig.isConfigured) {
      try {
        await DemoPersistence.setPreferLive(true);
        await DemoPersistence.setDemoMode(false);
        _ref.read(demoModeProvider.notifier).state = false;

        final response = await Supabase.instance.client.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'full_name': fullName},
        );

        if (response.session != null) {
          _ref.read(localAuthProvider.notifier).state = false;
          await LocalAccountStore.clearSession();
          return;
        }
        // No session = Confirm email is still ON (or rate limited).
        cloudError = const LiveAuthSetupException(
          title: 'Account created in Supabase, but Confirm email is still ON',
          steps: kLiveEmailConfirmSteps,
        );
      } catch (e) {
        cloudError = e;
        final msg = e.toString().toLowerCase();
        if (msg.contains('rate limit') || msg.contains('over_email')) {
          cloudError = const LiveAuthSetupException(
            title: 'Supabase email rate limit hit',
            steps: kLiveEmailConfirmSteps,
          );
        }
      }
    } else if (requireCloud) {
      throw const LiveAuthSetupException(
        title: 'Supabase is not configured',
        steps: 'Add SUPABASE_URL and SUPABASE_ANON_KEY in assets/supabase.env',
      );
    }

    if (requireCloud) {
      if (cloudError is LiveAuthSetupException) throw cloudError;
      throw LiveAuthSetupException(
        title: 'Live Sign Up failed',
        steps: '${cloudError ?? "Unknown error"}\n\n$kLiveEmailConfirmSteps',
      );
    }

    // Offline fallback only when cloud is not required.
    try {
      await LocalAccountStore.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already exists')) {
        await LocalAccountStore.signIn(email: email, password: password);
      } else {
        throw cloudError ?? e;
      }
    }
    await _activateLocalSession();
  }

  /// Starts Google / Apple / LinkedIn OAuth via Supabase.
  Future<void> signInWithSocial(SocialAuthProvider provider) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Social login needs Supabase providers enabled. Use email Sign Up or Demo Mode.',
      );
    }

    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;
    _ref.read(localAuthProvider.notifier).state = false;

    final oauthProvider = switch (provider) {
      SocialAuthProvider.google => OAuthProvider.google,
      SocialAuthProvider.apple => OAuthProvider.apple,
      SocialAuthProvider.linkedin => OAuthProvider.linkedinOidc,
    };

    final launched = await Supabase.instance.client.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: SupabaseConfig.oauthRedirectTo,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );

    if (!launched) {
      throw StateError('Could not open the ${provider.name} sign-in page.');
    }
  }

  Future<bool> waitForSession({
    Duration timeout = const Duration(minutes: 2),
  }) async {
    if (!SupabaseConfig.isConfigured) return false;
    if (Supabase.instance.client.auth.currentSession != null) return true;

    final completer = Completer<bool>();
    late final StreamSubscription<AuthState> sub;
    sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.session != null && !completer.isCompleted) {
        completer.complete(true);
      }
    });

    try {
      return await completer.future.timeout(timeout, onTimeout: () => false);
    } finally {
      await sub.cancel();
    }
  }

  Future<void> signOut() async {
    await LocalAccountStore.clearSession();
    _ref.read(localAuthProvider.notifier).state = false;

    if (isDemoMode) {
      await DemoPersistence.setDemoMode(false);
      _ref.read(demoModeProvider.notifier).state = false;
      _ref.read(localClientsOverrideProvider.notifier).state = const [];
    }
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));
