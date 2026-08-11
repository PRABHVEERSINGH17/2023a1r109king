import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';

/// Google / Apple / LinkedIn sign-in buttons for login & signup screens.
///
/// These only work after each provider is enabled in the Supabase dashboard.
/// Until then, email Sign Up / Demo Mode are the supported paths.
class SocialAuthButtons extends ConsumerStatefulWidget {
  const SocialAuthButtons({super.key});

  @override
  ConsumerState<SocialAuthButtons> createState() => _SocialAuthButtonsState();
}

class _SocialAuthButtonsState extends ConsumerState<SocialAuthButtons> {
  SocialAuthProvider? _busy;

  Future<void> _onTap(SocialAuthProvider provider) async {
    if (_busy != null) return;
    setState(() => _busy = provider);

    final auth = ref.read(authServiceProvider);
    try {
      await auth.signInWithSocial(provider);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Complete ${provider.name} sign-in in the browser window…',
          ),
        ),
      );

      final ok = await auth.waitForSession();
      if (!mounted) return;
      if (ok) {
        context.go('/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sign-in was not completed. Use email Sign Up or Demo Mode.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().toLowerCase();
      final needsSetup = message.contains('supabase') ||
          message.contains('provider is not enabled') ||
          message.contains('unsupported provider') ||
          message.contains('validation_failed');

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            needsSetup
                ? '${_label(provider)} is not enabled yet'
                : '${_label(provider)} sign-in failed',
          ),
          content: Text(
            needsSetup
                ? 'Enable ${_label(provider)} in Supabase → Authentication → Providers '
                    '(see SOCIAL_LOGIN.md).\n\n'
                    'Right now use:\n'
                    '• Create Online Account (email Sign Up)\n'
                    '• Or Continue with Demo Mode'
                : '$e',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go('/signup');
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authServiceProvider).enterDemoMode();
                if (!context.mounted) return;
                context.go('/dashboard');
              },
              child: const Text('Demo Mode'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  String _label(SocialAuthProvider provider) => switch (provider) {
        SocialAuthProvider.google => 'Google',
        SocialAuthProvider.apple => 'Apple',
        SocialAuthProvider.linkedin => 'LinkedIn',
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Or continue with',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: AppTypography.body,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.warning.withOpacity(0.35)),
          ),
          child: Text(
            SupabaseConfig.isConfigured
                ? 'Google / Apple / LinkedIn need to be turned on in Supabase first. Use email Sign Up or Demo Mode until then.'
                : 'Social login needs Supabase. Use email Sign Up or Demo Mode.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11.5,
              height: 1.35,
              fontFamily: AppTypography.body,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          label: 'Continue with Google',
          background: Colors.white,
          foreground: const Color(0xFF1F1F1F),
          border: AppColors.border,
          icon: Icons.g_mobiledata_rounded,
          loading: _busy == SocialAuthProvider.google,
          onPressed: _busy == null ? () => _onTap(SocialAuthProvider.google) : null,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          label: 'Continue with Apple',
          background: const Color(0xFF111111),
          foreground: Colors.white,
          border: const Color(0xFF111111),
          icon: Icons.apple,
          loading: _busy == SocialAuthProvider.apple,
          onPressed: _busy == null ? () => _onTap(SocialAuthProvider.apple) : null,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          label: 'Continue with LinkedIn',
          background: const Color(0xFF0A66C2),
          foreground: Colors.white,
          border: const Color(0xFF0A66C2),
          icon: Icons.work_outline_rounded,
          loading: _busy == SocialAuthProvider.linkedin,
          onPressed: _busy == null ? () => _onTap(SocialAuthProvider.linkedin) : null,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foreground,
                ),
              )
            : Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: AppTypography.body,
          ),
        ),
      ),
    );
  }
}
