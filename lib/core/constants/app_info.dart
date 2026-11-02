/// Static application metadata.
abstract final class AppInfo {
  static const packageName = 'com.zaid.hisnalmuslim';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';

  /// Support contact shown in About/Privacy. Intentionally empty until the
  /// publisher provides a real address (see docs/release/GOOGLE_PLAY_CHECKLIST.md);
  /// the UI hides the contact row while it is empty.
  static const supportEmail = '';

  /// Official source of the book's text.
  static const contentSourceUrl = 'https://www.hisnmuslim.com';
}
