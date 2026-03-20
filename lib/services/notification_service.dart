import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const int _dailyBaseId = 1000;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // Set tz.local to the device's actual timezone so scheduled times
    // are correct for every user, not just those in UTC.
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

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

  /// Returns true if notification posting is permitted, false if denied.
  /// Also attempts to request exact-alarm permission on Android 12 so that
  /// reminders fire at the precise time the user chose.
  Future<bool> requestPermissions() async {
    await initialize();

    final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();
    final ios = _plugin.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin
    >();

    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // On platforms where neither plugin applies (macOS etc.) treat as granted.
    if (androidGranted == null && iosGranted == null) return true;
    return (androidGranted ?? true) && (iosGranted ?? true);
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

    // Use exact scheduling when the OS permits it; fall back to inexact
    // (which the OS may delay by a few minutes) rather than silently failing.
    final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();
    final canExact = await android?.canScheduleExactNotifications() ?? true;
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_study_reminders',
        'Daily study reminders',
        channelDescription: 'Daily nudge to keep your study streak going',
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
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
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
