import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/privacy_providers.dart';
import '../../router/app_router.dart';

/// UC267, UC268: Privacy settings screen.
class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _isLoading = false;

  // TODO: Get from auth provider
  final String _userId = 'user_id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final consentAsync = ref.watch(userConsentProvider(_userId));
    final privacyPolicy = ref.watch(privacyPolicyProvider);
    final termsOfService = ref.watch(termsOfServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade'),
      ),
      body: consentAsync.when(
        data: (consent) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Consent status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Consentimentos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (consent != null) ...[
                        _ConsentRow(
                          label: 'Termos de Uso',
                          accepted: consent.termsAccepted,
                        ),
                        _ConsentRow(
                          label: 'Política de Privacidade',
                          accepted: consent.privacyPolicyAccepted,
                        ),
                        const Divider(height: 24),
                        SwitchListTile(
                          title: const Text('Analytics'),
                          subtitle: const Text('Compartilhar dados de uso anônimos'),
                          value: consent.analyticsConsent,
                          onChanged: _isLoading
                              ? null
                              : (v) => _updateConsent(analyticsConsent: v),
                        ),
                        SwitchListTile(
                          title: const Text('Comunicações'),
                          subtitle: const Text('Receber novidades e ofertas'),
                          value: consent.marketingConsent,
                          onChanged: _isLoading
                              ? null
                              : (v) => _updateConsent(marketingConsent: v),
                        ),
                      ] else ...[
                        Text(
                          'Nenhum consentimento registrado',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Legal documents
              Text(
                'Documentos Legais',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Termos de Uso'),
                subtitle: Text('Versão ${termsOfService.version}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open URL
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Política de Privacidade'),
                subtitle: Text('Versão ${privacyPolicy.version}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Open URL
                },
              ),
              const SizedBox(height: 24),

              // Data management
              Text(
                'Gerenciamento de Dados',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Exportar Meus Dados'),
                subtitle: const Text('Baixe uma cópia de todos os seus dados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacyDataExport),
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                title: Text(
                  'Excluir Minha Conta',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                subtitle: const Text('Remover permanentemente todos os dados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacyDeleteAccount),
              ),
              const SizedBox(height: 24),

              // Security
              Text(
                'Segurança',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Log de Atividades'),
                subtitle: const Text('Veja acessos recentes à sua conta'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.privacySecurityLog),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<void> _updateConsent({
    bool? analyticsConsent,
    bool? marketingConsent,
  }) async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(privacyServiceProvider);
      await updateConsentDirect(
        service,
        _userId,
        analyticsConsent: analyticsConsent,
        marketingConsent: marketingConsent,
      );
      ref.invalidate(userConsentProvider(_userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferências atualizadas')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ConsentRow extends StatelessWidget {
  final String label;
  final bool accepted;

  const _ConsentRow({required this.label, required this.accepted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            accepted ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: accepted ? Colors.green : theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
