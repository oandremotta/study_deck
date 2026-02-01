/// Stub for non-web platforms.
///
/// This file is used on mobile/desktop where JS interop is not available.
/// The actual implementation is in ads_web_interop.dart for web.
library;

Future<int> showWebRewardedAd() async {
  // This should never be called on non-web platforms
  throw UnsupportedError('Web ads are only supported on web platform');
}
