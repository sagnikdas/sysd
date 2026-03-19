import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyBaseId = 1000;
  static const int _trialExpiryId = 2000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> cancelDailyReminders() async {
    await initialize();
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(_dailyNotificationId(weekday));
    }
  }

  Future<void> scheduleWeeklyReminders({
    required int hour,
    required int minute,
    required Set<int> weekdays,
    required String title,
    required String body,
  }) async {
    await initialize();
    await cancelDailyReminders();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_study_reminders',
        'Daily study reminders',
        channelDescription: 'Pro study reminders at your chosen time',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    for (final weekday in weekdays) {
      final scheduled = _nextInstanceForWeekday(weekday, hour, minute);
      await _plugin.zonedSchedule(
        _dailyNotificationId(weekday),
        title,
        body,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> scheduleTrialExpiryReminder({
    required DateTime trialStart,
    String title = 'Trial ending soon',
    String body = 'Your trial ends tomorrow. Keep your momentum with Pro.',
  }) async {
    await initialize();

    final reminderAt = trialStart.add(const Duration(days: 6));
    final reminder = tz.TZDateTime.from(
      DateTime(reminderAt.year, reminderAt.month, reminderAt.day, 10),
      tz.local,
    );

    if (reminder.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'trial_expiry_reminders',
        'Trial expiry reminders',
        channelDescription: 'Reminder before free trial ends',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.zonedSchedule(
      _trialExpiryId,
      title,
      body,
      reminder,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTrialExpiryReminder() async {
    await initialize();
    await _plugin.cancel(_trialExpiryId);
  }

  int _dailyNotificationId(int weekday) => _dailyBaseId + weekday;

  tz.TZDateTime _nextInstanceForWeekday(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceAtTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceAtTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
