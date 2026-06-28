import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import 'dashboard_screen.dart';
import '../utils/toast_utils.dart';

class NotificationSoundScreen extends StatefulWidget {
  const NotificationSoundScreen({super.key});

  @override
  State<NotificationSoundScreen> createState() => _NotificationSoundScreenState();
}

class _NotificationSoundScreenState extends State<NotificationSoundScreen> {
  Timer? _previewTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _previewTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _previewSound(String soundFile, {bool isAlarm = false}) async {
    _previewTimer?.cancel();
    await _audioPlayer.stop();

    if (soundFile == 'default_system') {
      // Default system sound cannot be reliably previewed without native code
      return;
    }
    
    String extension = soundFile == 'alarm_lagu' ? '.mp3' : '.wav';
    await _audioPlayer.play(AssetSource('audio/$soundFile$extension'));
    
    _previewTimer = Timer(const Duration(seconds: 5), () {
      _audioPlayer.stop();
    });
  }

  String _getDisplayName(String rawName) {
    if (rawName == 'default_system') return 'DEFAULT HP';
    if (rawName == 'ringtone_default') return 'NADA SUBTRACK';
    return rawName.replaceAll('ringtone_', '').replaceAll('alarm_', '').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, lang, child) {
            return Text(
              tr('Suara Notifikasi & Alarm', 'Notification & Alarm Sound', 'Notificación y sonido de alarma'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
            );
          }
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            FlutterLocalNotificationsPlugin().cancel(8888);
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(tr('Suara Notifikasi Biasa', 'Regular Notification', 'Notificación periódica'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: ['default_system', 'ringtone_default', 'ringtone_chime', 'ringtone_alert', 'ringtone_synth'].map((r) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(_getDisplayName(r), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        value: r,
                        groupValue: ringtoneNotifier.value, 
                        activeColor: const Color(0xFF2563EB),
                        onChanged: (val) async {
                          ringtoneNotifier.value = val!; 
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('app_ringtone', val); 
                          setState((){});
                          _previewSound(val);
                          if (context.mounted) ToastUtils.show(context, tr('Suara notifikasi diubah', 'Notification sound changed', 'El sonido de notificación cambió'));
                        },
                      ),
                      if (r != 'ringtone_synth') Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(tr('Suara Alarm Tagihan', 'Billing Alarm Sound', 'Sonido de alarma de facturación'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
              ),
              child: Column(
                children: ['alarm_lagu', 'alarm_digital', 'alarm_classic'].map((r) {
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(_getDisplayName(r), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        value: r,
                        groupValue: alarmNotifier.value, 
                        activeColor: Colors.redAccent,
                        onChanged: (val) async {
                          alarmNotifier.value = val!; 
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('app_alarm', val); 
                          setState((){});
                          _previewSound(val, isAlarm: true);
                          if (context.mounted) ToastUtils.show(context, tr('Suara alarm diubah', 'Alarm sound changed', 'El sonido de la alarma cambió'));
                        },
                      ),
                      if (r != 'alarm_classic') Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
