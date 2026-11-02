// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hisn Al-Muslim';

  @override
  String get appTagline => 'Fortify your day with the remembrance of Allah';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Adhkar';

  @override
  String get navTasbeeh => 'Tasbeeh';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionStart => 'Get started';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionShare => 'Share';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionBack => 'Back';

  @override
  String get copied => 'Text copied';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get greetingMorning => 'Blessed morning';

  @override
  String get greetingDay => 'Good day';

  @override
  String get greetingEvening => 'Blessed evening';

  @override
  String get greetingNight => 'Peaceful night';

  @override
  String get homeTodayWird => 'Today\'s wird';

  @override
  String homeWirdProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'Start your streak today',
    );
    return '$_temp0';
  }

  @override
  String get homeSuggested => 'Suggested now';

  @override
  String get homeDailyDhikr => 'Today\'s remembrance';

  @override
  String get homeQuickAccess => 'Quick access';

  @override
  String get homeAllCategories => 'All categories';

  @override
  String get homeCompletedToday => 'Completed today';

  @override
  String get searchHint => 'Search adhkar and supplications';

  @override
  String get libraryTitle => 'Adhkar library';

  @override
  String libraryItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adhkar',
      one: '1 dhikr',
      zero: 'No adhkar',
    );
    return '$_temp0';
  }

  @override
  String get categoryStart => 'Start reading';

  @override
  String get categoryContinue => 'Continue reading';

  @override
  String get categoryReadAgain => 'Read again';

  @override
  String get categoryDoneToday => 'Completed today';

  @override
  String repeatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      two: 'twice',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String readerOf(int current, int total) {
    return '$current of $total';
  }

  @override
  String get readerTapToCount => 'Tap to count';

  @override
  String get readerDone => 'Done';

  @override
  String get readerRemainingLabel => 'left';

  @override
  String get readerQuran => 'Quran';

  @override
  String get readerSunnah => 'Sunnah';

  @override
  String get readerReference => 'Source & reference';

  @override
  String get readerReferenceMissing =>
      'The reference for this item has not been attached yet.';

  @override
  String get readerBookNote => 'Note from the book';

  @override
  String get readerFootnoteTitle => 'Book footnote (Arabic)';

  @override
  String get readerSourceLabel => 'Source';

  @override
  String get readerTranslation => 'Translation';

  @override
  String get readerTransliteration => 'Transliteration';

  @override
  String readerTranslationBy(String source) {
    return 'Translation: $source';
  }

  @override
  String get readerFontSize => 'Text size';

  @override
  String get readerShowTranslation => 'Show English translation';

  @override
  String get readerAutoAdvance => 'Auto-advance when done';

  @override
  String get readerTapText => 'Tap the text to count';

  @override
  String get readerResetCount => 'Reset count';

  @override
  String get readerMarkDone => 'Mark as done';

  @override
  String readerCompleteTitle(String category) {
    return 'You completed $category';
  }

  @override
  String get readerCompleteBody => 'May Allah accept from us and from you.';

  @override
  String get readerBackToList => 'Back to list';

  @override
  String get readerStay => 'Stay here';

  @override
  String get readerEmpty => 'Nothing to read here.';

  @override
  String get readerDisplayOptions => 'Display options';

  @override
  String get shareFooter => '— via the Hisn Al-Muslim app';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on any dhikr to keep it here, always within reach.';

  @override
  String get favoritesSearchHint => 'Search favorites';

  @override
  String get favoritesReadAll => 'Read all';

  @override
  String get favoritesNoMatch => 'No matching favorites';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchIntro =>
      'Search by a word from the text, the occasion, or the English meaning. Diacritics are optional.';

  @override
  String get searchSuggestions => 'Suggestions';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchNoResultsHint => 'Try another word or part of a word.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchClear => 'Clear';

  @override
  String get tasbeehTitle => 'Tasbeeh';

  @override
  String get tasbeehTapHint => 'Tap the circle to count';

  @override
  String get tasbeehTarget => 'Target';

  @override
  String get tasbeehUnlimited => 'No limit';

  @override
  String get tasbeehRounds => 'Rounds';

  @override
  String get tasbeehToday => 'Today';

  @override
  String get tasbeehTotal => 'All time';

  @override
  String get tasbeehChoose => 'Choose dhikr';

  @override
  String get tasbeehAddCustom => 'Add your own';

  @override
  String get tasbeehCustomHint => 'Type the dhikr';

  @override
  String get tasbeehCustomTarget => 'Repetitions';

  @override
  String get tasbeehResetTitle => 'Reset the counter?';

  @override
  String get tasbeehResetBody =>
      'The current count and rounds go back to zero. Your statistics are kept.';

  @override
  String get tasbeehRoundDone => 'Round complete';

  @override
  String get tasbeehSound => 'Sound';

  @override
  String get tasbeehHaptics => 'Vibration';

  @override
  String get tasbeehDeleteCustom => 'Delete this dhikr';

  @override
  String tasbeehCountSemantics(int count) {
    return 'Count $count';
  }

  @override
  String tasbeehStatsFor(int count) {
    return 'All-time for this dhikr: $count';
  }

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersIntro =>
      'Optional daily reminders at the times you choose.';

  @override
  String get reminderMorning => 'Morning adhkar';

  @override
  String get reminderEvening => 'Evening adhkar';

  @override
  String get reminderSleep => 'Bedtime adhkar';

  @override
  String get reminderCustomSection => 'Custom reminders';

  @override
  String get reminderAdd => 'Add reminder';

  @override
  String get reminderTitleHint => 'Reminder title (e.g. Quran reading)';

  @override
  String get reminderTime => 'Time';

  @override
  String get reminderMorningBody => 'It\'s time for your morning adhkar.';

  @override
  String get reminderEveningBody => 'It\'s time for your evening adhkar.';

  @override
  String get reminderSleepBody => 'Don\'t forget your bedtime adhkar.';

  @override
  String get reminderCustomBody => 'A reminder from Hisn Al-Muslim';

  @override
  String get reminderChannelName => 'Adhkar reminders';

  @override
  String get reminderChannelDescription => 'Daily reminders chosen by the user';

  @override
  String get reminderPermissionTitle => 'Allow notifications';

  @override
  String get reminderPermissionBody =>
      'Notifications are used only to remind you of adhkar at the times you set. No ads or other messages, and you can turn them off at any time.';

  @override
  String get reminderPermissionDenied =>
      'Notifications are turned off for this app. Enable them in your device settings to receive reminders.';

  @override
  String get reminderNotNow => 'Not now';

  @override
  String get reminderDelete => 'Delete reminder';

  @override
  String get reminderInexactNote =>
      'Reminders may arrive a few minutes late to save battery.';

  @override
  String get reminderExactTitle => 'Precise reminder timing';

  @override
  String get reminderExactBody =>
      'Your system may delay reminders to save battery. Allow \"Alarms & reminders\" so they arrive on time.';

  @override
  String get reminderExactAction => 'Allow';

  @override
  String get reminderLimitReached =>
      'You\'ve reached the maximum number of custom reminders.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsReading => 'Reading';

  @override
  String get settingsFontSize => 'Adhkar text size';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsHaptics => 'Vibrate when counting';

  @override
  String get settingsSound => 'Click sound';

  @override
  String get settingsSoundHint => 'Follows your device\'s touch-sound setting';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsRemindersSubtitle =>
      'Morning, evening and bedtime reminders';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsResetProgress => 'Reset reading progress';

  @override
  String get settingsResetProgressBody =>
      'Today\'s counts and your completion history will be erased. This can\'t be undone.';

  @override
  String get settingsProgressReset => 'Progress reset';

  @override
  String get settingsClearData => 'Clear all app data';

  @override
  String get settingsClearDataBody =>
      'Favorites, progress, tasbeeh statistics, reminders and settings will be deleted from this device.';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSources => 'Content sources';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsShareApp => 'Share the app';

  @override
  String settingsShareMessage(String url) {
    return 'Hisn Al-Muslim — authentic adhkar and supplications, fully offline:\n$url';
  }

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsLicenses => 'Open-source and font licenses';

  @override
  String get settingsContact => 'Contact us';

  @override
  String get aboutBody =>
      'Hisn Al-Muslim brings together the daily adhkar and supplications from \"Hisn al-Muslim min Adhkar al-Kitab was-Sunnah\" (Fortress of the Muslim) by Sa\'id ibn Ali ibn Wahf al-Qahtani, together with supplications from the Quran, in a calm experience that works fully offline.';

  @override
  String get aboutPrinciples => 'Our principles';

  @override
  String get aboutPrincipleOffline => 'Works offline';

  @override
  String get aboutPrincipleNoAds => 'No ads, no tracking';

  @override
  String get aboutPrincipleNoAccount => 'No account needed';

  @override
  String get aboutContentNoticeTitle => 'About content accuracy';

  @override
  String get aboutContentNotice =>
      'Texts are taken verbatim from the listed sources and matched programmatically with the book\'s footnotes. They have not yet been reviewed by a qualified scholar. If you notice a mistake, please let us know.';

  @override
  String get sourcesTitle => 'Content sources';

  @override
  String get sourcesHisnTitle => 'Hisn al-Muslim';

  @override
  String get sourcesHisnBody =>
      'Adhkar text, repetition counts and English translation from the book\'s official website, hisnmuslim.com.';

  @override
  String get sourcesFootnotesTitle => 'Book footnotes';

  @override
  String get sourcesFootnotesBody =>
      'References and virtues come from a text transcription of the book\'s footnotes and are attached only when they match unambiguously.';

  @override
  String get sourcesEveningTitle => 'Evening wording';

  @override
  String get sourcesEveningBody =>
      'The book only notes the evening wording; the full evening text is shown only when it matches the book\'s note.';

  @override
  String get sourcesQuranTitle => 'Quranic verses';

  @override
  String get sourcesQuranBody =>
      'Verse text from the Tanzil Quran (tanzil.net, simple script); English meaning: Saheeh International.';

  @override
  String sourcesVersion(int version, int count) {
    return 'Content version $version · $count items';
  }

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyIntro =>
      'Hisn Al-Muslim does not collect any personal data and does not send data anywhere.';

  @override
  String get privacyPointAccount => 'No account or sign-in is required.';

  @override
  String get privacyPointAds =>
      'There are no ads, analytics or tracking tools.';

  @override
  String get privacyPointInternet =>
      'The app does not use the internet and does not request internet access.';

  @override
  String get privacyPointLocal =>
      'Favorites, progress, settings and reminders are stored only on your device, and you can delete them in Settings.';

  @override
  String get privacyPointNotifications =>
      'The notification permission is optional and used only for reminders you turn on.';

  @override
  String get privacyPointSharing =>
      'When you copy or share, the text goes only to the app you choose.';

  @override
  String get privacyPointBackup =>
      'If device backup is turned on, the operating system may include the app\'s settings in your own device backup.';

  @override
  String get onboardingTitle1 => 'Hisn Al-Muslim';

  @override
  String get onboardingBody1 =>
      'Daily adhkar and supplications from the Quran and Sunnah, organised to accompany you through your day.';

  @override
  String get onboardingTitle2 => 'Calm reading, precise counting';

  @override
  String get onboardingBody2 =>
      'Clear Arabic typography, a repetition counter, and your progress saved automatically.';

  @override
  String get onboardingTitle3 => 'Private and offline';

  @override
  String get onboardingBody3 =>
      'No account, no ads, no tracking. Your data stays on your device.';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorContent =>
      'The content could not be loaded. Restart the app; if the problem persists, reinstall it.';

  @override
  String get loading => 'Loading…';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get goHome => 'Go to home';

  @override
  String counterSemantics(int count, int total) {
    return 'Count $count of $total';
  }

  @override
  String get completedSemantics => 'Completed';
}
