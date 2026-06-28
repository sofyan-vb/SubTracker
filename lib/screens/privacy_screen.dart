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
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
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
              tr('Privasi & Keamanan', 'Privacy & Security', 'Privacidad y seguridad'),
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
                  Text(tr('Perlindungan Data Anda', 'Your Data Protection', 'Tu protección de datos'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(tr('Di SubTrack IQ, kami menganggap privasi pengguna sebagai hal yang mutlak. Aplikasi ini dirancang menggunakan arsitektur Offline-First.', 'At SubTrack IQ, we take user privacy absolutely seriously. This app is designed using an Offline-First architecture.', 'En SubTrack IQ, nos tomamos absolutamente en serio la privacidad del usuario. Esta aplicación está diseñada utilizando una arquitectura sin conexión.'), style: TextStyle(color: subTextColor, height: 1.5, fontSize: 13)),
                  const SizedBox(height: 24),
                  
                  _buildPrivacyPoint('1', tr('Pengumpulan Data', 'Data Collection', 'Recopilación de datos'), tr('SubTrack IQ tidak mengumpulkan atau merekam data identitas pribadi Anda. Anda menggunakan aplikasi ini secara anonim.', 'SubTrack IQ does not collect your personal data. You use this app anonymously.', 'SubTrack IQ no recopila sus datos personales. Utiliza esta aplicación de forma anónima.'), textColor, subTextColor),
                  _buildPrivacyPoint('2', tr('Penyimpanan Lokal (On-Device)', 'Local Storage', 'Almacenamiento local'), tr('Semua data tagihan dan nama Anda murni disimpan dan dienkripsi di dalam memori internal HP Anda. Tidak ada data yang dikirim ke Cloud.', 'All your bills and name are purely saved and encrypted locally in your phone. No data is sent to the Cloud.', 'Todas sus facturas y su nombre se guardan y cifran exclusivamente localmente en su teléfono. No se envían datos a la nube.'), textColor, subTextColor),
                  _buildPrivacyPoint('3', tr('Sistem Notifikasi Pintar', 'Smart Notification System', 'Sistema de notificación inteligente'), tr('Pengingat tagihan berjalan langsung di latar belakang sistem HP Anda tanpa perlu menghubungi server eksternal.', 'Bill reminders run locally on your phone background without needing to contact external servers.', 'Los recordatorios de facturas se ejecutan localmente en el fondo de su teléfono sin necesidad de contactar servidores externos.'), textColor, subTextColor),
                  _buildPrivacyPoint('4', tr('Akses Pihak Ketiga', 'Third-Party Access', 'Acceso de terceros'), tr('Kami menjamin 100% bahwa data finansial Anda tidak akan pernah dijual atau dibagikan ke pihak ketiga manapun untuk tujuan iklan.', 'We 100% guarantee that your financial data will never be sold or shared to any third parties for advertising.', 'Garantizamos al 100% que sus datos financieros nunca serán vendidos ni compartidos con terceros con fines publicitarios.'), textColor, subTextColor),
                  _buildPrivacyPoint('5', tr('Kendali Penuh Pengguna', 'Full User Control', 'Control total del usuario'), tr('Anda memegang kendali mutlak. Anda bebas mengatur, mengubah, hingga memusnahkan seluruh catatan Anda kapan saja.', 'You hold absolute control. You are free to manage, edit, or destroy all your records anytime.', 'Tienes el control absoluto. Eres libre de administrar, editar o destruir todos tus registros en cualquier momento.'), textColor, subTextColor),
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
