// lib/services/notification_service.dart
import 'package:flutter/foundation.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; 

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; 

    tz.initializeTimeZones();
    
    // DETEKSI WAKTU GADGET 
    final dynamic info = await FlutterTimezone.getLocalTimezone();
    String timeZoneName;
    try { 
      timeZoneName = info.name; 
    } catch(e) { 
      timeZoneName = 'Asia/Jakarta'; 
    }
    
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(settings);

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission(); 
      await androidPlugin.requestExactAlarmsPermission(); 
    }
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime) async {
    if (kIsWeb) return;

    final tz.TZDateTime scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (scheduledTzTime.isBefore(now)) return; 

    await _notificationsPlugin.zonedSchedule(
      id,
      title, 
      body,  
      scheduledTzTime, 
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sub_tracker_spanduk_v3', // ID Baru lagi agar Android mereset ulang izin
          'Pesan Tagihan',
          importance: Importance.max, // Wajib Maksimal
          priority: Priority.high,    // Wajib Tinggi
          playSound: true,            // Wajib ada agar Android mau menurunkan Banner
          enableVibration: true,      // Wajib ada agar Android mau menurunkan Banner
          ticker: 'Pengingat baru',
          // fullScreenIntent dan showWhen SUDAH DIHAPUS agar tidak dianggap alarm
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}