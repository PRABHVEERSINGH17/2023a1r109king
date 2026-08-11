import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
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
            requireCloud: true,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (!mounted) return;
      if (e is LiveAuthSetupException) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(e.title),
            content: Text(e.steps),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
        return;
      }
      final message = e.toString().toLowerCase();
      final isInvalid = message.contains('invalid') ||
          message.contains('credentials') ||
          message.contains('email not confirmed');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInvalid
                ? 'Invalid email or password. Create an account first with Sign Up.'
                : 'Login failed: $e',
          ),
        ),
      );
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
                  padding: EdgeInsets.all(AppBreakpoints.isCompact(context) ? 14 : 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 980 : 440),
                    child: wide
                        ? Row(
                            children: [
                              Expanded(child: FadeInUp(child: _BrandPanel())),
                              const SizedBox(width: 28),
                              Expanded(
                                child: FadeInUp(
                                  delay: const Duration(milliseconds: 120),
                                  child: _buildLoginCard(),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              FadeInUp(child: _BrandPanel(compact: true)),
                              const SizedBox(height: 20),
                              FadeInUp(
                                delay: const Duration(milliseconds: 100),
                                child: _buildLoginCard(),
                              ),
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
    final compact = MediaQuery.sizeOf(context).width < 400;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      padding: EdgeInsets.all(compact ? 18 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign in',
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
              'Live TR Tech CRM — your data saves to the cloud.',
              style: TextStyle(color: AppColors.textSecondary, fontFamily: AppTypography.body),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Use your real email and password.\nNew here? Tap Create Account below.',
                style: TextStyle(
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => context.go('/signup'),
                child: const Text('Create Account'),
              ),
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
            'TR TECH',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontWeight: FontWeight.w800,
              fontSize: compact ? 18 : 22,
              letterSpacing: 2.2,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(
            'TR Technology\nSolutions',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 34 : 46,
              height: 1.05,
              letterSpacing: -1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Manage clients, invoices, services, and revenue in one live CRM.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontFamily: AppTypography.body,
              height: 1.45,
              fontSize: 14.5,
            ),
          ),
        ],
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
