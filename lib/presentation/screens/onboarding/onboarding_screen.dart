import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';
import '../../providers/user_providers.dart';
import '../../router/app_router.dart';

/// Onboarding screen - first screen users see.
///
/// Implements UC01 (Use without account) and leads to UC02 (Create account/Login).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App logo
              Image.asset(
                'assets/images/logo.png',
                width: 220,
                height: 220,
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                'Study Deck',
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Aprenda com flashcards inteligentes',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Micro social proof (apenas 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⭐️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    'Mais de 10.000 cards criados com IA',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // AI feature highlight (above buttons)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'Criar flashcards com IA (gratis)',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Primary: Create account / Login button (empurra para login)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _goToLogin,
                  icon: const Icon(Icons.person_rounded),
                  label: const Text('Entrar ou criar conta'),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Salve seus cards, progresso e creditos',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Secondary: Use without account (UC01)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _useWithoutAccount,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.rocket_launch_rounded),
                  label: const Text('Ganhar creditos gratis'),
                ),
              ),

              const SizedBox(height: 24),

              // Info text - mais tranquilizador
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Sem conta, seus dados ficam apenas neste dispositivo.\n'
                      'Voce pode criar uma conta depois sem perder seus cards.',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Trust signals - transparencia sobre anuncios
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('📺', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        'Anuncios opcionais para ganhar creditos de IA',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💳', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        'Nenhum cartao e exigido',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// UC01 - Use without account
  Future<void> _useWithoutAccount() async {
    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);

      final result = await authRepo.useWithoutAccount();

      result.fold(
        (failure) {
          // E1: Falha ao criar perfil local
          _showRetryDialog(failure.message);
        },
        (user) async {
          // Mark onboarding as complete
          await userRepo.setOnboardingComplete();

          if (mounted) {
            context.go(AppRoutes.home);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToLogin() {
    context.push(AppRoutes.login);
  }

  void _showRetryDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _useWithoutAccount();
            },
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
