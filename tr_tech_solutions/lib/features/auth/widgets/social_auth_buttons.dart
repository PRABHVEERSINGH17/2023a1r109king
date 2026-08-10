import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';

/// Google / Apple / LinkedIn sign-in buttons for login & signup screens.
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
              'Sign-in was not completed. Try again, or use Demo Mode.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      final needsSetup = message.contains('Supabase') ||
          message.contains('provider is not enabled') ||
          message.contains('Unsupported provider') ||
          message.contains('validation_failed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            needsSetup
                ? 'Enable ${provider.name} in Supabase (see SOCIAL_LOGIN.md), or use Demo Mode.'
                : 'Social login failed: $e',
          ),
          action: SnackBarAction(
            label: 'Demo Mode',
            textColor: AppColors.primaryLight,
            onPressed: () async {
              await ref.read(authServiceProvider).enterDemoMode();
              if (!context.mounted) return;
              context.go('/dashboard');
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

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
        const SizedBox(height: 14),
        if (!SupabaseConfig.isConfigured)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Social login needs Supabase providers enabled (SOCIAL_LOGIN.md). Demo Mode works now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                height: 1.35,
                fontFamily: AppTypography.body,
              ),
            ),
          ),
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: AppTypography.body,
          ),
        ),
      ),
    );
  }
}
