import 'dart:typed_data'; 
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
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    final tz.TZDateTime scheduledTzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final Int32List additionalFlags = isAlarm ? Int32List.fromList(<int>[4]) : Int32List(0);
    final AndroidNotificationSound customSound = RawResourceAndroidNotificationSound(isAlarm ? 'alarm_lagu' : ringtone);
    final String channelId = isAlarm ? 'channel_alarm_lagu_v3' : 'channel_notif_${ringtone}_v1';
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
}