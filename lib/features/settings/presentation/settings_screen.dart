import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/utils/share_helper.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/app_settings.dart';
import '../../reminders/application/reminders_controller.dart';
import '../application/data_management.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final version = ref.watch(appVersionProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter,
            AppSpace.xs,
            AppSpace.gutter,
            AppSpace.xxl,
          ),
          children: [
            SectionHeader(title: l10n.settingsAppearance),
            _Group(
              children: [
                _Labeled(
                  label: l10n.settingsTheme,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.themeSystem),
                        icon: const Icon(Icons.brightness_auto_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.themeLight),
                        icon: const Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.themeDark),
                        icon: const Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => controller.setThemeMode(s.first),
                  ),
                ),
                _Labeled(
                  label: l10n.settingsLanguage,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: 'ar', label: Text(l10n.languageArabic)),
                      ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
                    ],
                    selected: {settings.languageCode},
                    onSelectionChanged: (s) async {
                      await controller.setLanguage(s.first);
                      // Reminder texts follow the app language.
                      await ref.read(remindersProvider.notifier).rescheduleAll();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            SectionHeader(title: l10n.settingsReading),
            _Group(
              children: [
                _Labeled(
                  label: l10n.settingsFontSize,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpace.sm),
                        decoration: BoxDecoration(
                          color: p.surfaceSunken,
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Text(
                          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.reading(p, scale: settings.readingScale),
                        ),
                      ),
                      Slider(
                        value: settings.readingScale,
                        min: AppSettings.minReadingScale,
                        max: AppSettings.maxReadingScale,
                        divisions: 10,
                        label: '${(settings.readingScale * 100).round()}%',
                        onChanged: controller.setReadingScale,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: Text(l10n.readerShowTranslation),
                  value: settings.showTranslation,
                  onChanged: controller.setShowTranslation,
                ),
                SwitchListTile(
                  title: Text(l10n.readerAutoAdvance),
                  value: settings.autoAdvance,
                  onChanged: controller.setAutoAdvance,
                ),
                SwitchListTile(
                  title: Text(l10n.readerTapText),
                  value: settings.tapTextToCount,
                  onChanged: controller.setTapTextToCount,
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            SectionHeader(title: l10n.settingsFeedback),
            _Group(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_rounded),
                  title: Text(l10n.settingsHaptics),
                  value: settings.hapticsEnabled,
                  onChanged: controller.setHaptics,
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: Text(l10n.settingsSound),
                  subtitle: Text(l10n.settingsSoundHint),
                  value: settings.soundEnabled,
                  onChanged: controller.setSound,
                ),
                _NavTile(
                  icon: Icons.notifications_rounded,
                  title: l10n.settingsReminders,
                  subtitle: l10n.settingsRemindersSubtitle,
                  onTap: () => context.push(Routes.reminders),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            SectionHeader(title: l10n.settingsData),
            _Group(
              children: [
                _NavTile(
                  icon: Icons.restart_alt_rounded,
                  title: l10n.settingsResetProgress,
                  onTap: () => _resetProgress(context, ref),
                ),
                _NavTile(
                  icon: Icons.delete_forever_rounded,
                  title: l10n.settingsClearData,
                  destructive: true,
                  onTap: () => _clearAll(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),
            SectionHeader(title: l10n.settingsAbout),
            _Group(
              children: [
                _NavTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAbout,
                  onTap: () => context.push(Routes.about),
                ),
                _NavTile(
                  icon: Icons.menu_book_rounded,
                  title: l10n.settingsSources,
                  onTap: () => context.push(Routes.sources),
                ),
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.settingsPrivacy,
                  onTap: () => context.push(Routes.privacy),
                ),
                Builder(
                  builder: (context) => _NavTile(
                    icon: Icons.share_rounded,
                    title: l10n.settingsShareApp,
                    onTap: () => ShareHelper.share(
                      context,
                      l10n.settingsShareMessage(AppInfo.playStoreUrl),
                      subject: l10n.appName,
                    ),
                  ),
                ),
                _NavTile(
                  icon: Icons.description_outlined,
                  title: l10n.settingsLicenses,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l10n.appName,
                    applicationVersion: version,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),
            if (version != null)
              Center(child: Text(l10n.settingsVersion(version), style: text.bodySmall)),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String body, String action) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _resetProgress(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      context,
      l10n.settingsResetProgress,
      l10n.settingsResetProgressBody,
      l10n.actionReset,
    )) {
      return;
    }
    await ref.read(dataManagementProvider).resetProgress();
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsProgressReset)));
    }
  }

  Future<void> _clearAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    if (!await _confirm(
      context,
      l10n.settingsClearData,
      l10n.settingsClearDataBody,
      l10n.actionDelete,
    )) {
      return;
    }
    await ref.read(dataManagementProvider).clearAll();
    if (context.mounted) context.go(Routes.onboarding);
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevated: false,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: AppSpace.md, endIndent: AppSpace.md),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpace.sm),
          SizedBox(width: double.infinity, child: child),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = destructive ? p.danger : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: color == null ? null : TextStyle(color: color)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(Icons.chevron_right_rounded, color: p.textMuted),
      onTap: onTap,
    );
  }
}
