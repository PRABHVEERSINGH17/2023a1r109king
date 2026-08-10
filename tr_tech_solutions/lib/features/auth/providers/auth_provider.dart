import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/providers/app_mode_provider.dart';
import 'package:tr_tech_solutions/features/clients/providers/clients_provider.dart';
import 'package:tr_tech_solutions/shared/services/data_service.dart';
import 'package:tr_tech_solutions/shared/services/demo_persistence.dart';

const kDemoEmail = 'admin@trtechsolutions.com';
const kDemoPassword = 'demo1234';

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

  String? get currentUserEmail {
    if (isDemoMode) return kDemoEmail;
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.email;
  }

  String? get currentUserId {
    if (isDemoMode) return 'demo-user-001';
    if (!SupabaseConfig.isConfigured) return null;
    return Supabase.instance.client.auth.currentUser?.id;
  }

  bool _isDemoCredentials(String email, String password) {
    return email.trim().toLowerCase() == kDemoEmail && password == kDemoPassword;
  }

  Future<void> enterDemoMode({bool resetWorkspace = false}) async {
    if (resetWorkspace) {
      await DemoPersistence.clearWorkspace();
      _ref.read(demoWorkspaceVersionProvider.notifier).state++;
      _ref.read(localClientsOverrideProvider.notifier).state = const [];
    }
    await DemoPersistence.setPreferLive(false);
    await DemoPersistence.setDemoMode(true);
    _ref.read(demoModeProvider.notifier).state = true;
  }

  /// Leave Demo Mode and return to the online login screen.
  Future<void> exitDemoAndGoOnline() async {
    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;
    _ref.read(localClientsOverrideProvider.notifier).state = const [];
    if (SupabaseConfig.isConfigured) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
  }

  Future<void> signIn(String email, String password) async {
    // Built-in demo account always works, even when Supabase is configured.
    // Do NOT reset workspace — refresh/re-login must keep saved clients.
    if (_isDemoCredentials(email, password)) {
      await enterDemoMode(resetWorkspace: false);
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Online mode needs Supabase. Check assets/supabase.env, or use Demo Mode.',
      );
    }

    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String fullName) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Online signup needs Supabase. Check assets/supabase.env, or use Demo Mode.',
      );
    }

    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // If email confirmation is disabled, session is returned immediately.
    if (response.session != null) {
      return;
    }
  }

  /// Starts Google / Apple / LinkedIn OAuth via Supabase.
  ///
  /// Returns when the browser/auth sheet has been opened. The actual session
  /// arrives later through [authStateProvider] — callers should wait for it.
  Future<void> signInWithSocial(SocialAuthProvider provider) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Social login needs Supabase. Open SOCIAL_LOGIN.md to enable Google, Apple, and LinkedIn, '
        'or use Demo Mode.',
      );
    }

    await DemoPersistence.setPreferLive(true);
    await DemoPersistence.setDemoMode(false);
    _ref.read(demoModeProvider.notifier).state = false;

    final oauthProvider = switch (provider) {
      SocialAuthProvider.google => OAuthProvider.google,
      SocialAuthProvider.apple => OAuthProvider.apple,
      // Prefer LinkedIn OIDC (current Supabase provider).
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

  /// Waits until a Supabase session exists (after OAuth redirect) or times out.
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
    if (isDemoMode) {
      // Keep workspace on disk so the next Demo Mode session restores clients.
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
