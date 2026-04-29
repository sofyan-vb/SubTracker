// lib/services/notification_service.dart
import 'package:flutter/foundation.dart'; // Diperlukan untuk mengecek kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // PENGAMAN: Jika dijalankan di Web/Chrome, hentikan proses agar tidak error
    if (kIsWeb) return; 

    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    // PENGAMAN: Jika dijalankan di Web/Chrome, hentikan proses agar tidak error
    if (kIsWeb) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sub_tracker_channel',
          'Subscription Reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher', // Tambahan icon spesifik untuk jaga-jaga
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}