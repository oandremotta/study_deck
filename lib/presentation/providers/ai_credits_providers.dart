import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/ai_credits_service.dart';
import '../../domain/entities/ai_credit.dart';
import 'auth_providers.dart';

/// Provider do servico de creditos IA.
final aiCreditsServiceProvider = Provider<AiCreditsService>((ref) {
  return AiCreditsService();
});

/// UC184: Saldo de creditos do usuario logado.
///
/// Retorna null se usuario nao esta logado (visitante nao ve saldo).
final aiCreditBalanceProvider = FutureProvider<AiCreditBalance?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final service = ref.watch(aiCreditsServiceProvider);
  return await service.getBalance(user.id);
});

/// UC183: Verifica se visitante tem credito temporario.
final hasTemporaryCreditProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user != null) return false; // Nao se aplica a usuarios logados

  final service = ref.watch(aiCreditsServiceProvider);
  return await service.hasTemporaryCredit();
});

/// UC183, UC194: Verifica se pode assistir anuncio.
final canWatchAdProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(aiCreditsServiceProvider);

  if (user == null) {
    // Visitante
    return await service.canVisitorWatchAd();
  } else {
    // Usuario logado
    return await service.canUserWatchAd(user.id);
  }
});

/// UC195: Mensagem contextual baseada no estado do usuario.
final aiCreditsMessageProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(aiCreditsServiceProvider);
  final isPremium = ref.watch(isPremiumUserProvider);

  if (isPremium) {
    return service.getPremiumMessage();
  }

  if (user == null) {
    return service.getVisitorMessage();
  }

  final balance = ref.watch(aiCreditBalanceProvider).valueOrNull;
  if (balance != null) {
    return service.getLoggedUserMessage(balance);
  }

  return 'Carregando...';
});

/// Verifica se usuario e premium (placeholder - integrar com RevenueCat).
final isPremiumUserProvider = Provider<bool>((ref) {
  // TODO: Integrar com RevenueCat/Stripe
  return false;
});

/// UC183: Verifica se pode usar IA.
///
/// Visitante: precisa de credito temporario
/// Logado Free: precisa de creditos
/// Premium: sempre pode
final canUseAiProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);
  final isPremium = ref.watch(isPremiumUserProvider);
  final service = ref.watch(aiCreditsServiceProvider);

  // Premium sempre pode
  if (isPremium) return true;

  if (user == null) {
    // Visitante - verifica credito temporario
    return await service.hasTemporaryCredit();
  } else {
    // Usuario logado - verifica saldo
    final balance = await service.getBalance(user.id);
    return balance.available > 0;
  }
});

/// Pacotes de creditos disponiveis para compra.
final creditPackagesProvider = Provider<List<AiCreditPackage>>((ref) {
  return AiCreditsService.creditPackages;
});

/// Estado do fluxo de uso de IA.
enum AiUsageState {
  /// Premium - IA sempre liberada
  premium,

  /// Tem creditos disponiveis
  hasCredits,

  /// Sem creditos - precisa assistir anuncio ou comprar
  noCredits,

  /// Visitante sem credito temporario
  visitorNoCredit,

  /// Visitante com credito temporario
  visitorHasCredit,
}

/// UC183-UC195: Estado atual do fluxo de IA.
final aiUsageStateProvider = FutureProvider<AiUsageState>((ref) async {
  final user = ref.watch(currentUserProvider);
  final isPremium = ref.watch(isPremiumUserProvider);
  final service = ref.watch(aiCreditsServiceProvider);

  // Premium
  if (isPremium) return AiUsageState.premium;

  // Visitante
  if (user == null) {
    final hasTemp = await service.hasTemporaryCredit();
    return hasTemp ? AiUsageState.visitorHasCredit : AiUsageState.visitorNoCredit;
  }

  // Usuario logado
  final balance = await service.getBalance(user.id);
  return balance.available > 0 ? AiUsageState.hasCredits : AiUsageState.noCredits;
});

// ============ Acoes ============

/// UC183: Concede credito temporario para visitante apos anuncio.
Future<void> grantTemporaryCreditAfterAd(WidgetRef ref) async {
  final service = ref.read(aiCreditsServiceProvider);
  await service.grantTemporaryCredit();
  ref.invalidate(hasTemporaryCreditProvider);
  ref.invalidate(canUseAiProvider);
  ref.invalidate(aiUsageStateProvider);
}

/// UC183: Consome credito temporario de visitante.
Future<bool> consumeTemporaryCredit(WidgetRef ref) async {
  final service = ref.read(aiCreditsServiceProvider);
  final consumed = await service.consumeTemporaryCredit();
  if (consumed) {
    ref.invalidate(hasTemporaryCreditProvider);
    ref.invalidate(canUseAiProvider);
    ref.invalidate(aiUsageStateProvider);
  }
  return consumed;
}

/// UC188: Adiciona credito para usuario logado apos anuncio.
Future<AiCreditBalance> addCreditFromAd(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) throw Exception('Usuario nao logado');

  final service = ref.read(aiCreditsServiceProvider);
  final balance = await service.addCreditFromAd(user.id);
  ref.invalidate(aiCreditBalanceProvider);
  ref.invalidate(canUseAiProvider);
  ref.invalidate(aiUsageStateProvider);
  ref.invalidate(canWatchAdProvider);
  return balance;
}

/// Consome credito do usuario logado.
Future<bool> consumeUserCredit(WidgetRef ref) async {
  final user = ref.read(currentUserProvider);
  if (user == null) throw Exception('Usuario nao logado');

  final service = ref.read(aiCreditsServiceProvider);
  final consumed = await service.consumeCredit(user.id);
  if (consumed) {
    ref.invalidate(aiCreditBalanceProvider);
    ref.invalidate(canUseAiProvider);
    ref.invalidate(aiUsageStateProvider);
  }
  return consumed;
}

/// Adiciona creditos de compra.
Future<AiCreditBalance> addCreditsFromPurchase(
    WidgetRef ref, int credits) async {
  final user = ref.read(currentUserProvider);
  if (user == null) throw Exception('Usuario nao logado');

  final service = ref.read(aiCreditsServiceProvider);
  final balance = await service.addCreditsFromPurchase(user.id, credits);
  ref.invalidate(aiCreditBalanceProvider);
  ref.invalidate(canUseAiProvider);
  ref.invalidate(aiUsageStateProvider);
  return balance;
}

/// UC187: Inicializa usuario com ou sem bonus.
Future<void> initializeUserCredits(WidgetRef ref,
    {bool withWelcomeBonus = false}) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return;

  final service = ref.read(aiCreditsServiceProvider);
  await service.initializeUser(user.id, withWelcomeBonus: withWelcomeBonus);
  ref.invalidate(aiCreditBalanceProvider);
}
