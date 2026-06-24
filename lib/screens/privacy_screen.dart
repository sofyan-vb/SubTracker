import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/subscription_provider.dart';
import '../utils/toast_utils.dart';
import '../main.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

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
              tr('Privasi & Keamanan', 'Privacy & Security'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
            );
          }
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Perlindungan Data Anda', 'Your Data Protection'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(tr('Di SubTrack IQ, kami menganggap privasi pengguna sebagai hal yang mutlak. Aplikasi ini dirancang menggunakan arsitektur Offline-First.', 'At SubTrack IQ, we take user privacy absolutely seriously. This app is designed using an Offline-First architecture.'), style: TextStyle(color: subTextColor, height: 1.5, fontSize: 13)),
                  const SizedBox(height: 24),
                  
                  _buildPrivacyPoint('1', tr('Pengumpulan Data', 'Data Collection'), tr('SubTrack IQ tidak mengumpulkan atau merekam data identitas pribadi Anda. Anda menggunakan aplikasi ini secara anonim.', 'SubTrack IQ does not collect your personal data. You use this app anonymously.'), textColor, subTextColor),
                  _buildPrivacyPoint('2', tr('Penyimpanan Lokal (On-Device)', 'Local Storage'), tr('Semua data tagihan dan nama Anda murni disimpan dan dienkripsi di dalam memori internal HP Anda. Tidak ada data yang dikirim ke Cloud.', 'All your bills and name are purely saved and encrypted locally in your phone. No data is sent to the Cloud.'), textColor, subTextColor),
                  _buildPrivacyPoint('3', tr('Sistem Notifikasi Pintar', 'Smart Notification System'), tr('Pengingat tagihan berjalan langsung di latar belakang sistem HP Anda tanpa perlu menghubungi server eksternal.', 'Bill reminders run locally on your phone background without needing to contact external servers.'), textColor, subTextColor),
                  _buildPrivacyPoint('4', tr('Akses Pihak Ketiga', 'Third-Party Access'), tr('Kami menjamin 100% bahwa data finansial Anda tidak akan pernah dijual atau dibagikan ke pihak ketiga manapun untuk tujuan iklan.', 'We 100% guarantee that your financial data will never be sold or shared to any third parties for advertising.'), textColor, subTextColor),
                  _buildPrivacyPoint('5', tr('Kendali Penuh Pengguna', 'Full User Control'), tr('Anda memegang kendali mutlak. Anda bebas mengatur, mengubah, hingga memusnahkan seluruh catatan Anda kapan saja.', 'You hold absolute control. You are free to manage, edit, or destroy all your records anytime.'), textColor, subTextColor),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(tr('Zona Bahaya', 'Danger Zone'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))
                  ]),
                  const SizedBox(height: 12),
                  Text(tr('Menghapus semua data akan menghilangkan seluruh catatan Anda secara permanen. Tindakan ini tidak dapat dibatalkan.', 'Deleting all data will permanently remove all your records. This action cannot be undone.'), style: TextStyle(color: subTextColor, fontSize: 12, height: 1.5)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, 
                        foregroundColor: Colors.white, 
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (confirmCtx) => AlertDialog(
                            backgroundColor: cardBg,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                            title: Text(tr('Reboot Sistem?', 'System Reboot?'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                            content: Text(tr('Semua data langganan, profil, dan pengaturan akan terhapus. Lanjutkan?', 'All subscriptions, profiles, and settings will be deleted. Continue?'), style: TextStyle(color: subTextColor)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold))),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(confirmCtx);
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  
                                  if (context.mounted) {
                                    final provider = context.read<SubProvider>();
                                    final subsList = provider.subs.toList();
                                    for (var sub in subsList) {
                                      provider.removeSub(sub.id);
                                    }
                                    
                                    themeNotifier.value = 'Hitam';
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
                      },
                      child: Text(tr('Hapus Seluruh Data Aplikasi', 'Delete All App Data'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(String number, String title, String desc, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
            child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: subTextColor, fontSize: 12, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
