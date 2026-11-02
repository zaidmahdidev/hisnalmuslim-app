// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'حصن المسلم';

  @override
  String get appTagline => 'حصّن يومك بذكر الله';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navLibrary => 'الأذكار';

  @override
  String get navTasbeeh => 'المسبحة';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionPrevious => 'السابق';

  @override
  String get actionSkip => 'تخطٍّ';

  @override
  String get actionStart => 'ابدأ';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionDone => 'تم';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionUndo => 'تراجع';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionReset => 'تصفير';

  @override
  String get actionCopy => 'نسخ';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionBack => 'رجوع';

  @override
  String get copied => 'تم نسخ النص';

  @override
  String get addedToFavorites => 'أُضيف إلى المفضلة';

  @override
  String get removedFromFavorites => 'أُزيل من المفضلة';

  @override
  String get addToFavorites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get greetingMorning => 'صباحٌ مبارك';

  @override
  String get greetingDay => 'يومٌ طيّب';

  @override
  String get greetingEvening => 'مساءٌ مبارك';

  @override
  String get greetingNight => 'ليلةٌ هانئة';

  @override
  String get homeTodayWird => 'وِرد اليوم';

  @override
  String homeWirdProgress(int done, int total) {
    return '$done من $total';
  }

  @override
  String homeStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم متتالٍ',
      many: '$count يومًا متتاليًا',
      few: '$count أيام متتالية',
      two: 'يومان متتاليان',
      one: 'يوم واحد متتالٍ',
      zero: 'ابدأ سلسلتك اليوم',
    );
    return '$_temp0';
  }

  @override
  String get homeSuggested => 'مقترح الآن';

  @override
  String get homeDailyDhikr => 'ذكر اليوم';

  @override
  String get homeQuickAccess => 'وصول سريع';

  @override
  String get homeAllCategories => 'جميع الأقسام';

  @override
  String get homeCompletedToday => 'أتممته اليوم';

  @override
  String get searchHint => 'ابحث في الأذكار والأدعية';

  @override
  String get libraryTitle => 'مكتبة الأذكار';

  @override
  String libraryItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ذكر',
      many: '$count ذكرًا',
      few: '$count أذكار',
      two: 'ذكران',
      one: 'ذكر واحد',
      zero: 'لا أذكار',
    );
    return '$_temp0';
  }

  @override
  String get categoryStart => 'ابدأ القراءة';

  @override
  String get categoryContinue => 'تابع القراءة';

  @override
  String get categoryReadAgain => 'اقرأ مجددًا';

  @override
  String get categoryDoneToday => 'أتممت هذا القسم اليوم';

  @override
  String repeatCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة',
      many: '$count مرة',
      few: '$count مرات',
      two: 'مرتان',
      one: 'مرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String readerOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String get readerTapToCount => 'اضغط للعدّ';

  @override
  String get readerDone => 'اكتمل';

  @override
  String get readerRemainingLabel => 'المتبقي';

  @override
  String get readerQuran => 'قرآن كريم';

  @override
  String get readerSunnah => 'من السنة';

  @override
  String get readerReference => 'المصدر والتخريج';

  @override
  String get readerReferenceMissing =>
      'لم يُرفق تخريج هذا الذكر في هذه النسخة بعد.';

  @override
  String get readerBookNote => 'ملاحظة من الكتاب';

  @override
  String get readerFootnoteTitle => 'حاشية الكتاب';

  @override
  String get readerSourceLabel => 'المصدر';

  @override
  String get readerTranslation => 'الترجمة';

  @override
  String get readerTransliteration => 'النطق';

  @override
  String readerTranslationBy(String source) {
    return 'ترجمة: $source';
  }

  @override
  String get readerFontSize => 'حجم الخط';

  @override
  String get readerShowTranslation => 'إظهار الترجمة الإنجليزية';

  @override
  String get readerAutoAdvance => 'الانتقال تلقائيًا بعد الإكمال';

  @override
  String get readerTapText => 'العدّ بالضغط على النص';

  @override
  String get readerResetCount => 'إعادة العدّ';

  @override
  String get readerMarkDone => 'تحديد كمكتمل';

  @override
  String readerCompleteTitle(String category) {
    return 'أتممت $category';
  }

  @override
  String get readerCompleteBody => 'تقبّل الله منا ومنكم صالح الأعمال.';

  @override
  String get readerBackToList => 'العودة إلى القائمة';

  @override
  String get readerStay => 'البقاء هنا';

  @override
  String get readerEmpty => 'لا توجد أذكار هنا.';

  @override
  String get readerDisplayOptions => 'خيارات العرض';

  @override
  String get shareFooter => '— من تطبيق حصن المسلم';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesEmptyTitle => 'لا توجد أذكار مفضلة بعد';

  @override
  String get favoritesEmptyBody =>
      'اضغط على أيقونة القلب في أي ذكر ليُحفظ هنا ويكون في متناولك دائمًا.';

  @override
  String get favoritesSearchHint => 'ابحث في المفضلة';

  @override
  String get favoritesReadAll => 'قراءة الكل';

  @override
  String get favoritesNoMatch => 'لا نتائج مطابقة في المفضلة';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchIntro =>
      'ابحث بكلمة من نص الذكر أو باسم المناسبة، ولا حاجة لكتابة التشكيل.';

  @override
  String get searchSuggestions => 'اقتراحات';

  @override
  String searchNoResults(String query) {
    return 'لا نتائج لـ «$query»';
  }

  @override
  String get searchNoResultsHint => 'جرّب كلمة أخرى أو جزءًا من الكلمة.';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get searchClear => 'مسح';

  @override
  String get tasbeehTitle => 'المسبحة';

  @override
  String get tasbeehTapHint => 'اضغط على الدائرة للتسبيح';

  @override
  String get tasbeehTarget => 'الهدف';

  @override
  String get tasbeehUnlimited => 'بلا حد';

  @override
  String get tasbeehRounds => 'الدورات';

  @override
  String get tasbeehToday => 'اليوم';

  @override
  String get tasbeehTotal => 'الإجمالي';

  @override
  String get tasbeehChoose => 'اختر الذكر';

  @override
  String get tasbeehAddCustom => 'إضافة ذكر خاص';

  @override
  String get tasbeehCustomHint => 'اكتب الذكر';

  @override
  String get tasbeehCustomTarget => 'عدد التكرار';

  @override
  String get tasbeehResetTitle => 'تصفير العداد؟';

  @override
  String get tasbeehResetBody =>
      'سيعود العدّ الحالي والدورات إلى الصفر، وتبقى الإحصائيات محفوظة.';

  @override
  String get tasbeehRoundDone => 'اكتملت الدورة';

  @override
  String get tasbeehSound => 'الصوت';

  @override
  String get tasbeehHaptics => 'الاهتزاز';

  @override
  String get tasbeehDeleteCustom => 'حذف هذا الذكر';

  @override
  String tasbeehCountSemantics(int count) {
    return 'العدد $count';
  }

  @override
  String tasbeehStatsFor(int count) {
    return 'إحصائيات هذا الذكر: $count';
  }

  @override
  String get remindersTitle => 'التذكيرات';

  @override
  String get remindersIntro =>
      'تذكيرات يومية اختيارية تصلك في الوقت الذي تختاره.';

  @override
  String get reminderMorning => 'أذكار الصباح';

  @override
  String get reminderEvening => 'أذكار المساء';

  @override
  String get reminderSleep => 'أذكار النوم';

  @override
  String get reminderCustomSection => 'تذكيرات خاصة';

  @override
  String get reminderAdd => 'إضافة تذكير';

  @override
  String get reminderTitleHint => 'عنوان التذكير (مثال: ورد القرآن)';

  @override
  String get reminderTime => 'الوقت';

  @override
  String get reminderMorningBody =>
      'حان وقت أذكار الصباح، حصّن يومك بذكر الله.';

  @override
  String get reminderEveningBody => 'حان وقت أذكار المساء.';

  @override
  String get reminderSleepBody => 'لا تنسَ أذكار النوم قبل أن تنام.';

  @override
  String get reminderCustomBody => 'تذكير من حصن المسلم';

  @override
  String get reminderChannelName => 'تذكيرات الأذكار';

  @override
  String get reminderChannelDescription =>
      'تذكيرات يومية يختارها المستخدم لقراءة الأذكار';

  @override
  String get reminderPermissionTitle => 'السماح بالإشعارات';

  @override
  String get reminderPermissionBody =>
      'نستخدم الإشعارات فقط لتذكيرك بالأذكار في الأوقات التي تحددها أنت. لا إعلانات ولا رسائل أخرى، ويمكنك إيقافها متى شئت.';

  @override
  String get reminderPermissionDenied =>
      'الإشعارات غير مفعّلة لهذا التطبيق. فعّلها من إعدادات الجهاز لتصلك التذكيرات.';

  @override
  String get reminderNotNow => 'ليس الآن';

  @override
  String get reminderDelete => 'حذف التذكير';

  @override
  String get reminderInexactNote =>
      'قد يتأخر التذكير دقائق قليلة حفاظًا على البطارية.';

  @override
  String get reminderExactTitle => 'توقيت دقيق للتذكيرات';

  @override
  String get reminderExactBody =>
      'قد يؤخّر النظام التذكيرات لتوفير البطارية. اسمح بـ«المنبّهات والتذكيرات» ليصلك التذكير في وقته.';

  @override
  String get reminderExactAction => 'السماح';

  @override
  String get reminderLimitReached => 'وصلت إلى الحد الأقصى للتذكيرات الخاصة.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsReading => 'القراءة';

  @override
  String get settingsFontSize => 'حجم خط الأذكار';

  @override
  String get settingsFeedback => 'التفاعل';

  @override
  String get settingsHaptics => 'الاهتزاز عند العدّ';

  @override
  String get settingsSound => 'صوت النقر';

  @override
  String get settingsSoundHint => 'يتبع إعداد أصوات اللمس في جهازك';

  @override
  String get settingsReminders => 'التذكيرات';

  @override
  String get settingsRemindersSubtitle => 'تذكيرات الصباح والمساء والنوم';

  @override
  String get settingsData => 'البيانات';

  @override
  String get settingsResetProgress => 'إعادة ضبط تقدّم القراءة';

  @override
  String get settingsResetProgressBody =>
      'سيُمسح عدّاد اليوم وسجل الإنجاز. لا يمكن التراجع عن ذلك.';

  @override
  String get settingsProgressReset => 'تمت إعادة ضبط التقدّم';

  @override
  String get settingsClearData => 'مسح جميع بيانات التطبيق';

  @override
  String get settingsClearDataBody =>
      'ستُحذف المفضلة والتقدّم وإحصائيات المسبحة والتذكيرات والإعدادات من هذا الجهاز.';

  @override
  String get settingsAbout => 'عن التطبيق';

  @override
  String get settingsSources => 'مصادر المحتوى';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsShareApp => 'مشاركة التطبيق';

  @override
  String settingsShareMessage(String url) {
    return 'حصن المسلم — أذكار وأدعية من الكتاب والسنة، تعمل دون إنترنت:\n$url';
  }

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsLicenses => 'تراخيص البرمجيات والخطوط';

  @override
  String get settingsContact => 'تواصل معنا';

  @override
  String get aboutBody =>
      'يجمع «حصن المسلم» أذكار اليوم والليلة والأدعية من كتاب «حصن المسلم من أذكار الكتاب والسنة» للشيخ سعيد بن علي بن وهف القحطاني، مع أدعية من القرآن الكريم، في تجربة هادئة تعمل بالكامل دون إنترنت.';

  @override
  String get aboutPrinciples => 'مبادئنا';

  @override
  String get aboutPrincipleOffline => 'يعمل دون إنترنت';

  @override
  String get aboutPrincipleNoAds => 'بلا إعلانات ولا تتبّع';

  @override
  String get aboutPrincipleNoAccount => 'بلا حساب أو تسجيل';

  @override
  String get aboutContentNoticeTitle => 'عن دقة المحتوى';

  @override
  String get aboutContentNotice =>
      'نُقلت النصوص حرفيًا من المصادر المذكورة وطوبقت آليًا مع حواشي الكتاب، ولم تُراجَع بعدُ من قِبل مختص شرعي. إن لاحظت خطأً فنرجو إبلاغنا.';

  @override
  String get sourcesTitle => 'مصادر المحتوى';

  @override
  String get sourcesHisnTitle => 'كتاب حصن المسلم';

  @override
  String get sourcesHisnBody =>
      'نص الأذكار وعدد التكرار والترجمة الإنجليزية من الموقع الرسمي للكتاب hisnmuslim.com.';

  @override
  String get sourcesFootnotesTitle => 'حواشي الكتاب';

  @override
  String get sourcesFootnotesBody =>
      'التخريج والفضل من نسخة نصية لحواشي الكتاب، وتُرفق بالذكر فقط عند تطابقها بوضوح.';

  @override
  String get sourcesEveningTitle => 'صيغ المساء';

  @override
  String get sourcesEveningBody =>
      'يكتفي الكتاب بالتنبيه على صيغة المساء؛ وتُعرض الصيغة الكاملة فقط إذا طابقت تنبيه الكتاب.';

  @override
  String get sourcesQuranTitle => 'الآيات القرآنية';

  @override
  String get sourcesQuranBody =>
      'نص الآيات من مصحف تنزيل (tanzil.net) بالرسم الإملائي، والترجمة الإنجليزية: Saheeh International.';

  @override
  String sourcesVersion(int version, int count) {
    return 'نسخة المحتوى $version · $count ذكرًا';
  }

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyIntro =>
      'لا يجمع «حصن المسلم» أي بيانات شخصية، ولا يرسل أي بيانات إلى أي جهة.';

  @override
  String get privacyPointAccount => 'لا يتطلب حسابًا أو تسجيل دخول.';

  @override
  String get privacyPointAds => 'لا يحتوي على إعلانات أو أدوات تحليل أو تتبّع.';

  @override
  String get privacyPointInternet =>
      'لا يستخدم الإنترنت ولا يطلب إذن الوصول إليه.';

  @override
  String get privacyPointLocal =>
      'تُحفظ المفضلة والتقدّم والإعدادات والتذكيرات على جهازك فقط، ويمكنك حذفها من الإعدادات.';

  @override
  String get privacyPointNotifications =>
      'إذن الإشعارات اختياري ويُستخدم فقط للتذكيرات التي تفعّلها بنفسك.';

  @override
  String get privacyPointSharing =>
      'عند النسخ أو المشاركة يُرسل النص إلى التطبيق الذي تختاره أنت فقط.';

  @override
  String get privacyPointBackup =>
      'إذا كان النسخ الاحتياطي لجهازك مفعّلًا، فقد يحتفظ نظام التشغيل بنسخة من إعدادات التطبيق ضمن نسختك الاحتياطية الخاصة.';

  @override
  String get onboardingTitle1 => 'حصن المسلم';

  @override
  String get onboardingBody1 =>
      'أذكار اليوم والليلة وأدعية من الكتاب والسنة، مرتّبة لتصحبك في كل أحوالك.';

  @override
  String get onboardingTitle2 => 'قراءة مريحة وعدّاد دقيق';

  @override
  String get onboardingBody2 =>
      'خط عربي واضح، وعدّاد للتكرار، ويُحفظ تقدّمك تلقائيًا.';

  @override
  String get onboardingTitle3 => 'لك وحدك، دون إنترنت';

  @override
  String get onboardingBody3 =>
      'لا حساب ولا إعلانات ولا تتبّع. كل بياناتك تبقى على جهازك.';

  @override
  String get errorTitle => 'حدث خطأ غير متوقع';

  @override
  String get errorContent =>
      'تعذّر تحميل المحتوى. أعد تشغيل التطبيق، وإن استمرت المشكلة فأعد تثبيته.';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get goHome => 'العودة إلى الرئيسية';

  @override
  String counterSemantics(int count, int total) {
    return 'العدد $count من $total';
  }

  @override
  String get completedSemantics => 'مكتمل';
}
