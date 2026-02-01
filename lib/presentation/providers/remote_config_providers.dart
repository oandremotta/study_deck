import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/remote_config_service.dart';

/// Provider do servico de Remote Config.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Provider de inicializacao do Remote Config.
final remoteConfigInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(remoteConfigServiceProvider);
  await service.initialize();
});

// ============ Feature Flags Providers ============

/// UC212: IA habilitada?
final isAiEnabledProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isAiEnabled;
});

/// UC212: Anuncios habilitados?
final areAdsEnabledProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.areAdsEnabled;
});

/// UC212: Premium habilitado?
final isPremiumEnabledProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isPremiumEnabled;
});

/// UC212: Comunidade habilitada?
final isCommunityEnabledProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isCommunityEnabled;
});

/// UC212: Modo educador habilitado?
final isEducatorModeEnabledProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isEducatorModeEnabled;
});

// ============ Configuracoes Providers ============

/// Limite diario de anuncios.
final dailyAdLimitProvider = Provider<int>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.dailyAdLimit;
});

/// UC214: Limite para alerta de saldo baixo.
final lowBalanceThresholdProvider = Provider<int>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.lowBalanceThreshold;
});

/// Bonus de boas-vindas.
final welcomeBonusCreditsProvider = Provider<int>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.welcomeBonusCredits;
});

// ============ A/B Testing Providers ============

/// Variante do paywall (control, variant_a, variant_b).
final paywallVariantProvider = Provider<String>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.paywallVariant;
});

/// Variante do onboarding.
final onboardingVariantProvider = Provider<String>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.onboardingVariant;
});

// ============ Mensagens Providers ============

/// Mensagem de manutencao.
final maintenanceMessageProvider = Provider<String>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.maintenanceMessage;
});

/// Verifica se esta em manutencao.
final isInMaintenanceProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.isInMaintenance;
});

/// Mensagem promocional.
final promoMessageProvider = Provider<String>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.promoMessage;
});

/// Verifica se tem promocao ativa.
final hasActivePromoProvider = Provider<bool>((ref) {
  ref.watch(remoteConfigInitProvider);
  final service = ref.watch(remoteConfigServiceProvider);
  return service.hasActivePromo;
});
