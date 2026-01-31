import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/privacy_settings.dart';
import '../../providers/privacy_providers.dart';
import '../../router/app_router.dart';

/// UC267: LGPD consent screen.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _analyticsConsent = false;
  bool _marketingConsent = false;
  bool _isLoading = false;

  bool get _canContinue => _termsAccepted && _privacyAccepted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final privacyPolicy = ref.watch(privacyPolicyProvider);
    final termsOfService = ref.watch(termsOfServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos e Privacidade'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(
              Icons.security,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Sua privacidade é importante',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Antes de continuar, precisamos do seu consentimento para alguns itens importantes.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Required consents
            Text(
              'Obrigatório',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ConsentTile(
              title: 'Termos de Uso',
              subtitle: termsOfService.summary,
              value: _termsAccepted,
              onChanged: (v) => setState(() => _termsAccepted = v ?? false),
              onTapDetails: () => _showTerms(context, termsOfService),
              required: true,
            ),
            const SizedBox(height: 8),
            _ConsentTile(
              title: 'Política de Privacidade',
              subtitle: privacyPolicy.summary,
              value: _privacyAccepted,
              onChanged: (v) => setState(() => _privacyAccepted = v ?? false),
              onTapDetails: () => _showPrivacy(context, privacyPolicy),
              required: true,
            ),
            const SizedBox(height: 24),

            // Optional consents
            Text(
              'Opcional',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ConsentTile(
              title: 'Analytics',
              subtitle: 'Ajude-nos a melhorar o app compartilhando dados de uso anônimos.',
              value: _analyticsConsent,
              onChanged: (v) => setState(() => _analyticsConsent = v ?? false),
              required: false,
            ),
            const SizedBox(height: 8),
            _ConsentTile(
              title: 'Comunicações',
              subtitle: 'Receba novidades, dicas de estudo e ofertas especiais.',
              value: _marketingConsent,
              onChanged: (v) => setState(() => _marketingConsent = v ?? false),
              required: false,
            ),
            const SizedBox(height: 32),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Você pode alterar essas preferências a qualquer momento nas configurações.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue button
            FilledButton(
              onPressed: _canContinue && !_isLoading ? _saveConsent : null,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTerms(BuildContext context, TermsOfServiceInfo terms) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termos de Uso'),
        content: SingleChildScrollView(
          child: Text(terms.summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context, PrivacyPolicyInfo policy) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: SingleChildScrollView(
          child: Text(policy.summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveConsent() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(privacyServiceProvider);
      // TODO: Get actual userId from auth
      const userId = 'user_id';

      await recordConsentDirect(
        service,
        userId,
        termsAccepted: _termsAccepted,
        privacyAccepted: _privacyAccepted,
        analyticsConsent: _analyticsConsent,
        marketingConsent: _marketingConsent,
      );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ConsentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onTapDetails;
  final bool required;

  const _ConsentTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.onTapDetails,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (required) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (onTapDetails != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: onTapDetails,
                      child: Text(
                        'Ver detalhes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
