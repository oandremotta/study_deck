// Stub for non-web platforms
void downloadFile(String content, String fileName) {
  // This function is only used on web
  // On mobile, share_plus is used instead
  throw UnsupportedError('downloadFile is only available on web');
}
