import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';
import '../../providers/user_providers.dart';
import '../../router/app_router.dart';

/// Login screen for authentication.
///
/// Implements UC02 (Create account / Login).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _loadingMethod;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Criar conta' : 'Entrar'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Social login buttons
              _buildSocialLoginSection(),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 32),

              // Email form
              _buildEmailForm(),

              const SizedBox(height: 24),

              // Toggle sign up / sign in
              TextButton(
                onPressed: () {
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(
                  _isSignUp
                      ? 'Ja tem uma conta? Entrar'
                      : 'Nao tem conta? Criar uma',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                _isLoading ? null : () => _signInWithSocial('google'),
            icon: _loadingMethod == 'google'
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.g_mobiledata_rounded, size: 24),
            label: const Text('Continuar com Google'),
          ),
        ),

        const SizedBox(height: 12),

        // Apple Sign In (only on iOS/macOS)
        if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _isLoading ? null : () => _signInWithSocial('apple'),
              icon: _loadingMethod == 'apple'
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.apple_rounded, size: 24),
              label: const Text('Continuar com Apple'),
            ),
          ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe o email';
              }
              if (!value.contains('@')) {
                return 'Email invalido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe a senha';
              }
              if (value.length < 6) {
                return 'Senha deve ter pelo menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              child: _loadingMethod == 'email'
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isSignUp ? 'Criar conta' : 'Entrar'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithSocial(String method) async {
    setState(() {
      _isLoading = true;
      _loadingMethod = method;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final result = method == 'google'
          ? await authRepo.signInWithGoogle()
          : await authRepo.signInWithApple();

      result.fold(
        (failure) {
          // E2: Cancelled or error
          if (failure.code != 'auth-cancelled') {
            context.showErrorSnackBar(failure.message);
          }
        },
        (user) async {
          await _handleSuccessfulLogin(userRepo);
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMethod = null;
        });
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingMethod = 'email';
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final result = _isSignUp
          ? await authRepo.signUpWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await authRepo.signInWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

      result.fold(
        (failure) {
          context.showErrorSnackBar(failure.message);
        },
        (user) async {
          await _handleSuccessfulLogin(userRepo);
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMethod = null;
        });
      }
    }
  }

  Future<void> _handleSuccessfulLogin(userRepository) async {
    // Check if there's local data to handle (UC03)
    final hasLocalData = await userRepository.hasLocalData();

    if (mounted) {
      final hasLocal = hasLocalData.fold((_) => false, (v) => v);

      if (hasLocal) {
        // Go to link data screen (UC03)
        context.go(AppRoutes.linkData);
      } else {
        // No local data, go directly to home
        await userRepository.setOnboardingComplete();
        context.go(AppRoutes.home);
      }
    }
  }
}
