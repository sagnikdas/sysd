import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/study_dates_provider.dart';
import '../../providers/user_prefs_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../onboarding/widgets/goal_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the app returns to foreground (e.g. after the user visits
  /// the system Alarms & Reminders settings page on Android 12).
  /// Re-syncs the notification schedule so that if exact-alarm permission
  /// was just granted, the reminders upgrade from inexact → exact.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncNotificationSchedules(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userPrefs = ref.watch(userPrefsProvider);
    final authState = ref.watch(authControllerProvider);
    final bookmarks = ref.watch(bookmarksProvider);
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
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _editDisplayName(context, ref, userPrefs.displayName),
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
            leading: const Icon(Icons.bookmark_outline),
            title: const Text('Bookmarks'),
            subtitle: Text(
              bookmarks.isEmpty
                  ? 'No bookmarked cards'
                  : '${bookmarks.length} card${bookmarks.length == 1 ? '' : 's'}',
            ),
            trailing: bookmarks.isNotEmpty
                ? const Icon(Icons.chevron_right)
                : null,
            onTap: bookmarks.isNotEmpty
                ? () => context.push('/study/concepts', extra: bookmarks.toList())
                : null,
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
            subtitle: Text(_notificationSummary(userPrefs)),
          ),
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
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Reset Progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Clear all progress, bookmarks, and streak'),
            onTap: () => _confirmReset(context, ref),
          ),
          const Divider(),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data != null
                  ? '${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                  : '—';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(version),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            subtitle: const Text('sagnikd91@gmail.com'),
            onTap: () async {
              final uri = Uri.parse(
                'mailto:sagnikd91@gmail.com?subject=${Uri.encodeComponent('SysDesign Flash: Feedback')}',
              );
              if (!await launchUrl(uri)) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not open mail app. Email sagnikd91@gmail.com directly.',
                    ),
                  ),
                );
              }
            },
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

    if (!enabled) {
      prefsNotifier.setRemindersEnabled(false);
      await NotificationService.instance.cancelDailyReminders();
      return;
    }

    final granted = await NotificationService.instance.requestPermissions();
    if (!context.mounted) return;

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permission denied. Enable it in device Settings.',
          ),
        ),
      );
      return;
    }

    prefsNotifier.setRemindersEnabled(true);
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
    final prefs = ref.read(userPrefsProvider);
    if (!prefs.remindersEnabled) {
      await NotificationService.instance.cancelDailyReminders();
      return;
    }

    await NotificationService.instance.scheduleWeeklyReminders(
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
      weekdays: prefs.reminderWeekdays,
      title: 'Time for a quick review',
      body: 'Keep your system design skills sharp with today\'s cards.',
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final controller = TextEditingController(text: current.trim());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: 'Your name'),
          textCapitalization: TextCapitalization.words,
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
    );
    if (confirmed == true) {
      ref
          .read(userPrefsProvider.notifier)
          .setDisplayName(controller.text.trim());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
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
          'This will clear all mastered cards, bookmarks, spaced repetition '
          'data, and your streak. This action cannot be undone.',
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
              await ref.read(masteredProvider.notifier).clearAll();
              await ref.read(streakProvider.notifier).reset();
              await ref.read(spacedRepetitionProvider.notifier).clearAll();
              await ref.read(studyDatesProvider.notifier).clearAll();
              await ref.read(bookmarksProvider.notifier).clearAll();
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
