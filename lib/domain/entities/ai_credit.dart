import 'package:equatable/equatable.dart';

/// UC187, UC189: Entidade de creditos IA.
///
/// Diferencia creditos temporarios (visitante) vs persistentes (logado).
class AiCredit extends Equatable {
  final String id;
  final String? userId; // null para visitante
  final int amount;
  final AiCreditType type;
  final AiCreditSource source;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final bool isUsed;

  const AiCredit({
    required this.id,
    this.userId,
    required this.amount,
    required this.type,
    required this.source,
    required this.createdAt,
    this.expiresAt,
    this.usedAt,
    this.isUsed = false,
  });

  /// UC189: Credito temporario (visitante)
  bool get isTemporary => type == AiCreditType.temporary;

  /// UC189: Credito persistente (logado)
  bool get isPersistent => type == AiCreditType.persistent;

  /// Verifica se o credito expirou
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Verifica se o credito esta disponivel para uso
  bool get isAvailable => !isUsed && !isExpired;

  AiCredit copyWith({
    String? id,
    String? userId,
    int? amount,
    AiCreditType? type,
    AiCreditSource? source,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
    bool? isUsed,
  }) {
    return AiCredit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        type,
        source,
        createdAt,
        expiresAt,
        usedAt,
        isUsed,
      ];
}

/// UC189: Tipo de credito IA.
enum AiCreditType {
  /// Credito temporario para visitante (uso unico, expira imediatamente)
  temporary,

  /// Credito persistente para usuario logado (acumulavel)
  persistent,

  /// Credito de assinatura premium (renovado mensalmente)
  subscription,
}

/// Fonte de obtencao do credito.
enum AiCreditSource {
  /// Bonus inicial ao criar conta
  welcomeBonus,

  /// Assistiu anuncio recompensado
  rewardedAd,

  /// Compra de pacote avulso
  purchase,

  /// Credito mensal da assinatura
  subscription,

  /// Promocao ou codigo
  promo,
}

/// UC187: Saldo de creditos do usuario.
class AiCreditBalance extends Equatable {
  final String? userId;
  final int available;
  final int usedToday;
  final int usedThisMonth;
  final int totalEarned;
  final int totalUsed;
  final DateTime? lastAdWatched;
  final int adsWatchedToday;

  const AiCreditBalance({
    this.userId,
    this.available = 0,
    this.usedToday = 0,
    this.usedThisMonth = 0,
    this.totalEarned = 0,
    this.totalUsed = 0,
    this.lastAdWatched,
    this.adsWatchedToday = 0,
  });

  /// Verifica se pode assistir mais anuncios hoje
  bool canWatchAd(int dailyLimit) => adsWatchedToday < dailyLimit;

  /// Verifica se esta em cooldown de anuncio
  bool isInAdCooldown(Duration cooldown) {
    if (lastAdWatched == null) return false;
    return DateTime.now().difference(lastAdWatched!) < cooldown;
  }

  /// Tempo restante de cooldown
  Duration? remainingCooldown(Duration cooldown) {
    if (lastAdWatched == null) return null;
    final elapsed = DateTime.now().difference(lastAdWatched!);
    if (elapsed >= cooldown) return null;
    return cooldown - elapsed;
  }

  AiCreditBalance copyWith({
    String? userId,
    int? available,
    int? usedToday,
    int? usedThisMonth,
    int? totalEarned,
    int? totalUsed,
    DateTime? lastAdWatched,
    int? adsWatchedToday,
  }) {
    return AiCreditBalance(
      userId: userId ?? this.userId,
      available: available ?? this.available,
      usedToday: usedToday ?? this.usedToday,
      usedThisMonth: usedThisMonth ?? this.usedThisMonth,
      totalEarned: totalEarned ?? this.totalEarned,
      totalUsed: totalUsed ?? this.totalUsed,
      lastAdWatched: lastAdWatched ?? this.lastAdWatched,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        available,
        usedToday,
        usedThisMonth,
        totalEarned,
        totalUsed,
        lastAdWatched,
        adsWatchedToday,
      ];
}

/// Pacote de creditos para compra.
class AiCreditPackage extends Equatable {
  final String id;
  final String name;
  final int credits;
  final double price;
  final String priceDisplay;
  final String? stripePriceId;
  final bool isPopular;

  const AiCreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.price,
    required this.priceDisplay,
    this.stripePriceId,
    this.isPopular = false,
  });

  /// Preco por credito
  double get pricePerCredit => price / credits;

  @override
  List<Object?> get props => [
        id,
        name,
        credits,
        price,
        priceDisplay,
        stripePriceId,
        isPopular,
      ];
}
