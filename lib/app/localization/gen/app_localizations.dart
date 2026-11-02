import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'حصن المسلم'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'حصّن يومك بذكر الله'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get navLibrary;

  /// No description provided for @navTasbeeh.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة'**
  String get navTasbeeh;

  /// No description provided for @navFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @actionNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get actionPrevious;

  /// No description provided for @actionSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطٍّ'**
  String get actionSkip;

  /// No description provided for @actionStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get actionStart;

  /// No description provided for @actionCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get actionDelete;

  /// No description provided for @actionDone.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get actionRetry;

  /// No description provided for @actionUndo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get actionUndo;

  /// No description provided for @actionClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get actionClose;

  /// No description provided for @actionSeeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get actionSeeAll;

  /// No description provided for @actionConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get actionConfirm;

  /// No description provided for @actionReset.
  ///
  /// In ar, this message translates to:
  /// **'تصفير'**
  String get actionReset;

  /// No description provided for @actionCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get actionCopy;

  /// No description provided for @actionShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get actionShare;

  /// No description provided for @actionSearch.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get actionSearch;

  /// No description provided for @actionBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get actionBack;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ النص'**
  String get copied;

  /// No description provided for @addedToFavorites.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف إلى المفضلة'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'أُزيل من المفضلة'**
  String get removedFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى المفضلة'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFromFavorites;

  /// No description provided for @greetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباحٌ مبارك'**
  String get greetingMorning;

  /// No description provided for @greetingDay.
  ///
  /// In ar, this message translates to:
  /// **'يومٌ طيّب'**
  String get greetingDay;

  /// No description provided for @greetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساءٌ مبارك'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In ar, this message translates to:
  /// **'ليلةٌ هانئة'**
  String get greetingNight;

  /// No description provided for @homeTodayWird.
  ///
  /// In ar, this message translates to:
  /// **'وِرد اليوم'**
  String get homeTodayWird;

  /// No description provided for @homeWirdProgress.
  ///
  /// In ar, this message translates to:
  /// **'{done} من {total}'**
  String homeWirdProgress(int done, int total);

  /// No description provided for @homeStreak.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{ابدأ سلسلتك اليوم} =1{يوم واحد متتالٍ} =2{يومان متتاليان} few{{count} أيام متتالية} many{{count} يومًا متتاليًا} other{{count} يوم متتالٍ}}'**
  String homeStreak(int count);

  /// No description provided for @homeSuggested.
  ///
  /// In ar, this message translates to:
  /// **'مقترح الآن'**
  String get homeSuggested;

  /// No description provided for @homeDailyDhikr.
  ///
  /// In ar, this message translates to:
  /// **'ذكر اليوم'**
  String get homeDailyDhikr;

  /// No description provided for @homeQuickAccess.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع'**
  String get homeQuickAccess;

  /// No description provided for @homeAllCategories.
  ///
  /// In ar, this message translates to:
  /// **'جميع الأقسام'**
  String get homeAllCategories;

  /// No description provided for @homeCompletedToday.
  ///
  /// In ar, this message translates to:
  /// **'أتممته اليوم'**
  String get homeCompletedToday;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في الأذكار والأدعية'**
  String get searchHint;

  /// No description provided for @libraryTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الأذكار'**
  String get libraryTitle;

  /// No description provided for @libraryItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا أذكار} =1{ذكر واحد} =2{ذكران} few{{count} أذكار} many{{count} ذكرًا} other{{count} ذكر}}'**
  String libraryItemsCount(int count);

  /// No description provided for @categoryStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ القراءة'**
  String get categoryStart;

  /// No description provided for @categoryContinue.
  ///
  /// In ar, this message translates to:
  /// **'تابع القراءة'**
  String get categoryContinue;

  /// No description provided for @categoryReadAgain.
  ///
  /// In ar, this message translates to:
  /// **'اقرأ مجددًا'**
  String get categoryReadAgain;

  /// No description provided for @categoryDoneToday.
  ///
  /// In ar, this message translates to:
  /// **'أتممت هذا القسم اليوم'**
  String get categoryDoneToday;

  /// No description provided for @repeatCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مرة واحدة} =2{مرتان} few{{count} مرات} many{{count} مرة} other{{count} مرة}}'**
  String repeatCount(int count);

  /// No description provided for @readerOf.
  ///
  /// In ar, this message translates to:
  /// **'{current} من {total}'**
  String readerOf(int current, int total);

  /// No description provided for @readerTapToCount.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للعدّ'**
  String get readerTapToCount;

  /// No description provided for @readerDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل'**
  String get readerDone;

  /// No description provided for @readerRemainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get readerRemainingLabel;

  /// No description provided for @readerQuran.
  ///
  /// In ar, this message translates to:
  /// **'قرآن كريم'**
  String get readerQuran;

  /// No description provided for @readerSunnah.
  ///
  /// In ar, this message translates to:
  /// **'من السنة'**
  String get readerSunnah;

  /// No description provided for @readerReference.
  ///
  /// In ar, this message translates to:
  /// **'المصدر والتخريج'**
  String get readerReference;

  /// No description provided for @readerReferenceMissing.
  ///
  /// In ar, this message translates to:
  /// **'لم يُرفق تخريج هذا الذكر في هذه النسخة بعد.'**
  String get readerReferenceMissing;

  /// No description provided for @readerBookNote.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة من الكتاب'**
  String get readerBookNote;

  /// No description provided for @readerFootnoteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حاشية الكتاب'**
  String get readerFootnoteTitle;

  /// No description provided for @readerSourceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المصدر'**
  String get readerSourceLabel;

  /// No description provided for @readerTranslation.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get readerTranslation;

  /// No description provided for @readerTransliteration.
  ///
  /// In ar, this message translates to:
  /// **'النطق'**
  String get readerTransliteration;

  /// No description provided for @readerTranslationBy.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة: {source}'**
  String readerTranslationBy(String source);

  /// No description provided for @readerFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get readerFontSize;

  /// No description provided for @readerShowTranslation.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الترجمة الإنجليزية'**
  String get readerShowTranslation;

  /// No description provided for @readerAutoAdvance.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال تلقائيًا بعد الإكمال'**
  String get readerAutoAdvance;

  /// No description provided for @readerTapText.
  ///
  /// In ar, this message translates to:
  /// **'العدّ بالضغط على النص'**
  String get readerTapText;

  /// No description provided for @readerResetCount.
  ///
  /// In ar, this message translates to:
  /// **'إعادة العدّ'**
  String get readerResetCount;

  /// No description provided for @readerMarkDone.
  ///
  /// In ar, this message translates to:
  /// **'تحديد كمكتمل'**
  String get readerMarkDone;

  /// No description provided for @readerCompleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'أتممت {category}'**
  String readerCompleteTitle(String category);

  /// No description provided for @readerCompleteBody.
  ///
  /// In ar, this message translates to:
  /// **'تقبّل الله منا ومنكم صالح الأعمال.'**
  String get readerCompleteBody;

  /// No description provided for @readerBackToList.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى القائمة'**
  String get readerBackToList;

  /// No description provided for @readerStay.
  ///
  /// In ar, this message translates to:
  /// **'البقاء هنا'**
  String get readerStay;

  /// No description provided for @readerEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أذكار هنا.'**
  String get readerEmpty;

  /// No description provided for @readerDisplayOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات العرض'**
  String get readerDisplayOptions;

  /// No description provided for @shareFooter.
  ///
  /// In ar, this message translates to:
  /// **'— من تطبيق حصن المسلم'**
  String get shareFooter;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أذكار مفضلة بعد'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أيقونة القلب في أي ذكر ليُحفظ هنا ويكون في متناولك دائمًا.'**
  String get favoritesEmptyBody;

  /// No description provided for @favoritesSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في المفضلة'**
  String get favoritesSearchHint;

  /// No description provided for @favoritesReadAll.
  ///
  /// In ar, this message translates to:
  /// **'قراءة الكل'**
  String get favoritesReadAll;

  /// No description provided for @favoritesNoMatch.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج مطابقة في المفضلة'**
  String get favoritesNoMatch;

  /// No description provided for @searchTitle.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get searchTitle;

  /// No description provided for @searchIntro.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بكلمة من نص الذكر أو باسم المناسبة، ولا حاجة لكتابة التشكيل.'**
  String get searchIntro;

  /// No description provided for @searchSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات'**
  String get searchSuggestions;

  /// No description provided for @searchNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا نتائج لـ «{query}»'**
  String searchNoResults(String query);

  /// No description provided for @searchNoResultsHint.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة أخرى أو جزءًا من الكلمة.'**
  String get searchNoResultsHint;

  /// No description provided for @searchResultsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا نتائج} =1{نتيجة واحدة} =2{نتيجتان} few{{count} نتائج} many{{count} نتيجة} other{{count} نتيجة}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchClear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get searchClear;

  /// No description provided for @tasbeehTitle.
  ///
  /// In ar, this message translates to:
  /// **'المسبحة'**
  String get tasbeehTitle;

  /// No description provided for @tasbeehTapHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الدائرة للتسبيح'**
  String get tasbeehTapHint;

  /// No description provided for @tasbeehTarget.
  ///
  /// In ar, this message translates to:
  /// **'الهدف'**
  String get tasbeehTarget;

  /// No description provided for @tasbeehUnlimited.
  ///
  /// In ar, this message translates to:
  /// **'بلا حد'**
  String get tasbeehUnlimited;

  /// No description provided for @tasbeehRounds.
  ///
  /// In ar, this message translates to:
  /// **'الدورات'**
  String get tasbeehRounds;

  /// No description provided for @tasbeehToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get tasbeehToday;

  /// No description provided for @tasbeehTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get tasbeehTotal;

  /// No description provided for @tasbeehChoose.
  ///
  /// In ar, this message translates to:
  /// **'اختر الذكر'**
  String get tasbeehChoose;

  /// No description provided for @tasbeehAddCustom.
  ///
  /// In ar, this message translates to:
  /// **'إضافة ذكر خاص'**
  String get tasbeehAddCustom;

  /// No description provided for @tasbeehCustomHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الذكر'**
  String get tasbeehCustomHint;

  /// No description provided for @tasbeehCustomTarget.
  ///
  /// In ar, this message translates to:
  /// **'عدد التكرار'**
  String get tasbeehCustomTarget;

  /// No description provided for @tasbeehResetTitle.
  ///
  /// In ar, this message translates to:
  /// **'تصفير العداد؟'**
  String get tasbeehResetTitle;

  /// No description provided for @tasbeehResetBody.
  ///
  /// In ar, this message translates to:
  /// **'سيعود العدّ الحالي والدورات إلى الصفر، وتبقى الإحصائيات محفوظة.'**
  String get tasbeehResetBody;

  /// No description provided for @tasbeehRoundDone.
  ///
  /// In ar, this message translates to:
  /// **'اكتملت الدورة'**
  String get tasbeehRoundDone;

  /// No description provided for @tasbeehSound.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get tasbeehSound;

  /// No description provided for @tasbeehHaptics.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز'**
  String get tasbeehHaptics;

  /// No description provided for @tasbeehDeleteCustom.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا الذكر'**
  String get tasbeehDeleteCustom;

  /// No description provided for @tasbeehCountSemantics.
  ///
  /// In ar, this message translates to:
  /// **'العدد {count}'**
  String tasbeehCountSemantics(int count);

  /// No description provided for @tasbeehStatsFor.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات هذا الذكر: {count}'**
  String tasbeehStatsFor(int count);

  /// No description provided for @remindersTitle.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get remindersTitle;

  /// No description provided for @remindersIntro.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات يومية اختيارية تصلك في الوقت الذي تختاره.'**
  String get remindersIntro;

  /// No description provided for @reminderMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get reminderMorning;

  /// No description provided for @reminderEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get reminderEvening;

  /// No description provided for @reminderSleep.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get reminderSleep;

  /// No description provided for @reminderCustomSection.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات خاصة'**
  String get reminderCustomSection;

  /// No description provided for @reminderAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة تذكير'**
  String get reminderAdd;

  /// No description provided for @reminderTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التذكير (مثال: ورد القرآن)'**
  String get reminderTitleHint;

  /// No description provided for @reminderTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get reminderTime;

  /// No description provided for @reminderMorningBody.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت أذكار الصباح، حصّن يومك بذكر الله.'**
  String get reminderMorningBody;

  /// No description provided for @reminderEveningBody.
  ///
  /// In ar, this message translates to:
  /// **'حان وقت أذكار المساء.'**
  String get reminderEveningBody;

  /// No description provided for @reminderSleepBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تنسَ أذكار النوم قبل أن تنام.'**
  String get reminderSleepBody;

  /// No description provided for @reminderCustomBody.
  ///
  /// In ar, this message translates to:
  /// **'تذكير من حصن المسلم'**
  String get reminderCustomBody;

  /// No description provided for @reminderChannelName.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الأذكار'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات يومية يختارها المستخدم لقراءة الأذكار'**
  String get reminderChannelDescription;

  /// No description provided for @reminderPermissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالإشعارات'**
  String get reminderPermissionTitle;

  /// No description provided for @reminderPermissionBody.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم الإشعارات فقط لتذكيرك بالأذكار في الأوقات التي تحددها أنت. لا إعلانات ولا رسائل أخرى، ويمكنك إيقافها متى شئت.'**
  String get reminderPermissionBody;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات غير مفعّلة لهذا التطبيق. فعّلها من إعدادات الجهاز لتصلك التذكيرات.'**
  String get reminderPermissionDenied;

  /// No description provided for @reminderNotNow.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get reminderNotNow;

  /// No description provided for @reminderDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف التذكير'**
  String get reminderDelete;

  /// No description provided for @reminderInexactNote.
  ///
  /// In ar, this message translates to:
  /// **'قد يتأخر التذكير دقائق قليلة حفاظًا على البطارية.'**
  String get reminderInexactNote;

  /// No description provided for @reminderExactTitle.
  ///
  /// In ar, this message translates to:
  /// **'توقيت دقيق للتذكيرات'**
  String get reminderExactTitle;

  /// No description provided for @reminderExactBody.
  ///
  /// In ar, this message translates to:
  /// **'قد يؤخّر النظام التذكيرات لتوفير البطارية. اسمح بـ«المنبّهات والتذكيرات» ليصلك التذكير في وقته.'**
  String get reminderExactBody;

  /// No description provided for @reminderExactAction.
  ///
  /// In ar, this message translates to:
  /// **'السماح'**
  String get reminderExactAction;

  /// No description provided for @reminderLimitReached.
  ///
  /// In ar, this message translates to:
  /// **'وصلت إلى الحد الأقصى للتذكيرات الخاصة.'**
  String get reminderLimitReached;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'السمة'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsReading.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get settingsReading;

  /// No description provided for @settingsFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم خط الأذكار'**
  String get settingsFontSize;

  /// No description provided for @settingsFeedback.
  ///
  /// In ar, this message translates to:
  /// **'التفاعل'**
  String get settingsFeedback;

  /// No description provided for @settingsHaptics.
  ///
  /// In ar, this message translates to:
  /// **'الاهتزاز عند العدّ'**
  String get settingsHaptics;

  /// No description provided for @settingsSound.
  ///
  /// In ar, this message translates to:
  /// **'صوت النقر'**
  String get settingsSound;

  /// No description provided for @settingsSoundHint.
  ///
  /// In ar, this message translates to:
  /// **'يتبع إعداد أصوات اللمس في جهازك'**
  String get settingsSoundHint;

  /// No description provided for @settingsReminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الصباح والمساء والنوم'**
  String get settingsRemindersSubtitle;

  /// No description provided for @settingsData.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get settingsData;

  /// No description provided for @settingsResetProgress.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط تقدّم القراءة'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetProgressBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُمسح عدّاد اليوم وسجل الإنجاز. لا يمكن التراجع عن ذلك.'**
  String get settingsResetProgressBody;

  /// No description provided for @settingsProgressReset.
  ///
  /// In ar, this message translates to:
  /// **'تمت إعادة ضبط التقدّم'**
  String get settingsProgressReset;

  /// No description provided for @settingsClearData.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع بيانات التطبيق'**
  String get settingsClearData;

  /// No description provided for @settingsClearDataBody.
  ///
  /// In ar, this message translates to:
  /// **'ستُحذف المفضلة والتقدّم وإحصائيات المسبحة والتذكيرات والإعدادات من هذا الجهاز.'**
  String get settingsClearDataBody;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get settingsAbout;

  /// No description provided for @settingsSources.
  ///
  /// In ar, this message translates to:
  /// **'مصادر المحتوى'**
  String get settingsSources;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settingsPrivacy;

  /// No description provided for @settingsShareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get settingsShareApp;

  /// No description provided for @settingsShareMessage.
  ///
  /// In ar, this message translates to:
  /// **'حصن المسلم — أذكار وأدعية من الكتاب والسنة، تعمل دون إنترنت:\n{url}'**
  String settingsShareMessage(String url);

  /// No description provided for @settingsVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsLicenses.
  ///
  /// In ar, this message translates to:
  /// **'تراخيص البرمجيات والخطوط'**
  String get settingsLicenses;

  /// No description provided for @settingsContact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get settingsContact;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'يجمع «حصن المسلم» أذكار اليوم والليلة والأدعية من كتاب «حصن المسلم من أذكار الكتاب والسنة» للشيخ سعيد بن علي بن وهف القحطاني، مع أدعية من القرآن الكريم، في تجربة هادئة تعمل بالكامل دون إنترنت.'**
  String get aboutBody;

  /// No description provided for @aboutPrinciples.
  ///
  /// In ar, this message translates to:
  /// **'مبادئنا'**
  String get aboutPrinciples;

  /// No description provided for @aboutPrincipleOffline.
  ///
  /// In ar, this message translates to:
  /// **'يعمل دون إنترنت'**
  String get aboutPrincipleOffline;

  /// No description provided for @aboutPrincipleNoAds.
  ///
  /// In ar, this message translates to:
  /// **'بلا إعلانات ولا تتبّع'**
  String get aboutPrincipleNoAds;

  /// No description provided for @aboutPrincipleNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'بلا حساب أو تسجيل'**
  String get aboutPrincipleNoAccount;

  /// No description provided for @aboutContentNoticeTitle.
  ///
  /// In ar, this message translates to:
  /// **'عن دقة المحتوى'**
  String get aboutContentNoticeTitle;

  /// No description provided for @aboutContentNotice.
  ///
  /// In ar, this message translates to:
  /// **'نُقلت النصوص حرفيًا من المصادر المذكورة وطوبقت آليًا مع حواشي الكتاب، ولم تُراجَع بعدُ من قِبل مختص شرعي. إن لاحظت خطأً فنرجو إبلاغنا.'**
  String get aboutContentNotice;

  /// No description provided for @sourcesTitle.
  ///
  /// In ar, this message translates to:
  /// **'مصادر المحتوى'**
  String get sourcesTitle;

  /// No description provided for @sourcesHisnTitle.
  ///
  /// In ar, this message translates to:
  /// **'كتاب حصن المسلم'**
  String get sourcesHisnTitle;

  /// No description provided for @sourcesHisnBody.
  ///
  /// In ar, this message translates to:
  /// **'نص الأذكار وعدد التكرار والترجمة الإنجليزية من الموقع الرسمي للكتاب hisnmuslim.com.'**
  String get sourcesHisnBody;

  /// No description provided for @sourcesFootnotesTitle.
  ///
  /// In ar, this message translates to:
  /// **'حواشي الكتاب'**
  String get sourcesFootnotesTitle;

  /// No description provided for @sourcesFootnotesBody.
  ///
  /// In ar, this message translates to:
  /// **'التخريج والفضل من نسخة نصية لحواشي الكتاب، وتُرفق بالذكر فقط عند تطابقها بوضوح.'**
  String get sourcesFootnotesBody;

  /// No description provided for @sourcesEveningTitle.
  ///
  /// In ar, this message translates to:
  /// **'صيغ المساء'**
  String get sourcesEveningTitle;

  /// No description provided for @sourcesEveningBody.
  ///
  /// In ar, this message translates to:
  /// **'يكتفي الكتاب بالتنبيه على صيغة المساء؛ وتُعرض الصيغة الكاملة فقط إذا طابقت تنبيه الكتاب.'**
  String get sourcesEveningBody;

  /// No description provided for @sourcesQuranTitle.
  ///
  /// In ar, this message translates to:
  /// **'الآيات القرآنية'**
  String get sourcesQuranTitle;

  /// No description provided for @sourcesQuranBody.
  ///
  /// In ar, this message translates to:
  /// **'نص الآيات من مصحف تنزيل (tanzil.net) بالرسم الإملائي، والترجمة الإنجليزية: Saheeh International.'**
  String get sourcesQuranBody;

  /// No description provided for @sourcesVersion.
  ///
  /// In ar, this message translates to:
  /// **'نسخة المحتوى {version} · {count} ذكرًا'**
  String sourcesVersion(int version, int count);

  /// No description provided for @privacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyTitle;

  /// No description provided for @privacyIntro.
  ///
  /// In ar, this message translates to:
  /// **'لا يجمع «حصن المسلم» أي بيانات شخصية، ولا يرسل أي بيانات إلى أي جهة.'**
  String get privacyIntro;

  /// No description provided for @privacyPointAccount.
  ///
  /// In ar, this message translates to:
  /// **'لا يتطلب حسابًا أو تسجيل دخول.'**
  String get privacyPointAccount;

  /// No description provided for @privacyPointAds.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتوي على إعلانات أو أدوات تحليل أو تتبّع.'**
  String get privacyPointAds;

  /// No description provided for @privacyPointInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يستخدم الإنترنت ولا يطلب إذن الوصول إليه.'**
  String get privacyPointInternet;

  /// No description provided for @privacyPointLocal.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ المفضلة والتقدّم والإعدادات والتذكيرات على جهازك فقط، ويمكنك حذفها من الإعدادات.'**
  String get privacyPointLocal;

  /// No description provided for @privacyPointNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إذن الإشعارات اختياري ويُستخدم فقط للتذكيرات التي تفعّلها بنفسك.'**
  String get privacyPointNotifications;

  /// No description provided for @privacyPointSharing.
  ///
  /// In ar, this message translates to:
  /// **'عند النسخ أو المشاركة يُرسل النص إلى التطبيق الذي تختاره أنت فقط.'**
  String get privacyPointSharing;

  /// No description provided for @privacyPointBackup.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان النسخ الاحتياطي لجهازك مفعّلًا، فقد يحتفظ نظام التشغيل بنسخة من إعدادات التطبيق ضمن نسختك الاحتياطية الخاصة.'**
  String get privacyPointBackup;

  /// No description provided for @onboardingTitle1.
  ///
  /// In ar, this message translates to:
  /// **'حصن المسلم'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In ar, this message translates to:
  /// **'أذكار اليوم والليلة وأدعية من الكتاب والسنة، مرتّبة لتصحبك في كل أحوالك.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In ar, this message translates to:
  /// **'قراءة مريحة وعدّاد دقيق'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In ar, this message translates to:
  /// **'خط عربي واضح، وعدّاد للتكرار، ويُحفظ تقدّمك تلقائيًا.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In ar, this message translates to:
  /// **'لك وحدك، دون إنترنت'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In ar, this message translates to:
  /// **'لا حساب ولا إعلانات ولا تتبّع. كل بياناتك تبقى على جهازك.'**
  String get onboardingBody3;

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorTitle;

  /// No description provided for @errorContent.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل المحتوى. أعد تشغيل التطبيق، وإن استمرت المشكلة فأعد تثبيته.'**
  String get errorContent;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل…'**
  String get loading;

  /// No description provided for @notFoundTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get notFoundTitle;

  /// No description provided for @goHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى الرئيسية'**
  String get goHome;

  /// No description provided for @counterSemantics.
  ///
  /// In ar, this message translates to:
  /// **'العدد {count} من {total}'**
  String counterSemantics(int count, int total);

  /// No description provided for @completedSemantics.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get completedSemantics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
