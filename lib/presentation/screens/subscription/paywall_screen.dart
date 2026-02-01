import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/services/revenuecat_service.dart';
import '../../../data/services/stripe_web_service.dart';
import '../../../domain/entities/subscription.dart';
import '../../providers/revenuecat_providers.dart';
import '../../providers/auth_providers.dart';

/// UC259, UC263: Paywall/subscription screen.
///
/// Uses RevenueCat for real purchases on mobile.
/// Falls back to mock implementation on web.
class PaywallScreen extends ConsumerStatefulWidget {
  final PremiumFeature? feature;

  const PaywallScreen({super.key, this.feature});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _selectedPackage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // On web, use legacy implementation
    if (kIsWeb) {
      return _buildWebPaywall(context, theme);
    }

    // On mobile, use RevenueCat
    final packagesAsync = ref.watch(availablePackagesProvider);
    final packages = packagesAsync;

    // Select first package by default (usually annual)
    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Premium icon
                    _buildPremiumIcon(theme),
                    const SizedBox(height: 24),

                    // Title
                    _buildTitle(theme),
                    const SizedBox(height: 32),

                    // Features list
                    ...PremiumFeature.values.map(
                      (f) => _FeatureRow(feature: f),
                    ),
                    const SizedBox(height: 32),

                    // Package selection
                    if (packages.isEmpty)
                      _buildLoadingPackages(theme)
                    else
                      ...packages.map((package) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PackageOption(
                              package: package,
                              isSelected: _selectedPackage == package,
                              onTap: () => setState(() {
                                _selectedPackage = package;
                              }),
                            ),
                          )),
                  ],
                ),
              ),
            ),

            // Subscribe button
            _buildSubscribeButton(theme, packages.isNotEmpty),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumIcon(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.workspace_premium,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          widget.feature != null
              ? 'Desbloqueie ${widget.feature!.displayName}'
              : 'Study Deck Premium',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.feature != null
              ? widget.feature!.description
              : 'Estude sem limites com todos os recursos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingPackages(ThemeData theme) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando planos...'),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(ThemeData theme, bool hasPackages) {
    final buttonText = _selectedPackage != null
        ? 'Assinar ${_selectedPackage!.formattedPrice}'
        : 'Selecione um plano';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: (_isLoading || !hasPackages || _selectedPackage == null)
                  ? null
                  : _subscribe,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      buttonText,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cancele a qualquer momento',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // TODO: Show terms
                },
                child: const Text('Termos de Uso'),
              ),
              const Text(' | '),
              TextButton(
                onPressed: () {
                  // TODO: Show privacy
                },
                child: const Text('Privacidade'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await purchasePackageDirect(service, _selectedPackage!);

      if (customerInfo != null && customerInfo.isPremium) {
        // Refresh providers
        refreshCustomerInfo(ref);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assinatura ativada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true);
        }
      } else {
        // User cancelled
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Web fallback using local subscription service
  Widget _buildWebPaywall(BuildContext context, ThemeData theme) {
    return _WebPaywallContent(
      feature: widget.feature,
      onClose: () => context.pop(),
    );
  }
}

/// Web paywall using Stripe Checkout.
class _WebPaywallContent extends ConsumerStatefulWidget {
  final PremiumFeature? feature;
  final VoidCallback onClose;

  const _WebPaywallContent({
    required this.feature,
    required this.onClose,
  });

  @override
  ConsumerState<_WebPaywallContent> createState() => _WebPaywallContentState();
}

class _WebPaywallContentState extends ConsumerState<_WebPaywallContent> {
  StripePlan? _selectedPlan;
  bool _isLoading = false;
  final _stripeService = StripeWebService();

  @override
  void initState() {
    super.initState();
    // Select annual plan by default
    _selectedPlan = StripeWebService.plans['annual'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // Se não está logado, mostrar tela de login obrigatório
    if (user == null) {
      return _buildLoginRequiredScreen(context, theme);
    }

    // Usuário logado - mostrar planos
    final plans = _stripeService.getPlans();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.feature != null
                          ? 'Desbloqueie ${widget.feature!.displayName}'
                          : 'Study Deck Premium',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estude sem limites com todos os recursos',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ...PremiumFeature.values.map(
                      (f) => _FeatureRow(feature: f),
                    ),
                    const SizedBox(height: 32),
                    // Stripe plans
                    ...plans.map((plan) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StripePlanOption(
                            plan: plan,
                            isSelected: _selectedPlan?.id == plan.id,
                            onTap: () => setState(() {
                              _selectedPlan = plan;
                            }),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: (_selectedPlan == null || _isLoading)
                          ? null
                          : _subscribeStripe,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _selectedPlan != null
                                  ? 'Assinar ${_selectedPlan!.priceDisplay}'
                                  : 'Selecione um plano',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pagamento seguro via Stripe',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'SSL Seguro',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tela para usuário não logado - planos ocultos
  Widget _buildLoginRequiredScreen(BuildContext context, ThemeData theme) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Crie uma conta para ver os planos',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Entre ou crie uma conta para desbloquear todos os recursos premium e acompanhar seus creditos.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () {
                            widget.onClose();
                            context.push('/login');
                          },
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'Entrar ou Criar Conta',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Enquanto isso, voce pode gerar cards com IA assistindo anuncios!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribeStripe() async {
    if (_selectedPlan == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faca login para assinar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if Stripe Price ID is configured
    if (_selectedPlan!.priceId.isEmpty) {
      _showConfigurationPendingDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final checkoutUrl = await _stripeService.createCheckoutSession(
        priceId: _selectedPlan!.priceId,
        userId: user.id,
        userEmail: user.email,
      );

      if (checkoutUrl != null) {
        // Open Stripe Checkout in browser
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao criar sessao de pagamento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showConfigurationPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuracao Pendente'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Os produtos do Stripe ainda nao foram configurados. '
              'Entre em contato com o suporte.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Stripe plan option widget.
class _StripePlanOption extends StatelessWidget {
  final StripePlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _StripePlanOption({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected ? true : null,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (plan.isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'MELHOR VALOR',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (plan.isLifetime) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PARA SEMPRE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    plan.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              plan.priceDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final PremiumFeature feature;

  const _FeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                feature.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  feature.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Package option for RevenueCat packages.
class _PackageOption extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageOption({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnnual = package.isAnnual;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected ? true : null,
              onChanged: (_) => onTap(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        package.title.isNotEmpty
                            ? package.title
                            : (isAnnual ? 'Anual' : 'Mensal'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'RECOMENDADO',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    package.description.isNotEmpty
                        ? package.description
                        : (isAnnual
                            ? 'Economia de mais de 40%'
                            : 'Cobranca mensal'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              package.formattedPrice,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

