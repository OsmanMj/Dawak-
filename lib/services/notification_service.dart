import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/medication.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleMedicationReminders(Medication medication) async {
    // Basic scheduling logic - needs to be expanded for complex frequencies
    // For now, we'll assume daily for testing

    // Note: Notification IDs must be unique integers.
    // We can generate a unique hash from medication ID + time.

    for (var time in medication.scheduleTimes) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Convert to TZDateTime
      // CAUTION: This assumes local timezone.

      // We use a simple hash for ID. In production, need a better ID management.
      int notificationId =
          (medication.id.hashCode + time.hour + time.minute).abs();

      try {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'حان وقت الدواء',
          'تناول ${medication.name} (${medication.dose})',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_channel_new', // Changed ID to force update settings
              'التذكير بالأدوية',
              channelDescription: 'قناة لإشعارات مواعيد الأدوية',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default',
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: scheduledDate.toIso8601String(),
        );
        print('Scheduled notification $notificationId for $scheduledDate');
      } catch (e) {
        print('Error scheduling notification: $e');
      }
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<bool> checkExactAlarmPermission() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    // Note: requestExactAlarmsPermission returns null if not Android, or true/false if valid.
    // But we actually want to 'check' not 'request' if possible?
    // The plugin doesn't have a simple 'check' method exposed easily on all versions,
    // but requesting it again is safe and returns the status.
    return result ?? true;
  }

  Future<void> cancelNotifications(Medication medication) async {
    for (var time in medication.scheduleTimes) {
      int notificationId =
          (medication.id.hashCode + time.hour + time.minute).abs();
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
