import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_motion.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@trtechsolutions.com');
  final _passwordController = TextEditingController(text: 'demo1234');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        final message = e.toString().toLowerCase();
        final isInvalid = message.contains('invalid') ||
            message.contains('credentials') ||
            message.contains('email not confirmed');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInvalid
                  ? 'Invalid credentials. Use Sign Up first, or continue in Demo Mode.'
                  : 'Login failed: $e',
            ),
            action: SnackBarAction(
              label: 'Demo Mode',
              textColor: AppColors.primaryLight,
              onPressed: _enterDemo,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enterDemo() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).enterDemoMode();
      if (mounted) context.go('/dashboard');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.heroGradient,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _Blob(size: 280, color: Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: _Blob(size: 320, color: AppColors.primaryLight.withOpacity(0.12)),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 980 : 440),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: FadeInUp(child: _BrandPanel())),
                              const SizedBox(width: 28),
                              Expanded(child: FadeInUp(delay: const Duration(milliseconds: 120), child: _buildLoginCard())),
                            ],
                          )
                        : Column(
                            children: [
                              FadeInUp(child: _BrandPanel(compact: true)),
                              const SizedBox(height: 24),
                              FadeInUp(delay: const Duration(milliseconds: 100), child: _buildLoginCard()),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.display,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sign in to manage clients, services, and revenue.',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: AppTypography.body),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                SupabaseConfig.isConfigured
                    ? 'Demo: admin@trtechsolutions.com / demo1234\nOr continue with Demo Mode instantly.'
                    : 'Demo Mode is ready — explore the full workspace with sample data.',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: AppTypography.body,
                ),
              ),
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _enterDemo,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Continue with Demo Mode'),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.textSecondary, fontFamily: AppTypography.body),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  final bool compact;

  const _BrandPanel({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 8 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TR Technology\nSolutions',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 36 : 52,
              height: 1.05,
              letterSpacing: -1.4,
              color: AppColors.textOnBrand,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A modern workspace for clients, renewals, invoices, and growth.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: compact ? 15 : 18,
              height: 1.45,
              fontFamily: AppTypography.body,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _FeatureChip(label: 'Clients & CRM'),
                _FeatureChip(label: 'Service renewals'),
                _FeatureChip(label: 'Sales reports'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textOnBrand,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: AppTypography.body,
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
