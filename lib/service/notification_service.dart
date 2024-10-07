import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Create a notification channel (required for Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_channel', // id
      'Todo Notifications', // title
      description: 'Notifications for todo tasks',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tap
        print("Notification tapped: ${notificationResponse.payload}");
      },
    );

    // Create the notification channel
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (await _isAndroid13OrHigher()) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        final result = await Permission.notification.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // Return true for lower Android versions
  }

  Future<bool> _isAndroid13OrHigher() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt >= 33;
  }

  int _generateValidNotificationId(int taskId, bool isEvening) {
    int baseId = taskId % 1000000;
    return isEvening ? baseId + 1 : baseId;
  }

  Future<bool> scheduleNotifications(Task task) async {
    if (!_initialized) {
      await init();
    }

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      print('Notification permission denied');
      return false;
    }

    try {
      print("Scheduling notifications for task: ${task.title}");
      await _scheduleMorningNotification(task);
      await _scheduleEveningNotification(task);
      return true;
    } catch (e) {
      print('Error scheduling notifications: $e');
      return false;
    }
  }

  Future<void> _scheduleMorningNotification(Task task) async {
    await _scheduleSpecificNotification(
      task,
      14, // 9 AM
      26, // Minute
      _generateValidNotificationId(task.id, false),
      'Morning Reminder',
    );
  }

  Future<void> _scheduleEveningNotification(Task task) async {
    await _scheduleSpecificNotification(
      task,
      23, // 11 PM
      0, // Minute
      _generateValidNotificationId(task.id, true),
      'Evening Reminder',
    );
  }

  Future<void> _scheduleSpecificNotification(
      Task task,
      int hour,
      int minute,
      int notificationId,
      String notificationTitle,
      ) async {
    int utcHour = hour - 6; // Bangladesh is UTC+6
    if (utcHour < 0) {
      utcHour += 24; // Adjust for the previous day if necessary
    }
    final tz.TZDateTime scheduledDate = _getScheduledDateTime(task.dueDate, utcHour, minute);

    print("Scheduling notification: $notificationTitle at $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      notificationTitle,
      'Task due today: ${task.title}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Notifications',
          channelDescription: 'Notifications for todo tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Notification scheduled successfully!");
  }

  tz.TZDateTime _getScheduledDateTime(DateTime dueDate, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1)); // Move to next day if time is in the past
    }

    return scheduledDate;
  }

  Future<void> cancelNotification(int taskId) async {
    await flutterLocalNotificationsPlugin.cancel(_generateValidNotificationId(taskId, false));
    await flutterLocalNotificationsPlugin.cancel(_generateValidNotificationId(taskId, true));
  }
}
