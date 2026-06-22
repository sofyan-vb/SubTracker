import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart' show tr, themeModeNotifier, languageNotifier, currencyNotifier;
import '../main.dart';
import '../services/cloud_sync_service.dart';
import '../providers/subscription_provider.dart';
import '../utils/toast_utils.dart';
import '../utils/currency_utils.dart';
import 'currency_exchange_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            Text(tr('Preferensi Utama', 'Main Preferences'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildSettingCard(
              cardColor: cardColor,
              textColor: textColor,
              icon: Icons.currency_exchange_rounded,
              iconColor: const Color(0xFF2563EB),
              title: tr('Kalkulator Kurs', 'Currency Converter'),
              subtitle: tr('Bandingkan mata uang & lihat grafik statistik', 'Compare currencies & view statistical charts'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: textColor.withOpacity(0.3), size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencyExchangeScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              cardColor: cardColor,
              textColor: textColor,
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF10B981),
              title: tr('Bahasa Aplikasi', 'App Language'),
              subtitle: languageNotifier.value == 'ID' ? 'Bahasa Indonesia' : 'English',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: languageNotifier.value,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  items: const [
                    DropdownMenuItem(value: 'ID', child: Text('🇮🇩 ID')),
                    DropdownMenuItem(value: 'EN', child: Text('🇬🇧 EN')),
                  ],
                  onChanged: (val) async {
                    if (val != null) {
                      languageNotifier.value = val;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('app_lang', val);
                      setState((){});
                    }
                  },
                ),
              ),
              onTap: null,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              cardColor: cardColor,
              textColor: textColor,
              icon: Icons.payments_rounded,
              iconColor: const Color(0xFFF59E0B),
              title: tr('Mata Uang Utama', 'Main Currency'),
              subtitle: tr('Pilih mata uang default untuk aplikasi', 'Choose default currency for the app'),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currencyNotifier.value,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
                  dropdownColor: cardColor,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  items: CurrencyUtils.data.keys.map((c) {
                    return DropdownMenuItem(value: c, child: Text('${CurrencyUtils.data[c]!['flag']} $c'));
                  }).toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      currencyNotifier.value = val;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('app_currency', val);
                      setState((){});
                    }
                  },
                ),
              ),
              onTap: null,
            ),

            const SizedBox(height: 32),
            Text(tr('Tampilan & Sistem', 'Display & System'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildSettingCard(
              cardColor: cardColor,
              textColor: textColor,
              icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: isDark ? tr('Mode Terang', 'Light Mode') : tr('Mode Gelap', 'Dark Mode'),
              subtitle: tr('Ubah tema sesuai kenyamanan mata', 'Change theme for eye comfort'),
              trailing: Switch(
                value: isDark,
                activeColor: const Color(0xFF8B5CF6),
                onChanged: (val) async {
                  final newMode = val ? ThemeMode.dark : ThemeMode.light;
                  themeModeNotifier.value = newMode;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_theme_mode', val ? 'Dark' : 'Light');
                },
              ),
              onTap: null,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              cardColor: cardColor,
              textColor: textColor,
              icon: Icons.cloud_sync_rounded,
              iconColor: const Color(0xFF0EA5E9),
              title: tr('Sinkronisasi Data', 'Data Sync'),
              subtitle: tr('Cadangkan data ke Google Drive', 'Backup data to Google Drive'),
              trailing: Icon(Icons.cloud_upload_rounded, color: textColor.withOpacity(0.3), size: 20),
              onTap: () async {
                final subs = context.read<SubProvider>().subs;
                final result = await CloudSyncService.syncWithGoogleDrive(subs);
                if(mounted) ToastUtils.show(context, result);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required Color cardColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing,
            ]
          ],
        ),
      ),
    );
  }
}
