import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tr_tech_solutions/core/config/supabase_config.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
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
                  ? 'Invalid credentials. Use Sign Up first, or click Continue with Demo Mode.'
                  : 'Login failed: $e',
            ),
            action: SnackBarAction(
              label: 'Demo Mode',
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0F19), Color(0xFF1a1040), Color(0xFF0B0F19)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          ),
          child: const Icon(Icons.business_center, color: AppColors.primary, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'TR Technology Solutions',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Business Management Platform',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use demo login below, or sign up with your own email for Supabase.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Text(
                  SupabaseConfig.isConfigured
                      ? 'Demo login: admin@trtechsolutions.com / demo1234\nOr click Continue with Demo Mode.'
                      : 'Demo mode ready. Click Continue with Demo Mode.',
                  style: const TextStyle(color: AppColors.info, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _enterDemo,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Continue with Demo Mode'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?",
                      style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
