import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/section_header.dart';
import '../application/data_management.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAbout)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.gutter),
          children: [
            const Center(child: BrandMark(size: 96)),
            const SizedBox(height: AppSpace.md),
            Center(
              child: Text(
                l10n.appName,
                style: TextStyle(
                  fontFamily: AppFonts.reading,
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: p.textPrimary,
                ),
              ),
            ),
            if (version != null)
              Center(child: Text(l10n.settingsVersion(version), style: text.bodySmall)),
            const SizedBox(height: AppSpace.xl),
            Text(l10n.aboutBody, style: text.bodyLarge),
            const SizedBox(height: AppSpace.xl),
            SectionHeader(title: l10n.aboutPrinciples),
            AppCard(
              elevated: false,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _Principle(icon: Icons.wifi_off_rounded, label: l10n.aboutPrincipleOffline),
                  _Principle(icon: Icons.block_rounded, label: l10n.aboutPrincipleNoAds),
                  _Principle(icon: Icons.person_off_rounded, label: l10n.aboutPrincipleNoAccount),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.xl),
            _Notice(title: l10n.aboutContentNoticeTitle, body: l10n.aboutContentNotice),
            if (AppInfo.supportEmail.isNotEmpty) ...[
              const SizedBox(height: AppSpace.lg),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded),
                title: Text(l10n.settingsContact),
                subtitle: const SelectableText(AppInfo.supportEmail),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final points = [
      (Icons.person_off_rounded, l10n.privacyPointAccount),
      (Icons.block_rounded, l10n.privacyPointAds),
      (Icons.wifi_off_rounded, l10n.privacyPointInternet),
      (Icons.phone_android_rounded, l10n.privacyPointLocal),
      (Icons.notifications_none_rounded, l10n.privacyPointNotifications),
      (Icons.ios_share_rounded, l10n.privacyPointSharing),
      (Icons.backup_outlined, l10n.privacyPointBackup),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.gutter),
          children: [
            Text(l10n.privacyIntro, style: text.titleMedium),
            const SizedBox(height: AppSpace.lg),
            AppCard(
              elevated: false,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final (icon, label) in points) _Principle(icon: icon, label: label),
                ],
              ),
            ),
            if (AppInfo.supportEmail.isNotEmpty) ...[
              const SizedBox(height: AppSpace.lg),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded),
                title: Text(l10n.settingsContact),
                subtitle: const SelectableText(AppInfo.supportEmail),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SourcesScreen extends ConsumerWidget {
  const SourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(contentRepositoryProvider);
    final text = Theme.of(context).textTheme;
    final sources = [
      (Icons.menu_book_rounded, l10n.sourcesHisnTitle, l10n.sourcesHisnBody),
      (Icons.format_quote_rounded, l10n.sourcesFootnotesTitle, l10n.sourcesFootnotesBody),
      (Icons.wb_twilight_rounded, l10n.sourcesEveningTitle, l10n.sourcesEveningBody),
      (Icons.auto_stories_rounded, l10n.sourcesQuranTitle, l10n.sourcesQuranBody),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sourcesTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.gutter),
          children: [
            for (final (icon, title, body) in sources) ...[
              AppCard(
                elevated: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: context.palette.accent),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: text.titleSmall),
                          const SizedBox(height: AppSpace.xxs),
                          Text(body, style: text.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            const SizedBox(height: AppSpace.sm),
            _Notice(title: l10n.aboutContentNoticeTitle, body: l10n.aboutContentNotice),
            const SizedBox(height: AppSpace.lg),
            Center(
              child: Text(l10n.sourcesVersion(repo.version, repo.itemCount), style: text.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}

class _Principle extends StatelessWidget {
  const _Principle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: p.accentSoft,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: p.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: p.accent),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: AppSpace.xxs),
                Text(body, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
