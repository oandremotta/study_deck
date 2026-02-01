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

  bool? _hasLocalData;

  @override
  void initState() {
    super.initState();
    _checkLocalData();
  }

  Future<void> _checkLocalData() async {
    final userRepo = ref.read(userRepositoryProvider);
    final result = await userRepo.hasLocalData();
    if (mounted) {
      setState(() {
        _hasLocalData = result.fold((_) => false, (v) => v);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sem AppBar - UX premium (Notion, Linear, ChatGPT, Duolingo)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mini-hero de contexto
                  _buildMiniHero(context),

                  const SizedBox(height: 32),

                  // Alerta para usuario guest com dados nao sincronizados
                  if (_hasLocalData == true) _buildGuestDataAlert(context),

                  // Social login buttons
                  _buildSocialLoginSection(),

                  const SizedBox(height: 32),

                  // Divider - mais humano
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou continue com email',
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

                  const SizedBox(height: 8),

                  // Esqueceu a senha? - mais visivel
                  if (!_isSignUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Esqueceu sua senha?',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 24),

                  // Divisor visual sutil
                  Divider(
                    color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),

                  const SizedBox(height: 16),

                  // Continuar sem conta - escape silencioso
                  GestureDetector(
                    onTap: _isLoading ? null : _continueWithoutAccount,
                    child: Column(
                      children: [
                        Text(
                          'Continuar sem conta',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '(ganhe creditos com anuncios)',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Microcopy tranquilizadora
                  Text(
                    'Voce pode criar uma conta depois sem perder seus cards',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Trust signals - rodape (foco em valor, nao tecnico)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 14,
                            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Nunca perdemos seus cards ou creditos',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Text(
                            'Seus dados sao criptografados',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Mini-hero de contexto no topo
  Widget _buildMiniHero(BuildContext context) {
    return Column(
      children: [
        // Logo
        Image.asset(
          'assets/images/logo.png',
          width: 220,
          height: 220,
        ),
        const SizedBox(height: 16),
        Text(
          'Study Deck',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Seus cards, progresso e creditos sincronizados',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Alerta para usuario guest com dados nao sincronizados
  Widget _buildGuestDataAlert(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade600, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voce tem cards e creditos nao sincronizados',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Entre para nao perder nada',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
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

        // Microcopy abaixo do Google
        const SizedBox(height: 6),
        Text(
          'Entrar em 1 toque, sem senha',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

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
                return 'Verifique o formato do email';
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
                  : Text(_isSignUp
                      ? 'Criar conta e manter meus estudos salvos'
                      : 'Entrar e manter meus estudos salvos'),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar senha'),
        content: const Text(
          'Para recuperar sua senha, acesse o site e clique em "Esqueci minha senha" na pagina de login.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
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
          final code = failure.code ?? 'unknown';
          if (code != 'auth-cancelled') {
            _showFriendlyError(code, failure.message);
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
          _showFriendlyError(failure.code ?? 'unknown', failure.message);
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

  /// Continuar sem conta (escape silencioso)
  Future<void> _continueWithoutAccount() async {
    setState(() {
      _isLoading = true;
      _loadingMethod = 'guest';
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final result = await authRepo.useWithoutAccount();

      result.fold(
        (failure) {
          context.showErrorSnackBar(failure.message);
        },
        (user) async {
          await userRepo.setOnboardingComplete();
          if (mounted) {
            context.go(AppRoutes.home);
          }
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

  /// Mostra erro amigavel ao usuario
  void _showFriendlyError(String code, String fallbackMessage) {
    String message;

    switch (code) {
      case 'user-not-found':
        message = 'Nao encontramos uma conta com esse email';
        break;
      case 'wrong-password':
        message = 'Senha incorreta. Tente novamente ou recupere sua senha.';
        break;
      case 'invalid-email':
        message = 'Verifique o formato do email';
        break;
      case 'email-already-in-use':
        message = 'Esse email ja esta em uso. Tente entrar ao inves de criar conta.';
        break;
      case 'weak-password':
        message = 'Senha muito fraca. Use pelo menos 6 caracteres.';
        break;
      case 'network-request-failed':
        message = 'Sem conexao com a internet. Verifique sua rede.';
        break;
      case 'too-many-requests':
        message = 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
        break;
      default:
        message = fallbackMessage;
    }

    context.showErrorSnackBar(message);
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
