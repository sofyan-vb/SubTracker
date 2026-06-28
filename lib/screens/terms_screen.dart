import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'splash_screen.dart';
import 'dashboard_screen.dart'; 

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _isAgreed = false;
  late AnimationController _arrowCtrl;
  late Animation<double> _arrowSlide;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _arrowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _arrowSlide = Tween<double>(begin: 0.0, end: 6.0).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 20) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  Future<void> _acceptTerms(BuildContext context) async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 200)); 
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedTerms', true); 
    
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: true)),
      );
      setState(() => _isLoading = false); 
    }
  }

  void _declineTerms() {
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final borderCol = isDark ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Selamat Datang di', 'Welcome to', 'Bienvenido a'), style: TextStyle(fontSize: 18, color: subTextColor)),
              Text('SubTrack IQ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -1.0)),
              const SizedBox(height: 24),

              Text(tr('Syarat & Ketentuan Penggunaan', 'Terms & Conditions of Use', 'Términos y condiciones de uso'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Dengan menggunakan aplikasi SubTrack IQ, Anda secara otomatis menyetujui seluruh ketentuan berikut:', 'By using the SubTrack IQ application, you automatically agree to all of the following terms:', 'Al utilizar la aplicación SubTrack IQ, automáticamente acepta todos los términos siguientes:'),
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 20),

                        _buildTermItem(
                          '1', 
                          tr('PENYIMPANAN DATA LOKAL', 'LOCAL DATA STORAGE', 'ALMACENAMIENTO DE DATOS LOCALES'), 
                          tr('Semua data yang Anda masukkan ke dalam aplikasi ini (termasuk nama langganan, harga, tenggat waktu, dan pengaturan lainnya) disimpan secara eksklusif di dalam memori internal perangkat Anda. Kami tidak memiliki akses ke data tersebut, tidak mencadangkannya di cloud, dan tidak membagikannya ke pihak ketiga manapun.', 'All data you enter into this app (including subscription names, prices, deadlines, and other settings) is stored exclusively in your device\'s internal memory. We do not have access to this data, do not back it up to the cloud, and do not share it with any third parties.', 'Todos los datos que ingresa en esta aplicación (incluidos los nombres de las suscripciones, los precios, los plazos y otras configuraciones) se almacenan exclusivamente en la memoria interna de su dispositivo. No tenemos acceso a estos datos, no realizamos copias de seguridad de ellos en la nube y no los compartimos con terceros.'),
                          isDark
                        ),
                        _buildTermItem(
                          '2', 
                          tr('IZIN SISTEM PERANGKAT', 'DEVICE SYSTEM PERMISSIONS', 'PERMISOS DEL SISTEMA DEL DISPOSITIVO'), 
                          tr('Untuk memastikan fitur pengingat berjalan dengan sempurna, aplikasi ini mewajibkan pengguna untuk memberikan izin akses Notifikasi dan Alarm Tepat Waktu (Exact Alarms). Anda bertanggung jawab untuk memastikan bahwa pengaturan penghemat baterai (Battery Saver) di perangkat Anda tidak memblokir aplikasi ini berjalan di latar belakang.', 'To ensure the reminder feature runs perfectly, this app requires users to grant access to Notifications and Exact Alarms. You are responsible for ensuring that the Battery Saver settings on your device do not block this app from running in the background.', 'Para garantizar que la función de recordatorio funcione perfectamente, esta aplicación requiere que los usuarios otorguen acceso a Notificaciones y Alarmas Exactas. Usted es responsable de garantizar que la configuración de Ahorro de batería en su dispositivo no bloquee la ejecución de esta aplicación en segundo plano.'),
                          isDark
                        ),
                        _buildTermItem(
                          '3', 
                          tr('PEMBATASAN TANGGUNG JAWAB', 'LIMITATION OF LIABILITY', 'LIMITACIÓN DE RESPONSABILIDAD'), 
                          tr('SubTrack IQ dirancang sebagai alat bantu produktivitas semata. Segala bentuk kerugian finansial, denda keterlambatan pembayaran langganan, atau pemutusan layanan yang disebabkan oleh kelalaian pengguna, kegagalan perangkat dalam memunculkan notifikasi, atau bug sistem, berada sepenuhnya di luar tanggung jawab pengembang.', 'SubTrack IQ is designed solely as a productivity tool. Any form of financial loss, subscription late payment fines, or service termination caused by user negligence, device failure to show notifications, or system bugs, are entirely beyond the developer\'s responsibility.', 'SubTrack IQ está diseñado únicamente como una herramienta de productividad. Cualquier forma de pérdida financiera, multas por pagos atrasados ​​de suscripción o terminación del servicio causada por negligencia del usuario, falla del dispositivo para mostrar notificaciones o errores del sistema, están completamente fuera de la responsabilidad del desarrollador.'),
                          isDark
                        ),
                        _buildTermItem(
                          '4', 
                          tr('PENGHAPUSAN APLIKASI', 'APP UNINSTALLATION', 'DESINSTALACIÓN DE LA APLICACIÓN'), 
                          tr('Karena data disimpan secara lokal, menghapus (uninstall) aplikasi dari perangkat Anda akan mengakibatkan hilangnya seluruh data catatan langganan secara permanen tanpa kemungkinan pemulihan.', 'Because data is stored locally, uninstalling the app from your device will result in the permanent loss of all subscription record data without the possibility of recovery.', 'Debido a que los datos se almacenan localmente, desinstalar la aplicación de su dispositivo resultará en la pérdida permanente de todos los datos del registro de suscripción sin posibilidad de recuperación.'),
                          isDark
                        ),
                        _buildTermItem(
                          '5', 
                          tr('PEMBARUAN KETENTUAN', 'TERMS UPDATE', 'ACTUALIZACIÓN DE TÉRMINOS'), 
                          tr('Pengembang berhak untuk mengubah, memodifikasi, atau memperbarui Syarat & Ketentuan ini kapan saja tanpa pemberitahuan sebelumnya, demi menyesuaikan dengan kebijakan keamanan atau penambahan fitur baru.', 'The developer reserves the right to change, modify, or update these Terms & Conditions at any time without prior notice, to adapt to security policies or the addition of new features.', 'El desarrollador se reserva el derecho de cambiar, modificar o actualizar estos Términos y Condiciones en cualquier momento sin previo aviso, para adaptarse a políticas de seguridad o la incorporación de nuevas funciones.'),
                          isDark
                        ),
                        
                        const SizedBox(height: 16),
                        Divider(color: borderCol, thickness: 1),
                        const SizedBox(height: 16),
                        
                        Text(tr('Aplikasi ini dirancang dan dikembangkan secara independen.', 'This application is designed and developed independently.', 'Esta aplicación está diseñada y desarrollada de forma independiente.'), style: TextStyle(color: subTextColor, fontSize: 12, height: 1.5)),
                        const SizedBox(height: 4),
                        Text(tr('Dibuat oleh: Sofyan Ibnu', 'Created by: Sofyan Ibnu', 'Creado por: Sofyan Ibnu'), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(tr('Tahun Rilis: 2026', 'Release Year: 2026', 'Año de lanzamiento: 2026'), style: TextStyle(color: subTextColor, fontSize: 12)),
                        const SizedBox(height: 16),
                        Divider(color: borderCol, thickness: 1),
                        const SizedBox(height: 16),
                        

                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _hasScrolledToBottom ? () => setState(() => _isAgreed = !_isAgreed) : () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Harap scroll sampai ke bawah terlebih dahulu', 'Please scroll to the bottom first', 'Por favor, desplácese hacia abajo primero.')), behavior: SnackBarBehavior.floating));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        onChanged: _hasScrolledToBottom ? (value) => setState(() => _isAgreed = value ?? false) : null,
                        activeColor: const Color(0xFF2563EB),
                        checkColor: Colors.white,
                        side: BorderSide(color: _hasScrolledToBottom ? (_isAgreed ? const Color(0xFF2563EB) : subTextColor) : borderCol, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('Saya telah membaca dan menyetujui Syarat & Ketentuan', 'I have read and agree to the Terms & Conditions', 'He leído y acepto los Términos y condiciones'),
                        style: TextStyle(color: _hasScrolledToBottom ? textColor : subTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : _declineTerms,
                    child: Text(tr('Tolak', 'Decline', 'Rechazar'), style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: (_isLoading || !_isAgreed) ? null : () => _acceptTerms(context),
                    child: _isLoading 
                        ? Padding(padding: const EdgeInsets.only(top: 4.0), child: WavyDotsProgressIndicator(color: Colors.white, dotSize: 5.0))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(tr('TERIMA & LANJUT', 'ACCEPT & NEXT', 'ACEPTAR Y SIGUIENTE'), style: TextStyle(color: _isAgreed ? Colors.white : Colors.white30, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String number, String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}