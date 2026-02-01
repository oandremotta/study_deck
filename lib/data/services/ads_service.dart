import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ads_web_stub.dart' if (dart.library.js_interop) 'ads_web_interop.dart';

/// UC208-UC210, UC078-UC088: Rewarded ads service with anti-abuse protection.
///
/// Handles:
/// - UC208: Show rewarded ad
/// - UC209: Grant credit after watching
/// - UC210: Daily ad limit enforcement
/// - UC078: Configurable daily credit limits
/// - UC079: Cooldown between ads
/// - UC081: Ad completion validation
/// - UC084: Farm detection
/// - UC088: Shadow ban (silent punishment)
class AdsService {
  // Storage keys
  static const String _dailyAdsCountKey = 'daily_ads_count';
  static const String _lastAdDateKey = 'last_ad_date';
  static const String _lastAdTimestampKey = 'last_ad_timestamp';
  static const String _adHistoryKey = 'ad_watch_history';
  static const String _shadowBanKey = 'ad_shadow_ban';
  static const String _abuseScoreKey = 'ad_abuse_score';
  static const String _studyAfterAdsKey = 'study_after_ads';

  // UC078: Configurable limits
  static const int maxDailyAdsForFree = 3;
  static const int maxDailyAdsForPremium = 5;
  static const int creditsPerAd = 1;

  // UC079: Cooldown settings (in minutes)
  static const int cooldownMinutesFree = 60; // 1 hour for free users
  static const int cooldownMinutesPremium = 30; // 30 min for premium

  // UC084: Farm detection thresholds
  static const int maxAdsPerHour = 2;
  static const int suspiciousPatternThreshold = 3; // days with max ads and no study
  static const double abuseScoreThreshold = 0.7;

  // Ad unit IDs
  // Android: Real production ID
  static const String _rewardedAdUnitAndroid =
      'ca-app-pub-2826419607983408/4259633889';
  // iOS: Test ID (replace with real iOS ad unit when created)
  static const String _rewardedAdUnitIos =
      'ca-app-pub-3940256099942544/1712485313';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  /// Check if rewarded ad is loaded and ready.
  bool get isAdReady => _isAdLoaded;

  /// Check if currently loading an ad.
  bool get isLoading => _isLoading;

  /// Get the ad unit ID for the current platform.
  String get _adUnitId {
    if (kIsWeb) {
      // Web doesn't support mobile ads
      return '';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _rewardedAdUnitAndroid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _rewardedAdUnitIos;
    }
    return '';
  }

  /// Initialize the ads SDK.
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('AdsService: Mobile ads not supported on web');
      return;
    }

    try {
      await MobileAds.instance.initialize();
      debugPrint('AdsService: SDK initialized');
    } catch (e) {
      debugPrint('AdsService: Failed to initialize SDK: $e');
    }
  }

  /// Load a rewarded ad.
  Future<bool> loadRewardedAd() async {
    if (kIsWeb) {
      // Web uses AdSense, not AdMob
      _isAdLoaded = true;
      return true;
    }

    if (_isLoading || _isAdLoaded) return _isAdLoaded;

    _isLoading = true;

    final completer = Completer<bool>();

    try {
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isAdLoaded = true;
            _isLoading = false;
            debugPrint('AdsService: Rewarded ad loaded');
            completer.complete(true);
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            debugPrint('AdsService: Failed to load rewarded ad: ${error.message}');
            completer.complete(false);
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      _isLoading = false;
      debugPrint('AdsService: Error loading ad: $e');
      return false;
    }
  }

  /// Show a rewarded ad and return whether user earned the reward.
  ///
  /// Returns the number of credits earned (0 if ad was not watched).
  Future<int> showRewardedAd() async {
    if (kIsWeb) {
      // Web uses AdSense via JavaScript interop
      debugPrint('AdsService: Showing AdSense rewarded ad on web');
      try {
        final credits = await showWebRewardedAd();
        if (credits > 0) {
          _isAdLoaded = false;
          await _recordAdWatched();
          debugPrint('AdsService: Web ad completed, earned $credits credits');
          return credits;
        }
        debugPrint('AdsService: Web ad dismissed without reward');
        return 0;
      } catch (e) {
        debugPrint('AdsService: Web ad error: $e');
        return 0;
      }
    }

    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('AdsService: No ad loaded');
      return 0;
    }

    final completer = Completer<int>();

    try {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('AdsService: Ad dismissed');
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          // Preload next ad
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('AdsService: Ad failed to show: ${error.message}');
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          if (!completer.isCompleted) {
            completer.complete(0);
          }
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('AdsService: User earned reward: ${reward.amount} ${reward.type}');
          await _recordAdWatched();
          if (!completer.isCompleted) {
            completer.complete(creditsPerAd);
          }
        },
      );

      // Wait for reward or timeout
      return await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => 0,
      );
    } catch (e) {
      debugPrint('AdsService: Error showing ad: $e');
      return 0;
    }
  }

  /// Check if user can watch more ads today.
  /// UC078: Checks daily limit
  /// UC079: Checks cooldown
  Future<bool> canWatchAd({bool isPremium = false}) async {
    // UC078: Check daily limit
    final count = await getDailyAdsWatched();
    final limit = isPremium ? maxDailyAdsForPremium : maxDailyAdsForFree;
    if (count >= limit) return false;

    // UC079: Check cooldown
    final cooldownComplete = await isCooldownComplete(isPremium: isPremium);
    return cooldownComplete;
  }

  /// Get detailed ad availability status.
  Future<AdAvailabilityStatus> getAdAvailabilityStatus({
    bool isPremium = false,
  }) async {
    final count = await getDailyAdsWatched();
    final limit = isPremium ? maxDailyAdsForPremium : maxDailyAdsForFree;
    final remaining = (limit - count).clamp(0, limit);

    if (remaining <= 0) {
      return AdAvailabilityStatus(
        canWatch: false,
        reason: AdBlockReason.dailyLimitReached,
        remainingToday: 0,
        cooldownMinutes: 0,
      );
    }

    final cooldownComplete = await isCooldownComplete(isPremium: isPremium);
    if (!cooldownComplete) {
      final cooldownMinutes =
          await getRemainingCooldownMinutes(isPremium: isPremium);
      return AdAvailabilityStatus(
        canWatch: false,
        reason: AdBlockReason.cooldownActive,
        remainingToday: remaining,
        cooldownMinutes: cooldownMinutes,
      );
    }

    return AdAvailabilityStatus(
      canWatch: true,
      reason: null,
      remainingToday: remaining,
      cooldownMinutes: 0,
    );
  }

  /// Get number of ads watched today.
  Future<int> getDailyAdsWatched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_lastAdDateKey);
      final today = _getTodayString();

      if (lastDateStr != today) {
        // Reset counter for new day
        await prefs.setInt(_dailyAdsCountKey, 0);
        await prefs.setString(_lastAdDateKey, today);
        // UC084: Reset study flag for new day
        await _resetDailyStudyFlag();
        return 0;
      }

      return prefs.getInt(_dailyAdsCountKey) ?? 0;
    } catch (e) {
      debugPrint('AdsService: Error getting daily ads count: $e');
      return 0;
    }
  }

  /// Get remaining ads for today.
  Future<int> getRemainingAds({bool isPremium = false}) async {
    final watched = await getDailyAdsWatched();
    final limit = isPremium ? maxDailyAdsForPremium : maxDailyAdsForFree;
    return (limit - watched).clamp(0, limit);
  }

  /// Record that user watched an ad.
  Future<void> _recordAdWatched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _getTodayString();
      final now = DateTime.now().millisecondsSinceEpoch;

      await prefs.setString(_lastAdDateKey, today);
      await prefs.setInt(_lastAdTimestampKey, now);

      final currentCount = prefs.getInt(_dailyAdsCountKey) ?? 0;
      await prefs.setInt(_dailyAdsCountKey, currentCount + 1);

      // UC084: Record in history for pattern detection
      await _recordAdHistory(now);
    } catch (e) {
      debugPrint('AdsService: Error recording ad watched: $e');
    }
  }

  // ============ UC079: Cooldown System ============

  /// Check if cooldown period has passed since last ad.
  Future<bool> isCooldownComplete({bool isPremium = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp = prefs.getInt(_lastAdTimestampKey);

      if (lastTimestamp == null) return true;

      final cooldownMinutes =
          isPremium ? cooldownMinutesPremium : cooldownMinutesFree;
      final cooldownMs = cooldownMinutes * 60 * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;

      return (now - lastTimestamp) >= cooldownMs;
    } catch (e) {
      debugPrint('AdsService: Error checking cooldown: $e');
      return true;
    }
  }

  /// Get remaining cooldown time in minutes.
  Future<int> getRemainingCooldownMinutes({bool isPremium = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp = prefs.getInt(_lastAdTimestampKey);

      if (lastTimestamp == null) return 0;

      final cooldownMinutes =
          isPremium ? cooldownMinutesPremium : cooldownMinutesFree;
      final cooldownMs = cooldownMinutes * 60 * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsed = now - lastTimestamp;
      final remaining = cooldownMs - elapsed;

      return remaining > 0 ? (remaining / 60000).ceil() : 0;
    } catch (e) {
      return 0;
    }
  }

  // ============ UC084: Farm Detection ============

  /// Record ad watch in history for pattern detection.
  Future<void> _recordAdHistory(int timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_adHistoryKey) ?? '[]';
      final history = List<int>.from(jsonDecode(historyJson));

      history.add(timestamp);

      // Keep only last 7 days of history
      final sevenDaysAgo =
          DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
      history.removeWhere((ts) => ts < sevenDaysAgo);

      await prefs.setString(_adHistoryKey, jsonEncode(history));

      // Update abuse score
      await _updateAbuseScore(history);
    } catch (e) {
      debugPrint('AdsService: Error recording ad history: $e');
    }
  }

  /// Update abuse score based on watching patterns.
  Future<void> _updateAbuseScore(List<int> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Calculate abuse indicators
      double score = 0.0;

      // Check ads per hour pattern
      final oneHourAgo =
          DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      final adsLastHour = history.where((ts) => ts > oneHourAgo).length;
      if (adsLastHour > maxAdsPerHour) {
        score += 0.3;
      }

      // Check study activity after ads
      final studyAfterAds = prefs.getBool(_studyAfterAdsKey) ?? true;
      if (!studyAfterAds) {
        score += 0.2;
      }

      // Check daily max pattern (hitting max every day)
      final daysAtMax = prefs.getInt('days_at_max_ads') ?? 0;
      if (daysAtMax >= suspiciousPatternThreshold) {
        score += 0.3;
      }

      // Clamp score
      score = score.clamp(0.0, 1.0);

      await prefs.setDouble(_abuseScoreKey, score);

      // UC088: Apply shadow ban if threshold exceeded
      if (score >= abuseScoreThreshold) {
        await _applyShadowBan();
      }
    } catch (e) {
      debugPrint('AdsService: Error updating abuse score: $e');
    }
  }

  /// Get current abuse score (0.0 = clean, 1.0 = abuser).
  Future<double> getAbuseScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_abuseScoreKey) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // ============ UC088: Shadow Ban ============

  /// Apply shadow ban (silently stop granting rewards).
  Future<void> _applyShadowBan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final banUntil = DateTime.now()
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch;
      await prefs.setInt(_shadowBanKey, banUntil);
      debugPrint('AdsService: Shadow ban applied until ${DateTime.fromMillisecondsSinceEpoch(banUntil)}');
    } catch (e) {
      debugPrint('AdsService: Error applying shadow ban: $e');
    }
  }

  /// Check if user is shadow banned.
  Future<bool> isShadowBanned() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final banUntil = prefs.getInt(_shadowBanKey);

      if (banUntil == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now >= banUntil) {
        // Ban expired, clear it
        await prefs.remove(_shadowBanKey);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Record that user studied after watching ads (reduces abuse score).
  Future<void> recordStudyActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_studyAfterAdsKey, true);

      // Gradually reduce abuse score when user studies
      final currentScore = prefs.getDouble(_abuseScoreKey) ?? 0.0;
      if (currentScore > 0) {
        await prefs.setDouble(_abuseScoreKey, (currentScore - 0.1).clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('AdsService: Error recording study activity: $e');
    }
  }

  /// Reset study activity flag (called at start of day).
  Future<void> _resetDailyStudyFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_studyAfterAdsKey, false);
    } catch (e) {
      debugPrint('AdsService: Error resetting study flag: $e');
    }
  }

  // ============ UC081: Enhanced Validation ============

  /// Validate ad completion (called by ad SDK callback).
  /// Returns true if reward should be granted.
  Future<bool> validateAdCompletion({
    required bool adCompleted,
    required int watchDurationMs,
    required bool wasInForeground,
  }) async {
    // UC081: Must complete ad fully
    if (!adCompleted) {
      debugPrint('AdsService: Ad not completed');
      return false;
    }

    // UC081: Must have minimum watch time (5 seconds minimum)
    if (watchDurationMs < 5000) {
      debugPrint('AdsService: Watch duration too short: $watchDurationMs ms');
      return false;
    }

    // UC081: Must be in foreground
    if (!wasInForeground) {
      debugPrint('AdsService: App was in background');
      return false;
    }

    // UC088: Check shadow ban
    if (await isShadowBanned()) {
      debugPrint('AdsService: User is shadow banned');
      return false; // Silently reject
    }

    return true;
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Dispose resources.
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}

/// Result of attempting to watch an ad.
class AdWatchResult {
  final bool success;
  final int creditsEarned;
  final String? errorMessage;

  const AdWatchResult({
    required this.success,
    this.creditsEarned = 0,
    this.errorMessage,
  });

  factory AdWatchResult.success(int credits) => AdWatchResult(
        success: true,
        creditsEarned: credits,
      );

  factory AdWatchResult.error(String message) => AdWatchResult(
        success: false,
        errorMessage: message,
      );

  factory AdWatchResult.limitReached() => const AdWatchResult(
        success: false,
        errorMessage: 'Limite diario de anuncios atingido',
      );

  factory AdWatchResult.notLoaded() => const AdWatchResult(
        success: false,
        errorMessage: 'Anuncio nao carregado',
      );

  factory AdWatchResult.cooldown(int minutes) => AdWatchResult(
        success: false,
        errorMessage: 'Aguarde $minutes minuto(s) para assistir outro anuncio',
      );
}

/// UC079: Reasons why ad watching may be blocked.
enum AdBlockReason {
  dailyLimitReached,
  cooldownActive,
  shadowBanned,
}

/// UC078-079: Detailed ad availability status.
class AdAvailabilityStatus {
  final bool canWatch;
  final AdBlockReason? reason;
  final int remainingToday;
  final int cooldownMinutes;

  const AdAvailabilityStatus({
    required this.canWatch,
    required this.reason,
    required this.remainingToday,
    required this.cooldownMinutes,
  });

  /// User-friendly message explaining why ads are blocked.
  String? get blockMessage {
    switch (reason) {
      case AdBlockReason.dailyLimitReached:
        return 'Limite diario atingido. Volte amanha!';
      case AdBlockReason.cooldownActive:
        return 'Aguarde $cooldownMinutes minuto(s) para o proximo anuncio';
      case AdBlockReason.shadowBanned:
        return null; // Silent - no message
      case null:
        return null;
    }
  }
}
