import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/privacy_service.dart';
import '../../domain/entities/privacy_settings.dart';

// ============ Service Provider ============

/// Provider for privacy service.
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  return PrivacyService();
});

// ============ Consent Providers ============

/// Provider for user consent.
final userConsentProvider =
    FutureProvider.family<UserConsent?, String>((ref, userId) async {
  final service = ref.watch(privacyServiceProvider);
  return service.getConsent(userId);
});

/// Provider to check if consent is required.
final consentRequiredProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final service = ref.watch(privacyServiceProvider);
  return service.isConsentRequired(userId);
});

/// Provider for privacy policy info.
final privacyPolicyProvider = Provider<PrivacyPolicyInfo>((ref) {
  final service = ref.watch(privacyServiceProvider);
  return service.getPrivacyPolicy();
});

/// Provider for terms of service info.
final termsOfServiceProvider = Provider<TermsOfServiceInfo>((ref) {
  final service = ref.watch(privacyServiceProvider);
  return service.getTermsOfService();
});

// ============ Direct Functions ============

/// UC267: Record consent.
Future<UserConsent> recordConsentDirect(
  PrivacyService service,
  String userId, {
  required bool termsAccepted,
  required bool privacyAccepted,
  bool analyticsConsent = false,
  bool marketingConsent = false,
  String? ipAddress,
  String? userAgent,
}) async {
  return service.recordConsent(
    userId,
    termsAccepted: termsAccepted,
    privacyAccepted: privacyAccepted,
    analyticsConsent: analyticsConsent,
    marketingConsent: marketingConsent,
    ipAddress: ipAddress,
    userAgent: userAgent,
  );
}

/// UC267: Update consent.
Future<UserConsent> updateConsentDirect(
  PrivacyService service,
  String userId, {
  bool? analyticsConsent,
  bool? marketingConsent,
}) async {
  return service.updateConsent(
    userId,
    analyticsConsent: analyticsConsent,
    marketingConsent: marketingConsent,
  );
}

/// UC269: Request data export.
Future<DataExportRequest> requestDataExportDirect(
  PrivacyService service,
  String userId, {
  List<DataExportType> includedData = const [],
}) async {
  return service.requestDataExport(userId, includedData: includedData);
}

/// UC269: Get export request status.
Future<DataExportRequest?> getExportRequestDirect(
  PrivacyService service,
  String requestId,
) async {
  return service.getExportRequest(requestId);
}

/// UC270: Request account deletion.
Future<AccountDeletionRequest> requestAccountDeletionDirect(
  PrivacyService service,
  String userId, {
  String? reason,
}) async {
  return service.requestAccountDeletion(userId, reason: reason);
}

/// UC270: Confirm deletion.
Future<AccountDeletionRequest> confirmDeletionDirect(
  PrivacyService service,
  String requestId,
) async {
  return service.confirmDeletion(requestId);
}

/// UC270: Cancel deletion.
Future<AccountDeletionRequest> cancelDeletionDirect(
  PrivacyService service,
  String requestId,
) async {
  return service.cancelDeletion(requestId);
}

/// UC271: Generate anonymous ID.
String generateAnonymousIdDirect(
  PrivacyService service,
  String userId,
) {
  return service.generateAnonymousId(userId);
}

/// UC271: Anonymize event.
Map<String, dynamic> anonymizeEventDirect(
  PrivacyService service,
  Map<String, dynamic> event,
) {
  return service.anonymizeEvent(event);
}

/// UC272-UC273: Record login attempt.
Future<LoginAttemptResult> recordLoginAttemptDirect(
  PrivacyService service,
  String identifier, {
  required bool success,
  String? ipAddress,
}) async {
  return service.recordLoginAttempt(
    identifier,
    success: success,
    ipAddress: ipAddress,
  );
}

/// UC273: Check if locked out.
Future<bool> isLockedOutDirect(
  PrivacyService service,
  String identifier,
) async {
  return service.isLockedOut(identifier);
}

/// UC273: Get security events.
Future<List<SecurityEvent>> getSecurityEventsDirect(
  PrivacyService service,
  String userId, {
  int limit = 20,
}) async {
  return service.getSecurityEvents(userId, limit: limit);
}
