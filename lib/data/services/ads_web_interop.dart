/// JavaScript interop for AdSense rewarded ads on web.
///
/// This file should only be imported when running on web platform.
/// Uses the showAdSenseRewardedAd function defined in index.html.
library;

import 'dart:async';
import 'dart:js_interop';

/// External JavaScript function to show AdSense rewarded ad.
@JS('showAdSenseRewardedAd')
external void _showAdSenseRewardedAd(
  JSFunction? onReward,
  JSFunction? onDismiss,
  JSFunction? onError,
);

/// Show a rewarded ad using AdSense on web.
///
/// Returns the number of credits earned (1 if ad was watched, 0 otherwise).
Future<int> showWebRewardedAd() {
  final completer = Completer<int>();

  try {
    _showAdSenseRewardedAd(
      // onReward callback
      ((int credits) {
        if (!completer.isCompleted) {
          completer.complete(credits);
        }
      }).toJS,
      // onDismiss callback
      (() {
        if (!completer.isCompleted) {
          completer.complete(0);
        }
      }).toJS,
      // onError callback
      ((String error) {
        if (!completer.isCompleted) {
          completer.complete(0);
        }
      }).toJS,
    );
  } catch (e) {
    if (!completer.isCompleted) {
      completer.complete(0);
    }
  }

  // Timeout after 60 seconds
  return completer.future.timeout(
    const Duration(seconds: 60),
    onTimeout: () => 0,
  );
}
