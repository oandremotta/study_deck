import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/privacy_settings.dart';

/// UC267-UC273: Privacy and LGPD service.
///
/// Handles:
/// - Consent management (UC267)
/// - Privacy policy access (UC268)
/// - Data export (UC269)
/// - Account deletion (UC270)
/// - Analytics anonymization (UC271)
/// - Authentication security (UC272)
/// - Suspicious activity detection (UC273)
class PrivacyService {
  static const String _consentKey = 'user_consent';
  static const String _securityEventsKey = 'security_events';
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _exportRequestsKey = 'export_requests';
  static const String _deletionRequestsKey = 'deletion_requests';

  static const int maxLoginAttempts = 5;
  static const int lockoutMinutes = 15;
  static const int deletionGracePeriodDays = 30;

  final _uuid = const Uuid();
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ============ UC267: Consent Management ============

  /// Get user consent record.
  Future<UserConsent?> getConsent(String userId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_consentKey}_$userId');

      if (json == null) return null;

      return UserConsent.fromJson(jsonDecode(json));
    } catch (e) {
      debugPrint('PrivacyService: Error getting consent: $e');
      return null;
    }
  }

  /// Record user consent.
  Future<UserConsent> recordConsent(
    String userId, {
    required bool termsAccepted,
    required bool privacyAccepted,
    bool analyticsConsent = false,
    bool marketingConsent = false,
    String? ipAddress,
    String? userAgent,
  }) async {
    final now = DateTime.now();
    final consent = UserConsent(
      userId: userId,
      termsAccepted: termsAccepted,
      privacyPolicyAccepted: privacyAccepted,
      analyticsConsent: analyticsConsent,
      marketingConsent: marketingConsent,
      termsAcceptedAt: termsAccepted ? now : null,
      privacyAcceptedAt: privacyAccepted ? now : null,
      analyticsConsentAt: analyticsConsent ? now : null,
      marketingConsentAt: marketingConsent ? now : null,
      termsVersion: TermsOfServiceInfo.current.version,
      privacyVersion: PrivacyPolicyInfo.current.version,
      ipAddress: ipAddress,
      userAgent: userAgent,
    );

    await _saveConsent(consent);
    debugPrint('PrivacyService: Consent recorded for $userId');
    return consent;
  }

  /// Update specific consent.
  Future<UserConsent> updateConsent(
    String userId, {
    bool? analyticsConsent,
    bool? marketingConsent,
  }) async {
    var consent = await getConsent(userId);
    consent ??= UserConsent(userId: userId);

    final now = DateTime.now();
    consent = consent.copyWith(
      analyticsConsent: analyticsConsent ?? consent.analyticsConsent,
      marketingConsent: marketingConsent ?? consent.marketingConsent,
      analyticsConsentAt:
          analyticsConsent == true ? now : consent.analyticsConsentAt,
      marketingConsentAt:
          marketingConsent == true ? now : consent.marketingConsentAt,
    );

    await _saveConsent(consent);
    return consent;
  }

  /// Check if consent is required.
  Future<bool> isConsentRequired(String userId) async {
    final consent = await getConsent(userId);
    if (consent == null) return true;

    return !consent.hasRequiredConsents ||
        consent.needsUpdate(
          TermsOfServiceInfo.current.version,
          PrivacyPolicyInfo.current.version,
        );
  }

  // ============ UC268: Privacy Policy ============

  /// Get privacy policy info.
  PrivacyPolicyInfo getPrivacyPolicy() {
    return PrivacyPolicyInfo.current;
  }

  /// Get terms of service info.
  TermsOfServiceInfo getTermsOfService() {
    return TermsOfServiceInfo.current;
  }

  // ============ UC269: Data Export ============

  /// Request data export.
  Future<DataExportRequest> requestDataExport(
    String userId, {
    List<DataExportType> includedData = const [],
  }) async {
    final request = DataExportRequest(
      id: _uuid.v4(),
      oduserId: userId,
      status: DataExportStatus.pending,
      requestedAt: DateTime.now(),
      includedData: includedData.isEmpty
          ? DataExportType.values
          : includedData,
    );

    await _saveExportRequest(request);
    debugPrint('PrivacyService: Data export requested for $userId');
    return request;
  }

  /// Get export request status.
  Future<DataExportRequest?> getExportRequest(String requestId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_exportRequestsKey}_$requestId');

      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return DataExportRequest(
        id: data['id'] as String,
        oduserId: data['userId'] as String,
        status: DataExportStatus.values.byName(data['status'] as String),
        requestedAt: DateTime.parse(data['requestedAt'] as String),
        completedAt: data['completedAt'] != null
            ? DateTime.parse(data['completedAt'] as String)
            : null,
        downloadUrl: data['downloadUrl'] as String?,
        expiresAt: data['expiresAt'] != null
            ? DateTime.parse(data['expiresAt'] as String)
            : null,
        includedData: (data['includedData'] as List<dynamic>?)
                ?.map((e) => DataExportType.values.byName(e as String))
                .toList() ??
            [],
      );
    } catch (e) {
      debugPrint('PrivacyService: Error getting export request: $e');
      return null;
    }
  }

  /// Simulate export completion (in real app, this would be server-side).
  Future<DataExportRequest> completeExport(
    String requestId,
    String downloadUrl,
  ) async {
    final request = await getExportRequest(requestId);
    if (request == null) {
      throw Exception('Export request not found');
    }

    final now = DateTime.now();
    final completed = DataExportRequest(
      id: request.id,
      oduserId: request.oduserId,
      status: DataExportStatus.ready,
      requestedAt: request.requestedAt,
      completedAt: now,
      downloadUrl: downloadUrl,
      expiresAt: now.add(const Duration(days: 7)),
      includedData: request.includedData,
    );

    await _saveExportRequest(completed);
    return completed;
  }

  // ============ UC270: Account Deletion ============

  /// Request account deletion.
  Future<AccountDeletionRequest> requestAccountDeletion(
    String userId, {
    String? reason,
  }) async {
    final now = DateTime.now();
    final request = AccountDeletionRequest(
      id: _uuid.v4(),
      oduserId: userId,
      status: DeletionStatus.pending,
      requestedAt: now,
      scheduledAt: now.add(const Duration(days: deletionGracePeriodDays)),
      reason: reason,
    );

    await _saveDeletionRequest(request);
    debugPrint('PrivacyService: Account deletion requested for $userId');
    return request;
  }

  /// Confirm account deletion.
  Future<AccountDeletionRequest> confirmDeletion(String requestId) async {
    final request = await getDeletionRequest(requestId);
    if (request == null) {
      throw Exception('Deletion request not found');
    }

    final confirmed = AccountDeletionRequest(
      id: request.id,
      oduserId: request.oduserId,
      status: DeletionStatus.confirmed,
      requestedAt: request.requestedAt,
      scheduledAt: request.scheduledAt,
      reason: request.reason,
      confirmed: true,
    );

    await _saveDeletionRequest(confirmed);
    debugPrint('PrivacyService: Deletion confirmed for ${request.oduserId}');
    return confirmed;
  }

  /// Cancel account deletion.
  Future<AccountDeletionRequest> cancelDeletion(String requestId) async {
    final request = await getDeletionRequest(requestId);
    if (request == null) {
      throw Exception('Deletion request not found');
    }

    if (!request.canCancel) {
      throw Exception('Cannot cancel deletion at this stage');
    }

    final cancelled = AccountDeletionRequest(
      id: request.id,
      oduserId: request.oduserId,
      status: DeletionStatus.cancelled,
      requestedAt: request.requestedAt,
      scheduledAt: request.scheduledAt,
      reason: request.reason,
      confirmed: false,
    );

    await _saveDeletionRequest(cancelled);
    debugPrint('PrivacyService: Deletion cancelled for ${request.oduserId}');
    return cancelled;
  }

  /// Get deletion request.
  Future<AccountDeletionRequest?> getDeletionRequest(String requestId) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_deletionRequestsKey}_$requestId');

      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return AccountDeletionRequest(
        id: data['id'] as String,
        oduserId: data['userId'] as String,
        status: DeletionStatus.values.byName(data['status'] as String),
        requestedAt: DateTime.parse(data['requestedAt'] as String),
        scheduledAt: DateTime.parse(data['scheduledAt'] as String),
        executedAt: data['executedAt'] != null
            ? DateTime.parse(data['executedAt'] as String)
            : null,
        reason: data['reason'] as String?,
        confirmed: data['confirmed'] as bool? ?? false,
      );
    } catch (e) {
      debugPrint('PrivacyService: Error getting deletion request: $e');
      return null;
    }
  }

  // ============ UC271: Analytics Anonymization ============

  /// Generate anonymized user ID for analytics.
  String generateAnonymousId(String oduserId) {
    // Create a hash-like ID that can't be traced back
    final hash = oduserId.hashCode.abs().toRadixString(36);
    return 'anon_$hash';
  }

  /// Anonymize analytics event.
  Map<String, dynamic> anonymizeEvent(Map<String, dynamic> event) {
    // Remove PII fields
    final anonymized = Map<String, dynamic>.from(event);
    anonymized.remove('userId');
    anonymized.remove('email');
    anonymized.remove('name');
    anonymized.remove('phone');
    anonymized.remove('ipAddress');

    // Add anonymized ID if userId was present
    if (event.containsKey('userId')) {
      anonymized['anonymousId'] = generateAnonymousId(event['userId'] as String);
    }

    return anonymized;
  }

  // ============ UC272-UC273: Security ============

  /// Record login attempt.
  Future<LoginAttemptResult> recordLoginAttempt(
    String identifier, {
    required bool success,
    String? ipAddress,
  }) async {
    final prefs = await _preferences;
    final key = '${_loginAttemptsKey}_$identifier';

    if (success) {
      // Clear failed attempts on success
      await prefs.remove(key);
      await _recordSecurityEvent(
        userId: identifier,
        type: SecurityEventType.loginSuccess,
        ipAddress: ipAddress,
      );
      return LoginAttemptResult.success();
    }

    // Get current failed attempts
    final attemptsJson = prefs.getString(key);
    LoginAttempts attempts;

    if (attemptsJson != null) {
      final data = jsonDecode(attemptsJson) as Map<String, dynamic>;
      attempts = LoginAttempts(
        count: data['count'] as int,
        firstAttempt: DateTime.parse(data['firstAttempt'] as String),
        lastAttempt: DateTime.parse(data['lastAttempt'] as String),
        lockedUntil: data['lockedUntil'] != null
            ? DateTime.parse(data['lockedUntil'] as String)
            : null,
      );
    } else {
      attempts = LoginAttempts(
        count: 0,
        firstAttempt: DateTime.now(),
        lastAttempt: DateTime.now(),
      );
    }

    // Check if currently locked
    if (attempts.isLocked) {
      await _recordSecurityEvent(
        userId: identifier,
        type: SecurityEventType.loginBlocked,
        ipAddress: ipAddress,
        blocked: true,
      );
      return LoginAttemptResult.locked(attempts.lockedUntil!);
    }

    // Increment attempts
    final newAttempts = LoginAttempts(
      count: attempts.count + 1,
      firstAttempt: attempts.firstAttempt,
      lastAttempt: DateTime.now(),
      lockedUntil: attempts.count + 1 >= maxLoginAttempts
          ? DateTime.now().add(const Duration(minutes: lockoutMinutes))
          : null,
    );

    await prefs.setString(
      key,
      jsonEncode({
        'count': newAttempts.count,
        'firstAttempt': newAttempts.firstAttempt.toIso8601String(),
        'lastAttempt': newAttempts.lastAttempt.toIso8601String(),
        'lockedUntil': newAttempts.lockedUntil?.toIso8601String(),
      }),
    );

    await _recordSecurityEvent(
      userId: identifier,
      type: SecurityEventType.loginFailed,
      ipAddress: ipAddress,
    );

    if (newAttempts.isLocked) {
      await _recordSecurityEvent(
        userId: identifier,
        type: SecurityEventType.accountLocked,
        ipAddress: ipAddress,
        blocked: true,
      );
      return LoginAttemptResult.locked(newAttempts.lockedUntil!);
    }

    return LoginAttemptResult.failed(
      attemptsRemaining: maxLoginAttempts - newAttempts.count,
    );
  }

  /// Check if user is locked out.
  Future<bool> isLockedOut(String identifier) async {
    final prefs = await _preferences;
    final key = '${_loginAttemptsKey}_$identifier';
    final attemptsJson = prefs.getString(key);

    if (attemptsJson == null) return false;

    final data = jsonDecode(attemptsJson) as Map<String, dynamic>;
    if (data['lockedUntil'] == null) return false;

    final lockedUntil = DateTime.parse(data['lockedUntil'] as String);
    return DateTime.now().isBefore(lockedUntil);
  }

  /// Get security events for user.
  Future<List<SecurityEvent>> getSecurityEvents(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final prefs = await _preferences;
      final json = prefs.getString('${_securityEventsKey}_$userId');

      if (json == null) return [];

      final List<dynamic> list = jsonDecode(json);
      return list
          .take(limit)
          .map((e) => SecurityEvent(
                id: e['id'] as String,
                userId: e['userId'] as String?,
                type: SecurityEventType.values.byName(e['type'] as String),
                occurredAt: DateTime.parse(e['occurredAt'] as String),
                ipAddress: e['ipAddress'] as String?,
                userAgent: e['userAgent'] as String?,
                location: e['location'] as String?,
                blocked: e['blocked'] as bool? ?? false,
              ))
          .toList();
    } catch (e) {
      debugPrint('PrivacyService: Error getting security events: $e');
      return [];
    }
  }

  // ============ Private Methods ============

  Future<void> _saveConsent(UserConsent consent) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_consentKey}_${consent.userId}',
      jsonEncode(consent.toJson()),
    );
  }

  Future<void> _saveExportRequest(DataExportRequest request) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_exportRequestsKey}_${request.id}',
      jsonEncode({
        'id': request.id,
        'userId': request.oduserId,
        'status': request.status.name,
        'requestedAt': request.requestedAt.toIso8601String(),
        'completedAt': request.completedAt?.toIso8601String(),
        'downloadUrl': request.downloadUrl,
        'expiresAt': request.expiresAt?.toIso8601String(),
        'includedData': request.includedData.map((e) => e.name).toList(),
      }),
    );
  }

  Future<void> _saveDeletionRequest(AccountDeletionRequest request) async {
    final prefs = await _preferences;
    await prefs.setString(
      '${_deletionRequestsKey}_${request.id}',
      jsonEncode({
        'id': request.id,
        'userId': request.oduserId,
        'status': request.status.name,
        'requestedAt': request.requestedAt.toIso8601String(),
        'scheduledAt': request.scheduledAt.toIso8601String(),
        'executedAt': request.executedAt?.toIso8601String(),
        'reason': request.reason,
        'confirmed': request.confirmed,
      }),
    );
  }

  Future<void> _recordSecurityEvent({
    String? userId,
    required SecurityEventType type,
    String? ipAddress,
    String? userAgent,
    bool blocked = false,
  }) async {
    final event = SecurityEvent(
      id: _uuid.v4(),
      userId: userId,
      type: type,
      occurredAt: DateTime.now(),
      ipAddress: ipAddress,
      userAgent: userAgent,
      blocked: blocked,
    );

    if (userId != null) {
      final prefs = await _preferences;
      final key = '${_securityEventsKey}_$userId';
      final existing = prefs.getString(key);

      List<Map<String, dynamic>> events = [];
      if (existing != null) {
        events = (jsonDecode(existing) as List<dynamic>)
            .cast<Map<String, dynamic>>();
      }

      events.insert(0, {
        'id': event.id,
        'userId': event.userId,
        'type': event.type.name,
        'occurredAt': event.occurredAt.toIso8601String(),
        'ipAddress': event.ipAddress,
        'userAgent': event.userAgent,
        'location': event.location,
        'blocked': event.blocked,
      });

      // Keep only last 100 events
      if (events.length > 100) {
        events = events.take(100).toList();
      }

      await prefs.setString(key, jsonEncode(events));
    }
  }
}

/// Login attempt tracking.
class LoginAttempts {
  final int count;
  final DateTime firstAttempt;
  final DateTime lastAttempt;
  final DateTime? lockedUntil;

  const LoginAttempts({
    required this.count,
    required this.firstAttempt,
    required this.lastAttempt,
    this.lockedUntil,
  });

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);
}

/// Result of login attempt.
class LoginAttemptResult {
  final bool isSuccess;
  final bool isLocked;
  final DateTime? lockedUntil;
  final int? attemptsRemaining;

  const LoginAttemptResult._({
    required this.isSuccess,
    required this.isLocked,
    this.lockedUntil,
    this.attemptsRemaining,
  });

  factory LoginAttemptResult.success() {
    return const LoginAttemptResult._(
      isSuccess: true,
      isLocked: false,
    );
  }

  factory LoginAttemptResult.failed({required int attemptsRemaining}) {
    return LoginAttemptResult._(
      isSuccess: false,
      isLocked: false,
      attemptsRemaining: attemptsRemaining,
    );
  }

  factory LoginAttemptResult.locked(DateTime until) {
    return LoginAttemptResult._(
      isSuccess: false,
      isLocked: true,
      lockedUntil: until,
    );
  }
}
