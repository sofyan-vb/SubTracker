import 'package:flutter/material.dart';
import 'dashboard_screen.dart' show tr;
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@subtrackiq.com',
      query: 'subject=Bantuan%20SubTrack%20IQ',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    final List<Map<String, dynamic>> faqs = [
      {
        'q': tr('Bagaimana cara menambah langganan?', 'How to add a subscription?', '¿Cómo agregar una suscripción?'),
        'a': tr('Anda dapat menambah langganan dengan menekan tombol + di tengah bawah pada halaman utama.', 'You can add a subscription by pressing the + button at the bottom center on the main page.', 'Puede agregar una suscripción presionando el botón + en la parte inferior central de la página principal.'),
        'icon': Icons.add_circle_outline_rounded,
        'color': Colors.blue,
      },
      {
        'q': tr('Bagaimana cara mengedit langganan?', 'How to edit a subscription?', '¿Cómo editar una suscripción?'),
        'a': tr('Buka detail langganan dengan mengetuk salah satu item di halaman utama, lalu klik ikon pensil (Edit) di pojok kanan atas.', 'Open subscription details by tapping an item on the main page, then click the pencil (Edit) icon at the top right corner.', 'Abra los detalles de la suscripción tocando un elemento en la página principal, luego haga clic en el ícono de lápiz (Editar) en la esquina superior derecha.'),
        'icon': Icons.edit_note_rounded,
        'color': Colors.purple,
      },
      {
        'q': tr('Apakah data saya aman?', 'Is my data secure?', '¿Están mis datos seguros?'),
        'a': tr('Semua data langganan Anda disimpan secara lokal di perangkat Anda (Offline-First). Kami tidak mengirimkannya ke server mana pun kecuali Anda mencadangkannya sendiri.', 'All your subscription data is stored locally on your device (Offline-First). We do not send it to any server unless you back it up yourself.', 'Todos los datos de su suscripción se almacenan localmente en su dispositivo (primero sin conexión). No lo enviamos a ningún servidor a menos que usted mismo haga una copia de seguridad.'),
        'icon': Icons.security_rounded,
        'color': Colors.green,
      },
      {
        'q': tr('Bagaimana cara mengatur notifikasi pengingat?', 'How to set reminder notifications?', '¿Cómo configurar notificaciones de recordatorio?'),
        'a': tr('Buka menu Pengaturan > Suara Notifikasi & Alarm untuk memilih nada dering. Anda juga bisa menonaktifkan notifikasi melalui toggle di Pengaturan.', 'Go to Settings > Notification & Alarm Sound to choose a ringtone. You can also disable notifications via the toggle in Settings.', 'Vaya a Configuración > Notificación y sonido de alarma para elegir un tono de llamada. También puede desactivar las notificaciones a través del interruptor en Configuración.'),
        'icon': Icons.notifications_active_rounded,
        'color': Colors.pink,
      },
      {
        'q': tr('Bagaimana cara mengubah mata uang?', 'How to change the currency?', '¿Cómo cambiar la moneda?'),
        'a': tr('Buka halaman Pengaturan, lalu pilih menu Mata Uang untuk mengubahnya.', 'Go to the Settings page, then select the Currency menu to change it.', 'Vaya a la página Configuración, luego seleccione el menú Moneda para cambiarlo.'),
        'icon': Icons.currency_exchange_rounded,
        'color': Colors.orange,
      },
      {
        'q': tr('Bagaimana cara menghapus langganan?', 'How to delete a subscription?', '¿Cómo eliminar una suscripción?'),
        'a': tr('Geser langganan ke kiri pada daftar utama untuk menampilkan tombol hapus, atau buka detail langganan dan pilih hapus.', 'Swipe left on a subscription in the main list to reveal the delete button, or open subscription details and select delete.', 'Deslice el dedo hacia la izquierda en una suscripción en la lista principal para revelar el botón de eliminar, o abra los detalles de la suscripción y seleccione eliminar.'),
        'icon': Icons.delete_sweep_rounded,
        'color': Colors.redAccent,
      },
      {
        'q': tr('Apakah aplikasi ini membutuhkan internet?', 'Does this app require internet?', '¿Esta aplicación requiere internet?'),
        'a': tr('Aplikasi dapat berjalan 100% offline. Internet hanya diperlukan untuk update nilai tukar kurs harian dan membagikan cadangan (backup).', 'The app can run 100% offline. Internet is only required for daily exchange rate updates and sharing backups.', 'La aplicación puede ejecutarse 100% sin conexión. Solo se requiere Internet para las actualizaciones diarias del tipo de cambio y para compartir copias de seguridad.'),
        'icon': Icons.wifi_off_rounded,
        'color': Colors.teal,
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Pusat Bantuan', 'Help Center', 'Centro de ayuda'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                    ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)]
                    : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Butuh Bantuan?', 'Need Help?', '¿Necesitar ayuda?'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 6),
                        Text(tr('Temukan jawaban untuk pertanyaan umum di bawah ini.', 'Find answers to common questions below.', 'Encuentre respuestas a preguntas comunes a continuación.'), style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(tr('Pertanyaan Umum (FAQ)', 'Frequently Asked Questions', 'Preguntas frecuentes'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...faqs.map((faq) {
              final Color iconColor = faq['color'] as Color;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iconColor.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(faq['icon'] as IconData, color: iconColor, size: 22),
                    ),
                    title: Text(faq['q']!, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                    iconColor: iconColor,
                    collapsedIconColor: subTextColor,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(faq['a']!, style: TextStyle(color: subTextColor, height: 1.5, fontSize: 12)),
                      )
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.mark_email_unread_rounded, color: textColor.withOpacity(0.5), size: 32),
                  const SizedBox(height: 12),
                  Text(tr('Punya Pertanyaan Lain?', 'Have Other Questions?', '¿Tiene otras preguntas?'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(tr('Hubungi tim dukungan kami.', 'Contact our support team.', 'Póngase en contacto con nuestro equipo de soporte.'), style: TextStyle(color: subTextColor, fontSize: 12)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _launchEmail,
                    child: Text(tr('Hubungi Support', 'Contact Support', 'Contactar con soporte'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
}

