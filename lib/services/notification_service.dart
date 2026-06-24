import 'dart:typed_data'; 
import 'dart:math'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; 

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return; 

    tz.initializeTimeZones();
    
    final dynamic info = await FlutterTimezone.getLocalTimezone();
    String timeZoneName;
    try { 
      timeZoneName = info.name; 
    } catch(e) { 
      timeZoneName = 'Asia/Jakarta'; 
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(settings);

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission(); 
      await androidPlugin.requestExactAlarmsPermission(); 
    }
  }

  static Future<void> scheduleNotification(int id, String title, String body, DateTime scheduledTime, {bool isAlarm = false}) async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    final String ringtone = prefs.getString('app_ringtone') ?? 'ringtone_default';
    final String alarm = prefs.getString('app_alarm') ?? 'alarm_lagu';

    final tz.TZDateTime scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Int32List additionalFlags = isAlarm ? Int32List.fromList(<int>[4]) : Int32List(0);
    final AndroidNotificationSound? customSound = (!isAlarm && ringtone == 'default_system') 
      ? null 
      : RawResourceAndroidNotificationSound(isAlarm ? alarm : ringtone);
    final String channelId = isAlarm ? 'channel_alarm_${alarm}_v3' : 'channel_notif_${ringtone}_v1';
    final String channelName = isAlarm ? 'Alarm Tagihan' : 'Notifikasi Tagihan';

    final NotificationDetails notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, 
        channelName,
        channelDescription: 'Tagihan yang tidak boleh dilewatkan',
        importance: Importance.max, 
        priority: Priority.high,    
        playSound: true,     
        sound: customSound,      
        enableVibration: true,      
        visibility: NotificationVisibility.public, 
        category: isAlarm ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder, 
        additionalFlags: additionalFlags, 
        audioAttributesUsage: isAlarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      ),
    );

    if (scheduledTzTime.isBefore(now) || scheduledTzTime.isAtSameMomentAs(now)) {
      await _notificationsPlugin.show(id, title, body, notifDetails);
      return; 
    }
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title, 
      body,  
      scheduledTzTime, 
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.alarmClock, 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> scheduleInactiveReminder() async {
    if (kIsWeb) return;
    
    final List<String> messages = [
      'Hei, sudah lama kamu tidak mengecek tagihanmu. Yuk cek sekarang agar tidak ada yang terlewat!',
      'Jangan sampai ada tagihan yang bocor! Buka SubTrack IQ untuk memastikan keuanganmu aman.',
      'Ada tagihan yang mendekati jatuh tempo? Cek langgananmu di SubTrack IQ hari ini.',
      'Kondisi keuangan langgananmu butuh perhatian nih. Yuk buka aplikasi sekarang!',
      'Kelola langgananmu dengan baik. Buka SubTrack IQ dan pastikan semuanya terkontrol.'
    ];
    
    final String body = messages[Random().nextInt(messages.length)];
    
    // Schedule for 3 days from now
    final tz.TZDateTime scheduledTzTime = tz.TZDateTime.now(tz.local).add(const Duration(days: 3));
    
    final prefs = await SharedPreferences.getInstance();
    final String ringtone = prefs.getString('app_ringtone') ?? 'ringtone_default';
    
    final AndroidNotificationSound? customSound = (ringtone == 'default_system') 
      ? null 
      : RawResourceAndroidNotificationSound(ringtone);
      
    final NotificationDetails notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_inactive_reminder', 
        'Pengingat Sistem',
        channelDescription: 'Pengingat untuk membuka aplikasi',
        importance: Importance.defaultImportance, 
        priority: Priority.defaultPriority,    
        playSound: true,     
        sound: customSound,      
      ),
    );

    // Cancel existing reminder if any, then schedule new one
    await _notificationsPlugin.cancel(9999);
    
    await _notificationsPlugin.zonedSchedule(
      9999,
      'SubTrack IQ merindukanmu!', 
      body,  
      scheduledTzTime, 
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}