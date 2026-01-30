import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth_providers.dart';
import '../../providers/user_providers.dart';
import '../../router/app_router.dart';

/// Screen to handle data linking after first login.
///
/// Implements UC03 (Link local data to account).
class LinkDataScreen extends ConsumerStatefulWidget {
  const LinkDataScreen({super.key});

  @override
  ConsumerState<LinkDataScreen> createState() => _LinkDataScreenState();
}

class _LinkDataScreenState extends ConsumerState<LinkDataScreen> {
  bool _isLoading = false;
  SyncStrategy? _selectedStrategy;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronizar dados'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info icon
              Icon(
                Icons.sync_rounded,
                size: 64,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Dados locais encontrados',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Voce tem dados salvos neste dispositivo. '
                'Como deseja proceder?',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Options
              _buildOption(
                strategy: SyncStrategy.keepLocal,
                icon: Icons.upload_rounded,
                title: 'Manter meus dados locais',
                description: 'Enviar dados deste dispositivo para a nuvem',
              ),

              const SizedBox(height: 12),

              _buildOption(
                strategy: SyncStrategy.downloadRemote,
                icon: Icons.download_rounded,
                title: 'Baixar dados da nuvem',
                description: 'Substituir dados locais pelos da nuvem',
              ),

              const SizedBox(height: 12),

              _buildOption(
                strategy: SyncStrategy.merge,
                icon: Icons.merge_rounded,
                title: 'Mesclar dados',
                description: 'Combinar dados locais e da nuvem',
              ),

              const Spacer(),

              // Continue button
              FilledButton(
                onPressed: _selectedStrategy == null || _isLoading
                    ? null
                    : _executeSync,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required SyncStrategy strategy,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedStrategy == strategy;

    return InkWell(
      onTap: _isLoading ? null : () => setState(() => _selectedStrategy = strategy),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? context.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeSync() async {
    if (_selectedStrategy == null) return;

    setState(() => _isLoading = true);

    try {
      final userRepo = ref.read(userRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      if (currentUser?.remoteId == null) {
        context.showErrorSnackBar('Erro: usuario nao autenticado');
        return;
      }

      final result = await userRepo.executeSyncStrategy(
        remoteId: currentUser!.remoteId!,
        strategy: _selectedStrategy!,
      );

      result.fold(
        (failure) {
          // E1: Conflict not resolved - apply "most recent wins"
          context.showErrorSnackBar(
            'Conflito detectado: ${failure.message}. '
            'Aplicando estrategia "mais recente vence".',
          );
          // Still continue to home
          _completeAndNavigate();
        },
        (_) {
          _completeAndNavigate();
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeAndNavigate() async {
    final userRepo = ref.read(userRepositoryProvider);
    await userRepo.setOnboardingComplete();

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }
}
