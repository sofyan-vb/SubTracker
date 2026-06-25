import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/subscription_provider.dart';
import '../utils/toast_utils.dart';
import 'dashboard_screen.dart';
import '../main.dart';
import 'splash_screen.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DangerZoneScreen extends StatefulWidget {
  const DangerZoneScreen({super.key});

  @override
  State<DangerZoneScreen> createState() => _DangerZoneScreenState();
}

class _DangerZoneScreenState extends State<DangerZoneScreen> {

  // Backup and Restore removed from Danger Zone, now in Dashboard Settings

  Future<void> _clearHistory() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(tr('Hapus Riwayat?', 'Clear History?'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(tr('Seluruh riwayat tagihan yang sudah dibayar akan dihapus. Langganan aktif tetap aman. Lanjutkan?', 'All paid billing history will be deleted. Active subscriptions remain safe. Continue?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
          TextButton(
            onPressed: () {
              Navigator.pop(confirmCtx);
              context.read<SubProvider>().clearHistory();
              if (mounted) ToastUtils.show(context, tr('Riwayat tagihan berhasil dihapus', 'Billing history successfully cleared'));
            },
            child: Text(tr('Ya, Hapus', 'Yes, Delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  Future<void> _resetPreferences() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(tr('Reset Preferensi?', 'Reset Preferences?'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(tr('Pengaturan seperti tema, bahasa, dan suara akan dikembalikan ke awal. Data langganan tetap aman. Lanjutkan?', 'Settings like theme, language, and sounds will be reset to default. Subscription data remains safe. Continue?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(confirmCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('app_lang');
              await prefs.remove('app_theme_mode');
              await prefs.remove('app_ringtone');
              await prefs.remove('app_alarm');
              
              languageNotifier.value = 'EN';
              themeModeNotifier.value = ThemeMode.system;
              ringtoneNotifier.value = 'ringtone_default';
              alarmNotifier.value = 'alarm_lagu';
              
              if (mounted) ToastUtils.show(context, tr('Preferensi berhasil direset', 'Preferences successfully reset'));
            },
            child: Text(tr('Ya, Reset', 'Yes, Reset'), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  Future<void> _deleteAllData() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (confirmCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(tr('Reboot Sistem?', 'System Reboot?'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Text(tr('Semua data langganan, profil, dan pengaturan akan terhapus. Lanjutkan?', 'All subscriptions, profiles, and settings will be deleted. Continue?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(confirmCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (mounted) {
                final provider = context.read<SubProvider>();
                final subsList = provider.subs.toList();
                for (var sub in subsList) {
                  provider.removeSub(sub.id);
                }
                
                userNameNotifier.value = ''; 
                
                ToastUtils.show(context, tr('Sistem berhasil di-reboot. Semua data telah dikosongkan', 'System rebooted. All data cleared'));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              }
            }, 
            child: Text(tr('Ya, Hapus Semua', 'Yes, Delete All'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ]
      )
    );
  }

  Widget _buildDangerTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 11))),
        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
        onTap: onTap, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          tr('Zona Bahaya', 'Danger Zone'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3))
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tr('Hati-hati! Tindakan di halaman ini dapat mengubah atau menghapus data secara permanen.', 'Caution! Actions on this page can modify or delete data permanently.'),
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(tr('Pembersihan Data', 'Data Cleanup'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDangerTile(
              tr('Hapus Riwayat', 'Clear History'),
              tr('Menghapus log tagihan yang sudah lalu', 'Delete past billing logs'),
              Icons.auto_delete_rounded,
              const Color(0xFFF59E0B), // Amber 500
              _clearHistory,
            ),
            _buildDangerTile(
              tr('Hapus Seluruh Data Aplikasi', 'Delete All App Data'),
              tr('Hapus seluruh langganan dan pengaturan permanen', 'Delete all subscriptions and settings permanently'),
              Icons.delete_sweep_rounded,
              const Color(0xFFEF4444), // Red 500
              _deleteAllData,
            ),
            
            const SizedBox(height: 24),
            Text(tr('Sistem', 'System'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDangerTile(
              tr('Reset Preferensi', 'Reset Preferences'),
              tr('Kembalikan pengaturan tema, bahasa, dll ke bawaan', 'Reset theme, language, etc to default'),
              Icons.restore_page_rounded,
              const Color(0xFF3B82F6), // Blue 500
              _resetPreferences,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
