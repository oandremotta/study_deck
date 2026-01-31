import 'dart:async';

import 'package:flutter/foundation.dart';

/// Google AdSense service for web platform.
///
/// Uses the Ad Placement API for rewarded ads on web.
/// Documentation: https://support.google.com/adsense/answer/9955214
///
/// Setup required:
/// 1. Create AdSense account at https://www.google.com/adsense
/// 2. Get your Publisher ID (ca-pub-XXXXXXXXXXXXXXXX)
/// 3. Update web/index.html with your Publisher ID
/// 4. Wait for AdSense approval (can take a few days)
class AdSenseService {
  bool _isInitialized = false;
  bool _isAdReady = true;

  /// Check if AdSense is initialized.
  bool get isInitialized => _isInitialized;

  /// Check if rewarded ad is ready.
  bool get isAdReady => _isAdReady;

  /// Initialize AdSense SDK for web.
  Future<void> initialize() async {
    if (!kIsWeb) {
      debugPrint('AdSenseService: Only available on web');
      return;
    }

    if (_isInitialized) return;

    try {
      _isInitialized = true;
      debugPrint('AdSenseService: Initialized');
    } catch (e) {
      debugPrint('AdSenseService: Failed to initialize: $e');
    }
  }

  /// Load a rewarded ad (AdSense handles this automatically).
  Future<bool> loadRewardedAd() async {
    if (!kIsWeb) return false;
    return true;
  }

  /// Show rewarded ad and return credits earned.
  ///
  /// This calls the JavaScript function defined in web/index.html.
  /// The function handles both real AdSense ads and development simulation.
  Future<int> showRewardedAd() async {
    if (!kIsWeb) return 0;

    try {
      // Call JavaScript function to show ad
      final credits = await _showAdViaJs();
      return credits;
    } catch (e) {
      debugPrint('AdSenseService: Failed to show ad: $e');
      return 0;
    }
  }

  /// Check if user can watch ads.
  Future<bool> canWatchAd() async {
    return kIsWeb && _isInitialized;
  }

  /// Show ad via JavaScript interop.
  Future<int> _showAdViaJs() async {
    final completer = Completer<int>();

    // Use the JavaScript function from index.html
    // For now, simulate until AdSense is properly configured
    await Future.delayed(const Duration(seconds: 2));
    completer.complete(1);

    return completer.future;
  }
}
