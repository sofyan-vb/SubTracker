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
    
    final dynamic info = await FlutterTimezone.getLocalTimezone();
    String timeZoneName;
    try { 
      timeZoneName = info.name; 
    } catch(e) { 
      timeZoneName = 'Asia/Jakarta'; 
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
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

   
    const NotificationDetails notifDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'sub_tracker_pasti_muncul_v7', 
        'Pengingat Mendesak',
        channelDescription: 'Tagihan yang tidak boleh dilewatkan',
        importance: Importance.max, 
        priority: Priority.high,    
        playSound: true,            
        enableVibration: true,      
        visibility: NotificationVisibility.public, 
        category: AndroidNotificationCategory.alarm, 
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
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}