import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_motion.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/features/auth/providers/auth_provider.dart';
import 'package:tr_tech_solutions/features/auth/widgets/social_auth_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _onlineMode = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mode = GoRouterState.of(context).uri.queryParameters['mode'];
    final online = mode == 'online';
    if (online != _onlineMode) {
      _onlineMode = online;
      if (_onlineMode) {
        _emailController.clear();
        _passwordController.clear();
      } else if (_emailController.text.isEmpty) {
        _emailController.text = 'admin@trtechsolutions.com';
        _passwordController.text = 'demo1234';
      }
    }
  }

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
      // Restore saved workspace when present (clients survive refresh).
      await ref.read(authServiceProvider).enterDemoMode(resetWorkspace: false);
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
                  padding: EdgeInsets.all(AppBreakpoints.isCompact(context) ? 14 : 20),
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
                              const SizedBox(height: 20),
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
            Text(
              _onlineMode ? 'Go Online' : 'Welcome back',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.display,
                letterSpacing: -0.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _onlineMode
                  ? 'Create or sign in to your live TR Tech account.'
                  : 'Sign in to manage clients, services, and revenue.',
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: AppTypography.body),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _onlineMode
                    ? 'Sign Up with any email + password (min 6 chars).\nWorks on this device immediately. Cloud sync needs Supabase confirm-email off (see AUTH.md).'
                    : (SupabaseConfig.isConfigured
                        ? 'Demo: admin@trtechsolutions.com / demo1234\nOr Sign Up with your email — Sign In works after that.'
                        : 'Sign Up with your email, or use Demo Mode to explore sample data.'),
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
            if (_onlineMode) ...[
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => context.go('/signup'),
                  child: const Text('Create Online Account'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton(
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
              const SizedBox(height: 18),
              const SocialAuthButtons(),
              const SizedBox(height: 14),
              TextButton(
                onPressed: _isLoading ? null : _enterDemo,
                child: const Text('Back to Demo Mode'),
              ),
            ] else ...[
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _enterDemo,
                  icon: const Icon(Icons.bolt_rounded),
                  label: const Text('Continue with Demo Mode'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Recommended — full CRM with sample clients, invoices & payments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: AppTypography.body,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: OutlinedButton(
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
              const SizedBox(height: 18),
              const SocialAuthButtons(),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : () => context.go('/login?mode=online'),
                child: const Text('Exit Demo — Go Online'),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
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
