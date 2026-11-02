import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import '../core/storage/key_value_store.dart';
import '../core/widgets/state_views.dart';
import '../data/datasources/content_asset_source.dart';
import '../data/repositories/content_repository.dart';
import 'app.dart';
import 'localization/gen/app_localizations.dart';
import 'providers.dart';
import 'theme/app_theme.dart';

/// Loads everything the first frame needs (settings store and the content
/// database) while the native splash is still visible, then starts the app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(_fontLicenses);

  try {
    final (store, bundle) = await (
      PrefsKeyValueStore.create(),
      const ContentAssetSource().load(),
    ).wait;
    runApp(
      ProviderScope(
        overrides: [
          keyValueStoreProvider.overrideWithValue(store),
          contentRepositoryProvider.overrideWithValue(ContentRepository(bundle)),
          reminderSchedulerProvider.overrideWithValue(LocalNotificationService()),
        ],
        child: const HisnApp(),
      ),
    );
  } on Object catch (error, stack) {
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack));
    runApp(const _StartupErrorApp());
  }
}

Stream<LicenseEntry> _fontLicenses() async* {
  for (final (font, file) in [
    ('Amiri', 'OFL-Amiri.txt'),
    ('Amiri Quran', 'OFL-AmiriQuran.txt'),
    ('IBM Plex Sans Arabic', 'OFL-IBMPlexSansArabic.txt'),
  ]) {
    yield LicenseEntryWithLineBreaks([font], await rootBundle.loadString('assets/fonts/$file'));
  }
}

/// Shown only if the bundled content cannot be read (e.g. a corrupt install).
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          return Scaffold(
            body: ErrorView(
              title: l10n.errorTitle,
              message: l10n.errorContent,
              retryLabel: l10n.actionRetry,
              onRetry: bootstrap,
            ),
          );
        },
      ),
    );
  }
}
