import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/study_dates_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../onboarding/widgets/goal_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userPrefs = ref.watch(userPrefsProvider);
    final tier = ref.watch(subscriptionProvider);
    final authState = ref.watch(authControllerProvider);
    final displayLabel = userPrefs.displayName.trim().isEmpty
        ? 'Not set'
        : userPrefs.displayName.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Display name'),
            subtitle: Text(displayLabel),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Account & Cloud Sync'),
            subtitle: Text(
              authState.user?.email ??
                  (authState.isConfigured
                      ? 'Not signed in'
                      : 'Cloud sync not configured in this build'),
            ),
            onTap: () => context.push('/auth'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(switch (userPrefs.themeMode) {
              ThemeModePreference.light => 'Light',
              ThemeModePreference.dark => 'Dark',
              ThemeModePreference.system => 'System',
            }),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<ThemeModePreference>(
              selected: {userPrefs.themeMode},
              onSelectionChanged: (selection) {
                ref
                    .read(userPrefsProvider.notifier)
                    .setThemeMode(selection.first);
              },
              segments: const [
                ButtonSegment(
                  value: ThemeModePreference.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeModePreference.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeModePreference.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Daily Goal'),
            subtitle: Text('${userPrefs.dailyGoal} cards / day'),
            onTap: () => _pickDailyGoal(context, ref, userPrefs.dailyGoal),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none_outlined),
            title: const Text('Notification settings'),
            subtitle: Text(
              tier == SubscriptionTier.pro
                  ? _notificationSummary(userPrefs)
                  : 'Upgrade to Pro to enable reminders',
            ),
          ),
          if (tier == SubscriptionTier.pro) ...[
            SwitchListTile(
              secondary: const Icon(Icons.alarm_outlined),
              title: const Text('Daily reminders'),
              subtitle: const Text('Schedule a study nudge on selected days'),
              value: userPrefs.remindersEnabled,
              onChanged: (value) =>
                  _toggleReminders(context, ref, enabled: value),
            ),
            ListTile(
              leading: const Icon(Icons.schedule_outlined),
              title: const Text('Reminder time'),
              subtitle: Text(_timeLabel(userPrefs)),
              enabled: userPrefs.remindersEnabled,
              onTap: userPrefs.remindersEnabled
                  ? () => _pickReminderTime(context, ref)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var day = 1; day <= 7; day++)
                    FilterChip(
                      label: Text(_weekdayLabel(day)),
                      selected: userPrefs.reminderWeekdays.contains(day),
                      onSelected: userPrefs.remindersEnabled
                          ? (_) => _toggleWeekday(context, ref, day)
                          : null,
                    ),
                ],
              ),
            ),
          ],
          if (kDebugMode)
            SwitchListTile(
              secondary: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Debug: Toggle Pro'),
              value: ref.watch(subscriptionProvider) == SubscriptionTier.pro,
              onChanged: (value) async {
                if (value) {
                  ref
                      .read(subscriptionProvider.notifier)
                      .setTier(SubscriptionTier.pro);
                  return;
                }
                await ref
                    .read(subscriptionProvider.notifier)
                    .clearDebugOverride();
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchase'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final tier = await ref
                    .read(subscriptionProvider.notifier)
                    .restorePurchases();
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      tier == SubscriptionTier.pro
                          ? 'Pro subscription restored.'
                          : 'No active Pro purchase found.',
                    ),
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      error.toString().replaceFirst('Exception: ', ''),
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Reset Progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Clear all mastered cards and streak'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            subtitle: const Text('hello@sysdesignflash.dev'),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Email hello@sysdesignflash.dev with your feedback.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(UserPrefsState prefs) {
    final hour = prefs.reminderHour.toString().padLeft(2, '0');
    final minute = prefs.reminderMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _notificationSummary(UserPrefsState prefs) {
    if (!prefs.remindersEnabled) return 'Disabled';
    return '${_timeLabel(prefs)} on ${prefs.reminderWeekdays.length} day(s)';
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      _ => 'Sun',
    };
  }

  Future<void> _toggleReminders(
    BuildContext context,
    WidgetRef ref, {
    required bool enabled,
  }) async {
    final prefsNotifier = ref.read(userPrefsProvider.notifier);
    prefsNotifier.setRemindersEnabled(enabled);

    if (!enabled) {
      await NotificationService.instance.cancelDailyReminders();
      await NotificationService.instance.cancelTrialExpiryReminder();
      return;
    }

    await NotificationService.instance.requestPermissions();
    await _syncNotificationSchedules(ref);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Daily reminders enabled')));
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(userPrefsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: prefs.reminderHour,
        minute: prefs.reminderMinute,
      ),
    );
    if (picked == null) return;
    ref
        .read(userPrefsProvider.notifier)
        .setReminderTime(hour: picked.hour, minute: picked.minute);
    await _syncNotificationSchedules(ref);
  }

  Future<void> _toggleWeekday(
    BuildContext context,
    WidgetRef ref,
    int day,
  ) async {
    ref.read(userPrefsProvider.notifier).toggleReminderWeekday(day);
    await _syncNotificationSchedules(ref);
    if (!context.mounted) return;
    final count = ref.read(userPrefsProvider).reminderWeekdays.length;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reminders set for $count day(s)')));
  }

  Future<void> _syncNotificationSchedules(WidgetRef ref) async {
    final tier = ref.read(subscriptionProvider);
    final prefs = ref.read(userPrefsProvider);
    if (tier != SubscriptionTier.pro || !prefs.remindersEnabled) {
      await NotificationService.instance.cancelDailyReminders();
      await NotificationService.instance.cancelTrialExpiryReminder();
      return;
    }

    await NotificationService.instance.scheduleWeeklyReminders(
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
      weekdays: prefs.reminderWeekdays,
      title: 'Time for a quick review',
      body: 'Keep your system design skills sharp with today\'s cards.',
    );

    final subscriptionBox = Hive.box('subscription');
    final trialStartedAt = DateTime.tryParse(
      (subscriptionBox.get('trialStartedAt') as String?) ?? '',
    );
    if (trialStartedAt != null) {
      await NotificationService.instance.scheduleTrialExpiryReminder(
        trialStart: trialStartedAt,
      );
    }
  }

  Future<void> _pickDailyGoal(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    int selected = current;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Daily Goal'),
          content: GoalPicker(
            selectedGoal: selected,
            onChanged: (g) => setState(() => selected = g),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      ref.read(userPrefsProvider.notifier).setDailyGoal(selected);
    }
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all mastered cards, bookmarks, and your streak. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              ref.read(masteredProvider.notifier).clearAll();
              ref.read(streakProvider.notifier).reset();
              await ref.read(spacedRepetitionProvider.notifier).clearAll();
              await ref.read(studyDatesProvider.notifier).clearAll();
              // Clear bookmarks too
              final bookmarkIds = ref.read(bookmarksProvider).toList();
              for (final id in bookmarkIds) {
                ref.read(bookmarksProvider.notifier).toggle(id);
              }
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Progress reset')));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
