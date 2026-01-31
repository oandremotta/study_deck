import 'package:equatable/equatable.dart';

/// UC267-UC273: Privacy and LGPD compliance entities.
///
/// Supports:
/// - Consent management (UC267)
/// - Privacy policy (UC268)
/// - Data export (UC269)
/// - Account deletion (UC270)
/// - Analytics anonymization (UC271)
/// - Secure authentication (UC272)
/// - Suspicious activity blocking (UC273)

/// UC267: User consent record.
class UserConsent extends Equatable {
  final String userId;
  final bool termsAccepted;
  final bool privacyPolicyAccepted;
  final bool analyticsConsent;
  final bool marketingConsent;
  final DateTime? termsAcceptedAt;
  final DateTime? privacyAcceptedAt;
  final DateTime? analyticsConsentAt;
  final DateTime? marketingConsentAt;
  final String? termsVersion;
  final String? privacyVersion;
  final String? ipAddress;
  final String? userAgent;

  const UserConsent({
    required this.userId,
    this.termsAccepted = false,
    this.privacyPolicyAccepted = false,
    this.analyticsConsent = false,
    this.marketingConsent = false,
    this.termsAcceptedAt,
    this.privacyAcceptedAt,
    this.analyticsConsentAt,
    this.marketingConsentAt,
    this.termsVersion,
    this.privacyVersion,
    this.ipAddress,
    this.userAgent,
  });

  /// Check if all required consents are given.
  bool get hasRequiredConsents => termsAccepted && privacyPolicyAccepted;

  /// Check if consent needs update (new version).
  bool needsUpdate(String currentTermsVersion, String currentPrivacyVersion) {
    return termsVersion != currentTermsVersion ||
        privacyVersion != currentPrivacyVersion;
  }

  UserConsent copyWith({
    String? userId,
    bool? termsAccepted,
    bool? privacyPolicyAccepted,
    bool? analyticsConsent,
    bool? marketingConsent,
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
    DateTime? analyticsConsentAt,
    DateTime? marketingConsentAt,
    String? termsVersion,
    String? privacyVersion,
    String? ipAddress,
    String? userAgent,
  }) {
    return UserConsent(
      userId: userId ?? this.userId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      privacyPolicyAccepted: privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      privacyAcceptedAt: privacyAcceptedAt ?? this.privacyAcceptedAt,
      analyticsConsentAt: analyticsConsentAt ?? this.analyticsConsentAt,
      marketingConsentAt: marketingConsentAt ?? this.marketingConsentAt,
      termsVersion: termsVersion ?? this.termsVersion,
      privacyVersion: privacyVersion ?? this.privacyVersion,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'termsAccepted': termsAccepted,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'analyticsConsent': analyticsConsent,
      'marketingConsent': marketingConsent,
      'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
      'privacyAcceptedAt': privacyAcceptedAt?.toIso8601String(),
      'analyticsConsentAt': analyticsConsentAt?.toIso8601String(),
      'marketingConsentAt': marketingConsentAt?.toIso8601String(),
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  factory UserConsent.fromJson(Map<String, dynamic> json) {
    return UserConsent(
      userId: json['userId'] as String,
      termsAccepted: json['termsAccepted'] as bool? ?? false,
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool? ?? false,
      analyticsConsent: json['analyticsConsent'] as bool? ?? false,
      marketingConsent: json['marketingConsent'] as bool? ?? false,
      termsAcceptedAt: json['termsAcceptedAt'] != null
          ? DateTime.parse(json['termsAcceptedAt'] as String)
          : null,
      privacyAcceptedAt: json['privacyAcceptedAt'] != null
          ? DateTime.parse(json['privacyAcceptedAt'] as String)
          : null,
      analyticsConsentAt: json['analyticsConsentAt'] != null
          ? DateTime.parse(json['analyticsConsentAt'] as String)
          : null,
      marketingConsentAt: json['marketingConsentAt'] != null
          ? DateTime.parse(json['marketingConsentAt'] as String)
          : null,
      termsVersion: json['termsVersion'] as String?,
      privacyVersion: json['privacyVersion'] as String?,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        termsAccepted,
        privacyPolicyAccepted,
        analyticsConsent,
        marketingConsent,
        termsAcceptedAt,
        privacyAcceptedAt,
        analyticsConsentAt,
        marketingConsentAt,
        termsVersion,
        privacyVersion,
      ];
}

/// UC269: Data export request.
class DataExportRequest extends Equatable {
  final String id;
  final String oduserId;
  final DataExportStatus status;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String? downloadUrl;
  final DateTime? expiresAt;
  final List<DataExportType> includedData;

  const DataExportRequest({
    required this.id,
    required this.oduserId,
    this.status = DataExportStatus.pending,
    required this.requestedAt,
    this.completedAt,
    this.downloadUrl,
    this.expiresAt,
    this.includedData = const [],
  });

  bool get isReady => status == DataExportStatus.ready && downloadUrl != null;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
        id,
        oduserId,
        status,
        requestedAt,
        completedAt,
        downloadUrl,
        expiresAt,
        includedData,
      ];
}

enum DataExportStatus {
  pending,
  processing,
  ready,
  expired,
  failed,
}

extension DataExportStatusExtension on DataExportStatus {
  String get displayName {
    switch (this) {
      case DataExportStatus.pending:
        return 'Aguardando';
      case DataExportStatus.processing:
        return 'Processando';
      case DataExportStatus.ready:
        return 'Pronto para download';
      case DataExportStatus.expired:
        return 'Expirado';
      case DataExportStatus.failed:
        return 'Falhou';
    }
  }
}

enum DataExportType {
  profile,
  decks,
  cards,
  studyProgress,
  statistics,
  settings,
}

extension DataExportTypeExtension on DataExportType {
  String get displayName {
    switch (this) {
      case DataExportType.profile:
        return 'Perfil';
      case DataExportType.decks:
        return 'Decks';
      case DataExportType.cards:
        return 'Cards';
      case DataExportType.studyProgress:
        return 'Progresso de estudo';
      case DataExportType.statistics:
        return 'Estatísticas';
      case DataExportType.settings:
        return 'Configurações';
    }
  }
}

/// UC270: Account deletion request.
class AccountDeletionRequest extends Equatable {
  final String id;
  final String oduserId;
  final DeletionStatus status;
  final DateTime requestedAt;
  final DateTime scheduledAt;
  final DateTime? executedAt;
  final String? reason;
  final bool confirmed;

  const AccountDeletionRequest({
    required this.id,
    required this.oduserId,
    this.status = DeletionStatus.pending,
    required this.requestedAt,
    required this.scheduledAt,
    this.executedAt,
    this.reason,
    this.confirmed = false,
  });

  /// Days until deletion.
  int get daysUntilDeletion {
    return scheduledAt.difference(DateTime.now()).inDays;
  }

  /// Can be cancelled if not yet executed.
  bool get canCancel => status == DeletionStatus.pending;

  @override
  List<Object?> get props => [
        id,
        oduserId,
        status,
        requestedAt,
        scheduledAt,
        executedAt,
        reason,
        confirmed,
      ];
}

enum DeletionStatus {
  pending,
  confirmed,
  executing,
  completed,
  cancelled,
}

extension DeletionStatusExtension on DeletionStatus {
  String get displayName {
    switch (this) {
      case DeletionStatus.pending:
        return 'Aguardando confirmação';
      case DeletionStatus.confirmed:
        return 'Agendada';
      case DeletionStatus.executing:
        return 'Em execução';
      case DeletionStatus.completed:
        return 'Concluída';
      case DeletionStatus.cancelled:
        return 'Cancelada';
    }
  }
}

/// UC273: Security event for suspicious activity.
class SecurityEvent extends Equatable {
  final String id;
  final String? userId;
  final SecurityEventType type;
  final DateTime occurredAt;
  final String? ipAddress;
  final String? userAgent;
  final String? location;
  final Map<String, dynamic>? metadata;
  final bool blocked;

  const SecurityEvent({
    required this.id,
    this.userId,
    required this.type,
    required this.occurredAt,
    this.ipAddress,
    this.userAgent,
    this.location,
    this.metadata,
    this.blocked = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        occurredAt,
        ipAddress,
        userAgent,
        location,
        blocked,
      ];
}

enum SecurityEventType {
  loginSuccess,
  loginFailed,
  loginBlocked,
  passwordChanged,
  passwordResetRequested,
  accountLocked,
  accountUnlocked,
  suspiciousActivity,
  newDevice,
  newLocation,
}

extension SecurityEventTypeExtension on SecurityEventType {
  String get displayName {
    switch (this) {
      case SecurityEventType.loginSuccess:
        return 'Login bem-sucedido';
      case SecurityEventType.loginFailed:
        return 'Tentativa de login falhou';
      case SecurityEventType.loginBlocked:
        return 'Login bloqueado';
      case SecurityEventType.passwordChanged:
        return 'Senha alterada';
      case SecurityEventType.passwordResetRequested:
        return 'Redefinição de senha solicitada';
      case SecurityEventType.accountLocked:
        return 'Conta bloqueada';
      case SecurityEventType.accountUnlocked:
        return 'Conta desbloqueada';
      case SecurityEventType.suspiciousActivity:
        return 'Atividade suspeita detectada';
      case SecurityEventType.newDevice:
        return 'Novo dispositivo';
      case SecurityEventType.newLocation:
        return 'Nova localização';
    }
  }

  bool get isWarning {
    switch (this) {
      case SecurityEventType.loginFailed:
      case SecurityEventType.loginBlocked:
      case SecurityEventType.accountLocked:
      case SecurityEventType.suspiciousActivity:
        return true;
      default:
        return false;
    }
  }
}

/// Privacy policy info.
class PrivacyPolicyInfo {
  final String version;
  final DateTime? lastUpdated;
  final String url;
  final String summary;

  const PrivacyPolicyInfo({
    required this.version,
    this.lastUpdated,
    required this.url,
    required this.summary,
  });

  static const PrivacyPolicyInfo current = PrivacyPolicyInfo(
    version: '1.0.0',
    url: 'https://studydeck.app/privacy',
    summary: 'Coletamos apenas os dados necessários para o funcionamento do app. '
        'Seus dados são armazenados de forma segura e nunca compartilhados sem seu consentimento.',
  );
}

/// Terms of service info.
class TermsOfServiceInfo {
  final String version;
  final DateTime? lastUpdated;
  final String url;
  final String summary;

  const TermsOfServiceInfo({
    required this.version,
    this.lastUpdated,
    required this.url,
    required this.summary,
  });

  static const TermsOfServiceInfo current = TermsOfServiceInfo(
    version: '1.0.0',
    url: 'https://studydeck.app/terms',
    summary: 'Ao usar o Study Deck, você concorda em usar o app de forma responsável '
        'e respeitar os direitos de outros usuários.',
  );
}
