import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UC090, UC095, UC100: AI abuse prevention service.
///
/// Handles:
/// - UC090: Rate limiting AI generations per time
/// - UC095: Detecting repeated prompts
/// - UC100: Reducing AI quality on abuse (fallback)
/// - UC103: Device fingerprinting
/// - UC110: Punishment escalation
class AiAbuseService {
  // Storage keys
  static const String _generationHistoryKey = 'ai_generation_history';
  static const String _promptHashesKey = 'ai_prompt_hashes';
  static const String _abuseScoreKey = 'ai_abuse_score';
  static const String _punishmentLevelKey = 'ai_punishment_level';
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _accountsOnDeviceKey = 'accounts_on_device';
  static const String _lastGenerationKey = 'last_ai_generation';

  // UC090: Rate limits
  static const int maxGenerationsPerMinute = 2;
  static const int maxGenerationsPerHour = 10;
  static const int maxGenerationsPerDayFree = 20;
  static const int maxGenerationsPerDayPremium = 100;

  // UC095: Prompt hash settings
  static const int promptHashWindowMinutes = 30;
  static const int maxIdenticalPromptsInWindow = 2;

  // UC100: Quality reduction thresholds
  static const double qualityReductionThreshold = 0.5;
  static const double hardBlockThreshold = 0.9;

  // UC103: Multi-account limits
  static const int maxAccountsPerDevice = 3;

  // ============ UC090: Rate Limiting ============

  /// Check if user can make an AI generation request.
  Future<AiRateLimitResult> checkRateLimit({bool isPremium = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Get generation history
      final historyJson = prefs.getString(_generationHistoryKey) ?? '[]';
      final history = List<int>.from(jsonDecode(historyJson));

      // Clean old entries (older than 24 hours)
      final oneDayAgo = now - (24 * 60 * 60 * 1000);
      history.removeWhere((ts) => ts < oneDayAgo);

      // Check per-minute limit
      final oneMinuteAgo = now - (60 * 1000);
      final lastMinute = history.where((ts) => ts > oneMinuteAgo).length;
      if (lastMinute >= maxGenerationsPerMinute) {
        return AiRateLimitResult.blocked(
          reason: RateLimitReason.perMinute,
          waitSeconds: 60 - ((now - history.last) ~/ 1000),
        );
      }

      // Check per-hour limit
      final oneHourAgo = now - (60 * 60 * 1000);
      final lastHour = history.where((ts) => ts > oneHourAgo).length;
      if (lastHour >= maxGenerationsPerHour) {
        final oldestInHour = history.where((ts) => ts > oneHourAgo).first;
        return AiRateLimitResult.blocked(
          reason: RateLimitReason.perHour,
          waitSeconds: ((oldestInHour + 3600000 - now) ~/ 1000),
        );
      }

      // Check per-day limit
      final dailyLimit =
          isPremium ? maxGenerationsPerDayPremium : maxGenerationsPerDayFree;
      if (history.length >= dailyLimit) {
        return AiRateLimitResult.blocked(
          reason: RateLimitReason.perDay,
          waitSeconds: 0, // Will reset at midnight
        );
      }

      return AiRateLimitResult.allowed(
        remainingToday: dailyLimit - history.length,
      );
    } catch (e) {
      debugPrint('AiAbuseService: Error checking rate limit: $e');
      return AiRateLimitResult.allowed(remainingToday: 999);
    }
  }

  /// Record an AI generation.
  Future<void> recordGeneration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      final historyJson = prefs.getString(_generationHistoryKey) ?? '[]';
      final history = List<int>.from(jsonDecode(historyJson));
      history.add(now);

      // Keep only last 24 hours
      final oneDayAgo = now - (24 * 60 * 60 * 1000);
      history.removeWhere((ts) => ts < oneDayAgo);

      await prefs.setString(_generationHistoryKey, jsonEncode(history));
      await prefs.setInt(_lastGenerationKey, now);
    } catch (e) {
      debugPrint('AiAbuseService: Error recording generation: $e');
    }
  }

  // ============ UC095: Prompt Hash Detection ============

  /// Check if prompt is repeated (spam detection).
  Future<PromptCheckResult> checkPrompt(String prompt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Calculate hash of normalized prompt
      final normalizedPrompt = _normalizePrompt(prompt);
      final hash = _hashPrompt(normalizedPrompt);

      // Get existing hashes with timestamps
      final hashesJson = prefs.getString(_promptHashesKey) ?? '{}';
      final hashes = Map<String, List<dynamic>>.from(
        jsonDecode(hashesJson).map(
          (k, v) => MapEntry(k, List<dynamic>.from(v)),
        ),
      );

      // Clean old entries
      final windowStart = now - (promptHashWindowMinutes * 60 * 1000);
      hashes.forEach((key, timestamps) {
        timestamps.removeWhere((ts) => (ts as int) < windowStart);
      });
      hashes.removeWhere((key, timestamps) => timestamps.isEmpty);

      // Check if hash exists in window
      final existingTimestamps = hashes[hash] ?? [];
      if (existingTimestamps.length >= maxIdenticalPromptsInWindow) {
        // Update abuse score
        await _incrementAbuseScore(0.2);
        return PromptCheckResult.repeated(
          message: 'Conteudo repetido detectado. Tente um texto diferente.',
        );
      }

      // Add new hash
      existingTimestamps.add(now);
      hashes[hash] = existingTimestamps;
      await prefs.setString(_promptHashesKey, jsonEncode(hashes));

      return PromptCheckResult.allowed();
    } catch (e) {
      debugPrint('AiAbuseService: Error checking prompt: $e');
      return PromptCheckResult.allowed();
    }
  }

  String _normalizePrompt(String prompt) {
    return prompt
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _hashPrompt(String prompt) {
    // Simple hash using hashCode (good enough for local duplicate detection)
    return prompt.hashCode.toRadixString(16);
  }

  // ============ UC100: Quality Reduction ============

  /// Get current AI quality level based on abuse score.
  Future<AiQualityLevel> getQualityLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final score = prefs.getDouble(_abuseScoreKey) ?? 0.0;

      if (score >= hardBlockThreshold) {
        return AiQualityLevel.blocked;
      } else if (score >= qualityReductionThreshold) {
        return AiQualityLevel.reduced;
      }
      return AiQualityLevel.full;
    } catch (e) {
      return AiQualityLevel.full;
    }
  }

  /// Get recommended card count based on quality level.
  int getAdjustedCardCount(int requestedCount, AiQualityLevel level) {
    switch (level) {
      case AiQualityLevel.full:
        return requestedCount;
      case AiQualityLevel.reduced:
        return (requestedCount * 0.5).ceil().clamp(1, requestedCount);
      case AiQualityLevel.blocked:
        return 0;
    }
  }

  // ============ UC103: Device Fingerprinting ============

  /// Get or create device fingerprint.
  Future<String> getDeviceFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var fingerprint = prefs.getString(_deviceFingerprintKey);

      if (fingerprint == null) {
        // Generate simple fingerprint
        fingerprint = _generateFingerprint();
        await prefs.setString(_deviceFingerprintKey, fingerprint);
      }

      return fingerprint;
    } catch (e) {
      return 'unknown';
    }
  }

  String _generateFingerprint() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = now.toString() + kIsWeb.toString() + DateTime.now().microsecond.toString();
    // Simple fingerprint using hashCode
    return 'fp_${random.hashCode.toRadixString(16)}';
  }

  /// Register account on device.
  Future<AccountRegistrationResult> registerAccount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fingerprint = await getDeviceFingerprint();

      final accountsJson = prefs.getString(_accountsOnDeviceKey) ?? '{}';
      final accounts = Map<String, List<dynamic>>.from(
        jsonDecode(accountsJson).map(
          (k, v) => MapEntry(k, List<dynamic>.from(v)),
        ),
      );

      final deviceAccounts = accounts[fingerprint] ?? [];

      if (!deviceAccounts.contains(userId)) {
        if (deviceAccounts.length >= maxAccountsPerDevice) {
          return AccountRegistrationResult.tooManyAccounts(
            maxAllowed: maxAccountsPerDevice,
          );
        }
        deviceAccounts.add(userId);
        accounts[fingerprint] = deviceAccounts;
        await prefs.setString(_accountsOnDeviceKey, jsonEncode(accounts));
      }

      return AccountRegistrationResult.success(
        accountsOnDevice: deviceAccounts.length,
      );
    } catch (e) {
      debugPrint('AiAbuseService: Error registering account: $e');
      return AccountRegistrationResult.success(accountsOnDevice: 1);
    }
  }

  // ============ UC110: Punishment Escalation ============

  /// Get current punishment level.
  Future<PunishmentLevel> getPunishmentLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final level = prefs.getInt(_punishmentLevelKey) ?? 0;
      return PunishmentLevel.values[level.clamp(0, PunishmentLevel.values.length - 1)];
    } catch (e) {
      return PunishmentLevel.none;
    }
  }

  /// Escalate punishment based on abuse.
  Future<void> escalatePunishment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt(_punishmentLevelKey) ?? 0;
      final newLevel = (currentLevel + 1).clamp(0, PunishmentLevel.values.length - 1);
      await prefs.setInt(_punishmentLevelKey, newLevel);
      debugPrint('AiAbuseService: Punishment escalated to level $newLevel');
    } catch (e) {
      debugPrint('AiAbuseService: Error escalating punishment: $e');
    }
  }

  /// Reduce punishment (good behavior).
  Future<void> reducePunishment() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentLevel = prefs.getInt(_punishmentLevelKey) ?? 0;
      if (currentLevel > 0) {
        await prefs.setInt(_punishmentLevelKey, currentLevel - 1);
      }
    } catch (e) {
      debugPrint('AiAbuseService: Error reducing punishment: $e');
    }
  }

  // ============ Abuse Score Management ============

  Future<void> _incrementAbuseScore(double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getDouble(_abuseScoreKey) ?? 0.0;
      final newScore = (current + amount).clamp(0.0, 1.0);
      await prefs.setDouble(_abuseScoreKey, newScore);

      // Check if should escalate punishment
      if (newScore >= hardBlockThreshold) {
        await escalatePunishment();
      }
    } catch (e) {
      debugPrint('AiAbuseService: Error incrementing abuse score: $e');
    }
  }

  /// Get current abuse score.
  Future<double> getAbuseScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_abuseScoreKey) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Record good behavior (reduces abuse score).
  Future<void> recordGoodBehavior() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getDouble(_abuseScoreKey) ?? 0.0;
      if (current > 0) {
        await prefs.setDouble(_abuseScoreKey, (current - 0.05).clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('AiAbuseService: Error recording good behavior: $e');
    }
  }
}

// ============ Result Classes ============

/// UC090: Rate limit check result.
class AiRateLimitResult {
  final bool allowed;
  final RateLimitReason? reason;
  final int waitSeconds;
  final int remainingToday;

  const AiRateLimitResult({
    required this.allowed,
    this.reason,
    this.waitSeconds = 0,
    this.remainingToday = 0,
  });

  factory AiRateLimitResult.allowed({required int remainingToday}) =>
      AiRateLimitResult(allowed: true, remainingToday: remainingToday);

  factory AiRateLimitResult.blocked({
    required RateLimitReason reason,
    required int waitSeconds,
  }) =>
      AiRateLimitResult(
        allowed: false,
        reason: reason,
        waitSeconds: waitSeconds,
      );

  String? get message {
    if (allowed) return null;
    switch (reason) {
      case RateLimitReason.perMinute:
        return 'Aguarde ${waitSeconds}s antes da proxima geracao';
      case RateLimitReason.perHour:
        final minutes = (waitSeconds / 60).ceil();
        return 'Limite por hora atingido. Aguarde $minutes min';
      case RateLimitReason.perDay:
        return 'Limite diario atingido. Volte amanha!';
      case null:
        return null;
    }
  }
}

enum RateLimitReason { perMinute, perHour, perDay }

/// UC095: Prompt check result.
class PromptCheckResult {
  final bool allowed;
  final String? message;

  const PromptCheckResult({required this.allowed, this.message});

  factory PromptCheckResult.allowed() =>
      const PromptCheckResult(allowed: true);

  factory PromptCheckResult.repeated({required String message}) =>
      PromptCheckResult(allowed: false, message: message);
}

/// UC100: AI quality levels.
enum AiQualityLevel {
  full,    // Normal operation
  reduced, // Reduced card count, simpler responses
  blocked, // No AI access
}

/// UC103: Account registration result.
class AccountRegistrationResult {
  final bool allowed;
  final int accountsOnDevice;
  final int? maxAllowed;

  const AccountRegistrationResult({
    required this.allowed,
    this.accountsOnDevice = 1,
    this.maxAllowed,
  });

  factory AccountRegistrationResult.success({required int accountsOnDevice}) =>
      AccountRegistrationResult(allowed: true, accountsOnDevice: accountsOnDevice);

  factory AccountRegistrationResult.tooManyAccounts({required int maxAllowed}) =>
      AccountRegistrationResult(
        allowed: false,
        maxAllowed: maxAllowed,
      );
}

/// UC110: Punishment levels.
enum PunishmentLevel {
  none,           // Normal
  warning,        // Show warning messages
  reducedBenefits, // Fewer credits, longer cooldowns
  tempBlock,      // Temporary AI/ads block
  suspended,      // Full suspension
}
