import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/localization/gen/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/category_icon.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/models/reminder.dart';
import '../application/reminders_controller.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reminders = ref.watch(remindersProvider);
    final exact = ref.watch(exactRemindersProvider).value;
    final builtIn = reminders.where((r) => !r.isCustom).toList();
    final custom = reminders.where((r) => r.isCustom).toList();
    final text = Theme.of(context).textTheme;
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersTitle)),
      floatingActionButton: custom.length >= Reminder.maxCustom
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addCustom(context, ref),
              icon: const Icon(Icons.add_alarm_rounded),
              label: Text(l10n.reminderAdd),
            ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.xs, AppSpace.gutter, 120),
          children: [
            Text(l10n.remindersIntro, style: text.bodyMedium),
            const SizedBox(height: AppSpace.lg),
            for (final r in builtIn) ...[
              _ReminderTile(reminder: r),
              const SizedBox(height: AppSpace.xs),
            ],
            if (custom.isNotEmpty) ...[
              const SizedBox(height: AppSpace.lg),
              SectionHeader(title: l10n.reminderCustomSection),
              for (final r in custom) ...[
                _ReminderTile(reminder: r),
                const SizedBox(height: AppSpace.xs),
              ],
            ],
            // Offer precise timing only when it matters and is missing.
            if (reminders.any((r) => r.enabled) && exact == false) ...[
              const SizedBox(height: AppSpace.md),
              const _ExactTimingCard(),
              const SizedBox(height: AppSpace.sm),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: p.textMuted),
                  const SizedBox(width: AppSpace.xs),
                  Expanded(child: Text(l10n.reminderInexactNote, style: text.bodySmall)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addCustom(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<(String, TimeOfDay)>(
      context: context,
      builder: (_) => const _CustomReminderDialog(),
    );
    if (result == null || !context.mounted) return;
    if (!await ensureNotificationRationale(context, ref)) return;
    final added = await ref.read(remindersProvider.notifier).addCustom(result.$1, result.$2);
    if (!context.mounted) return;
    if (added == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reminderLimitReached)));
      return;
    }
    final enabled = await ref.read(remindersProvider.notifier).setEnabled(added, true);
    if (enabled == ReminderEnableResult.permissionDenied && context.mounted) _showDenied(context);
  }
}

/// Explains why notifications are needed before the OS prompt appears.
/// Returns false if the user declines. Shown only while no reminder is on.
Future<bool> ensureNotificationRationale(BuildContext context, WidgetRef ref) async {
  if (ref.read(remindersProvider.notifier).hasEnabled) return true;
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.notifications_active_rounded),
      title: Text(l10n.reminderPermissionTitle),
      content: Text(l10n.reminderPermissionBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.reminderNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.actionConfirm),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void _showDenied(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.reminderPermissionDenied), duration: const Duration(seconds: 5)),
  );
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    final controller = ref.read(remindersProvider.notifier);
    final time = TimeOfDay(hour: reminder.hour, minute: reminder.minute);
    final (title, icon) = switch (reminder.kind) {
      ReminderKind.morning => (l10n.reminderMorning, 'morning'),
      ReminderKind.evening => (l10n.reminderEvening, 'evening'),
      ReminderKind.sleep => (l10n.reminderSleep, 'sleep'),
      ReminderKind.custom => (reminder.title.isEmpty ? l10n.appName : reminder.title, 'misc'),
    };

    Future<void> toggle(bool value) async {
      if (value && !await ensureNotificationRationale(context, ref)) return;
      final result = await controller.setEnabled(reminder, value);
      if (result == ReminderEnableResult.permissionDenied && context.mounted) _showDenied(context);
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(context: context, initialTime: time);
      if (picked != null) await controller.setTime(reminder, picked);
    }

    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.sm, AppSpace.xs, AppSpace.sm),
      child: Row(
        children: [
          CategoryIcon(iconKey: icon),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                InkWell(
                  onTap: pickTime,
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.xxs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule_rounded, size: 16, color: p.primary),
                        const SizedBox(width: AppSpace.xxs),
                        Text(
                          time.format(context),
                          style: text.labelLarge?.copyWith(color: p.primary),
                          semanticsLabel: '${l10n.reminderTime} ${time.format(context)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reminder.isCustom)
            IconButton(
              tooltip: l10n.reminderDelete,
              onPressed: () => controller.remove(reminder),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          Switch(value: reminder.enabled, onChanged: toggle),
        ],
      ),
    );
  }
}

class _CustomReminderDialog extends StatefulWidget {
  const _CustomReminderDialog();

  @override
  State<_CustomReminderDialog> createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<_CustomReminderDialog> {
  final _title = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reminderAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(hintText: l10n.reminderTitleHint),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded),
            title: Text(l10n.reminderTime),
            trailing: Text(_time.format(context), style: Theme.of(context).textTheme.titleMedium),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () => Navigator.pop(context, (_title.text, _time)),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

class _ExactTimingCard extends ConsumerWidget {
  const _ExactTimingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final text = Theme.of(context).textTheme;
    return AppCard(
      color: p.accentSoft,
      elevated: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.alarm_on_rounded, color: p.accent),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.reminderExactTitle, style: text.titleSmall),
                const SizedBox(height: AppSpace.xxs),
                Text(l10n.reminderExactBody, style: text.bodyMedium),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => ref.read(remindersProvider.notifier).requestExactTiming(),
                    child: Text(l10n.reminderExactAction),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
