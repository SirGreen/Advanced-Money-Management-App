import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:io';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    String timeZoneName = 'UTC';

    try {
      // Fix: flutter_timezone might return object, safe convert to String
      final dynamic raw = await FlutterTimezone.getLocalTimezone();
      String rawTimeZone = raw.toString();
      timeZoneName = rawTimeZone;

      // Fix for emulator returning "TimezoneInfo(Asia/Bangkok, ...)"
      if (rawTimeZone.startsWith('TimezoneInfo')) {
        final start = rawTimeZone.indexOf('(') + 1;
        final end = rawTimeZone.indexOf(',');
        if (start > 0 && end > start) {
          timeZoneName = rawTimeZone.substring(start, end).trim();
        }
      }
    } catch (e) {
      debugPrint('Could not get local timezone: $e');
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Failed to set timezone "$timeZoneName": $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
      },
    );

    // Create Notification Channel for Android 8.0+
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          'recurring_transaction_channel',
          'Recurring Transactions',
          description: 'Reminders for upcoming recurring transactions',
          importance: Importance.max,
        ),
      );
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      // Request notification permission (Android 13+)
      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();

      // Also request exact alarm permission (Android 12+)
      // Note: This might not show a dialog on all versions but is good practice
      if (granted == true) {
        await androidImplementation?.requestExactAlarmsPermission();
      }

      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Ensure we schedule at a reasonable time (9 AM) instead of midnight
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9,
      0,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) return;

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'recurring_transaction_channel',
            'Recurring Transactions',
            channelDescription: 'Reminders for upcoming recurring transactions',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Successfully scheduled notification ID $id at $scheduledDateTime");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
      // Fallback to inexact if exact fails due to permission
      try {
        await _notificationsPlugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(scheduledDateTime, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'recurring_transaction_channel',
              'Recurring Transactions',
              channelDescription: 'Reminders for upcoming recurring transactions',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        debugPrint("Successfully scheduled inexact notification ID $id at $scheduledDateTime");
      } catch (e2) {
        debugPrint("Failed even with inexact schedule: $e2");
      }
    }
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
