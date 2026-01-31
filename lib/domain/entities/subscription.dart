import 'package:equatable/equatable.dart';

/// UC258-UC266: Subscription and monetization entities.
///
/// Supports:
/// - Plan comparison (UC258)
/// - Premium subscription (UC259)
/// - Auto-renewal (UC260)
/// - Cancellation (UC261)
/// - Free limits (UC262)
/// - Paywall (UC263)
/// - AI credits (UC264-UC265)
/// - Restore purchases (UC266)

/// Subscription plan types.
enum SubscriptionPlan {
  free,
  premiumMonthly,
  premiumAnnual,
}

extension SubscriptionPlanExtension on SubscriptionPlan {
  String get id {
    switch (this) {
      case SubscriptionPlan.free:
        return 'free';
      case SubscriptionPlan.premiumMonthly:
        return 'premium_monthly';
      case SubscriptionPlan.premiumAnnual:
        return 'premium_annual';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Gratuito';
      case SubscriptionPlan.premiumMonthly:
        return 'Premium Mensal';
      case SubscriptionPlan.premiumAnnual:
        return 'Premium Anual';
    }
  }

  String get description {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Recursos básicos para começar';
      case SubscriptionPlan.premiumMonthly:
        return 'Todos os recursos, cobrança mensal';
      case SubscriptionPlan.premiumAnnual:
        return 'Todos os recursos, economize 40%';
    }
  }

  /// Price in BRL (cents).
  int get priceInCents {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.premiumMonthly:
        return 1990; // R$ 19,90
      case SubscriptionPlan.premiumAnnual:
        return 14990; // R$ 149,90 (economiza ~R$ 90)
    }
  }

  String get priceDisplay {
    if (this == SubscriptionPlan.free) return 'Grátis';
    final reais = priceInCents ~/ 100;
    final centavos = priceInCents % 100;
    return 'R\$ $reais,${centavos.toString().padLeft(2, '0')}';
  }

  String get periodDisplay {
    switch (this) {
      case SubscriptionPlan.free:
        return '';
      case SubscriptionPlan.premiumMonthly:
        return '/mês';
      case SubscriptionPlan.premiumAnnual:
        return '/ano';
    }
  }

  bool get isPremium => this != SubscriptionPlan.free;

  /// Billing period in days.
  int get periodDays {
    switch (this) {
      case SubscriptionPlan.free:
        return 0;
      case SubscriptionPlan.premiumMonthly:
        return 30;
      case SubscriptionPlan.premiumAnnual:
        return 365;
    }
  }
}

/// UC258: Plan features for comparison.
class PlanFeatures extends Equatable {
  final SubscriptionPlan plan;
  final int maxDecks;
  final int maxCardsPerDeck;
  final int maxTotalCards;
  final bool unlimitedDecks;
  final bool unlimitedCards;
  final bool aiCardGeneration;
  final int aiCreditsPerMonth;
  final bool audioFeatures;
  final bool pronunciationRecording;
  final bool advancedStats;
  final bool cloudBackup;
  final bool prioritySupport;
  final bool noAds;
  final bool customThemes;

  const PlanFeatures({
    required this.plan,
    this.maxDecks = 5,
    this.maxCardsPerDeck = 100,
    this.maxTotalCards = 500,
    this.unlimitedDecks = false,
    this.unlimitedCards = false,
    this.aiCardGeneration = false,
    this.aiCreditsPerMonth = 0,
    this.audioFeatures = false,
    this.pronunciationRecording = false,
    this.advancedStats = false,
    this.cloudBackup = false,
    this.prioritySupport = false,
    this.noAds = false,
    this.customThemes = false,
  });

  /// Free plan features.
  static const PlanFeatures free = PlanFeatures(
    plan: SubscriptionPlan.free,
    maxDecks: 5,
    maxCardsPerDeck: 100,
    maxTotalCards: 500,
    unlimitedDecks: false,
    unlimitedCards: false,
    aiCardGeneration: false,
    aiCreditsPerMonth: 3,
    audioFeatures: false,
    pronunciationRecording: false,
    advancedStats: false,
    cloudBackup: false,
    prioritySupport: false,
    noAds: false,
    customThemes: false,
  );

  /// Premium features (same for monthly and annual).
  static const PlanFeatures premium = PlanFeatures(
    plan: SubscriptionPlan.premiumMonthly,
    maxDecks: -1,
    maxCardsPerDeck: -1,
    maxTotalCards: -1,
    unlimitedDecks: true,
    unlimitedCards: true,
    aiCardGeneration: true,
    aiCreditsPerMonth: 100,
    audioFeatures: true,
    pronunciationRecording: true,
    advancedStats: true,
    cloudBackup: true,
    prioritySupport: true,
    noAds: true,
    customThemes: true,
  );

  static PlanFeatures forPlan(SubscriptionPlan plan) {
    return plan.isPremium ? premium : free;
  }

  @override
  List<Object?> get props => [
        plan,
        maxDecks,
        maxCardsPerDeck,
        maxTotalCards,
        unlimitedDecks,
        unlimitedCards,
        aiCardGeneration,
        aiCreditsPerMonth,
        audioFeatures,
        pronunciationRecording,
        advancedStats,
        cloudBackup,
        prioritySupport,
        noAds,
        customThemes,
      ];
}

/// UC259-UC261: User subscription status.
class UserSubscription extends Equatable {
  final String id;
  final String oduserId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final bool autoRenew;
  final String? transactionId;
  final String? productId;
  final int aiCreditsRemaining;
  final int aiCreditsPurchased;
  final DateTime? lastCreditRefresh;

  const UserSubscription({
    required this.id,
    required this.oduserId,
    this.plan = SubscriptionPlan.free,
    this.status = SubscriptionStatus.active,
    this.startDate,
    this.endDate,
    this.cancelledAt,
    this.autoRenew = true,
    this.transactionId,
    this.productId,
    this.aiCreditsRemaining = 3,
    this.aiCreditsPurchased = 0,
    this.lastCreditRefresh,
  });

  /// Create free subscription for new user.
  factory UserSubscription.free(String userId) {
    return UserSubscription(
      id: 'sub_free_$userId',
      oduserId: userId,
      plan: SubscriptionPlan.free,
      status: SubscriptionStatus.active,
      aiCreditsRemaining: 3,
    );
  }

  // ============ Computed Properties ============

  bool get isPremium => plan.isPremium && status == SubscriptionStatus.active;

  bool get isActive => status == SubscriptionStatus.active;

  bool get isExpired =>
      endDate != null && DateTime.now().isAfter(endDate!);

  bool get isCancelled => status == SubscriptionStatus.cancelled;

  bool get willRenew => isActive && autoRenew && !isCancelled;

  /// Days remaining in current period.
  int get daysRemaining {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  /// Total AI credits available.
  int get totalAiCredits => aiCreditsRemaining + aiCreditsPurchased;

  /// Get features for current plan.
  PlanFeatures get features => PlanFeatures.forPlan(plan);

  UserSubscription copyWith({
    String? id,
    String? oduserId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? cancelledAt,
    bool? autoRenew,
    String? transactionId,
    String? productId,
    int? aiCreditsRemaining,
    int? aiCreditsPurchased,
    DateTime? lastCreditRefresh,
  }) {
    return UserSubscription(
      id: id ?? this.id,
      oduserId: oduserId ?? this.oduserId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenew: autoRenew ?? this.autoRenew,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      aiCreditsRemaining: aiCreditsRemaining ?? this.aiCreditsRemaining,
      aiCreditsPurchased: aiCreditsPurchased ?? this.aiCreditsPurchased,
      lastCreditRefresh: lastCreditRefresh ?? this.lastCreditRefresh,
    );
  }

  /// Convert to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': oduserId,
      'plan': plan.id,
      'status': status.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'autoRenew': autoRenew,
      'transactionId': transactionId,
      'productId': productId,
      'aiCreditsRemaining': aiCreditsRemaining,
      'aiCreditsPurchased': aiCreditsPurchased,
      'lastCreditRefresh': lastCreditRefresh?.toIso8601String(),
    };
  }

  /// Create from JSON.
  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] as String,
      oduserId: json['userId'] as String,
      plan: SubscriptionPlan.values.firstWhere(
        (p) => p.id == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      status: SubscriptionStatus.values.byName(
        json['status'] as String? ?? 'active',
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      autoRenew: json['autoRenew'] as bool? ?? true,
      transactionId: json['transactionId'] as String?,
      productId: json['productId'] as String?,
      aiCreditsRemaining: json['aiCreditsRemaining'] as int? ?? 3,
      aiCreditsPurchased: json['aiCreditsPurchased'] as int? ?? 0,
      lastCreditRefresh: json['lastCreditRefresh'] != null
          ? DateTime.parse(json['lastCreditRefresh'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        oduserId,
        plan,
        status,
        startDate,
        endDate,
        cancelledAt,
        autoRenew,
        transactionId,
        productId,
        aiCreditsRemaining,
        aiCreditsPurchased,
        lastCreditRefresh,
      ];
}

/// Subscription status.
enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  paused,
  pendingPayment,
}

extension SubscriptionStatusExtension on SubscriptionStatus {
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Ativa';
      case SubscriptionStatus.expired:
        return 'Expirada';
      case SubscriptionStatus.cancelled:
        return 'Cancelada';
      case SubscriptionStatus.paused:
        return 'Pausada';
      case SubscriptionStatus.pendingPayment:
        return 'Aguardando pagamento';
    }
  }
}

/// UC264: AI credit packages.
enum AiCreditPackage {
  small,
  medium,
  large,
}

extension AiCreditPackageExtension on AiCreditPackage {
  String get id {
    switch (this) {
      case AiCreditPackage.small:
        return 'ai_credits_small';
      case AiCreditPackage.medium:
        return 'ai_credits_medium';
      case AiCreditPackage.large:
        return 'ai_credits_large';
    }
  }

  String get displayName {
    switch (this) {
      case AiCreditPackage.small:
        return '50 Créditos';
      case AiCreditPackage.medium:
        return '150 Créditos';
      case AiCreditPackage.large:
        return '500 Créditos';
    }
  }

  int get credits {
    switch (this) {
      case AiCreditPackage.small:
        return 50;
      case AiCreditPackage.medium:
        return 150;
      case AiCreditPackage.large:
        return 500;
    }
  }

  /// Price in BRL (cents).
  int get priceInCents {
    switch (this) {
      case AiCreditPackage.small:
        return 990; // R$ 9,90
      case AiCreditPackage.medium:
        return 2490; // R$ 24,90
      case AiCreditPackage.large:
        return 6990; // R$ 69,90
    }
  }

  String get priceDisplay {
    final reais = priceInCents ~/ 100;
    final centavos = priceInCents % 100;
    return 'R\$ $reais,${centavos.toString().padLeft(2, '0')}';
  }

  /// Price per credit for comparison.
  double get pricePerCredit => priceInCents / credits;
}

/// UC263: Premium feature for paywall.
enum PremiumFeature {
  unlimitedDecks,
  unlimitedCards,
  aiGeneration,
  audioFeatures,
  pronunciation,
  advancedStats,
  cloudBackup,
  customThemes,
}

extension PremiumFeatureExtension on PremiumFeature {
  String get displayName {
    switch (this) {
      case PremiumFeature.unlimitedDecks:
        return 'Decks Ilimitados';
      case PremiumFeature.unlimitedCards:
        return 'Cards Ilimitados';
      case PremiumFeature.aiGeneration:
        return 'Geração de Cards com IA';
      case PremiumFeature.audioFeatures:
        return 'Áudio e TTS';
      case PremiumFeature.pronunciation:
        return 'Gravação de Pronúncia';
      case PremiumFeature.advancedStats:
        return 'Estatísticas Avançadas';
      case PremiumFeature.cloudBackup:
        return 'Backup na Nuvem';
      case PremiumFeature.customThemes:
        return 'Temas Personalizados';
    }
  }

  String get description {
    switch (this) {
      case PremiumFeature.unlimitedDecks:
        return 'Crie quantos decks precisar';
      case PremiumFeature.unlimitedCards:
        return 'Adicione cards sem limites';
      case PremiumFeature.aiGeneration:
        return 'Gere cards automaticamente com IA';
      case PremiumFeature.audioFeatures:
        return 'Ouça pronúncias e adicione áudio';
      case PremiumFeature.pronunciation:
        return 'Grave sua própria pronúncia';
      case PremiumFeature.advancedStats:
        return 'Análises detalhadas do seu progresso';
      case PremiumFeature.cloudBackup:
        return 'Seus dados seguros na nuvem';
      case PremiumFeature.customThemes:
        return 'Personalize a aparência do app';
    }
  }

  String get icon {
    switch (this) {
      case PremiumFeature.unlimitedDecks:
        return '📚';
      case PremiumFeature.unlimitedCards:
        return '📝';
      case PremiumFeature.aiGeneration:
        return '🤖';
      case PremiumFeature.audioFeatures:
        return '🔊';
      case PremiumFeature.pronunciation:
        return '🎤';
      case PremiumFeature.advancedStats:
        return '📊';
      case PremiumFeature.cloudBackup:
        return '☁️';
      case PremiumFeature.customThemes:
        return '🎨';
    }
  }
}
