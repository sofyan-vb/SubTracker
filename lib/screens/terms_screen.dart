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

class _TermsScreenState extends State<TermsScreen> {
  bool _isLoading = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Selamat Datang di', 'Welcome to'), style: const TextStyle(fontSize: 18, color: Colors.white54)),
              const Text('SubTracker', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.0)),
              const SizedBox(height: 24),

              Text(tr('Syarat & Ketentuan Penggunaan', 'Terms & Conditions of Use'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Dengan menggunakan aplikasi SubTracker, Anda secara otomatis menyetujui seluruh ketentuan berikut:', 'By using the SubTracker application, you automatically agree to all of the following terms:'),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 20),

                        _buildTermItem(
                          '1', 
                          tr('PENYIMPANAN DATA LOKAL', 'LOCAL DATA STORAGE'), 
                          tr('Semua data yang Anda masukkan ke dalam aplikasi ini (termasuk nama langganan, harga, tenggat waktu, dan pengaturan lainnya) disimpan secara eksklusif di dalam memori internal perangkat Anda. Kami tidak memiliki akses ke data tersebut, tidak mencadangkannya di cloud, dan tidak membagikannya ke pihak ketiga manapun.', 
                             'All data you enter into this app (including subscription names, prices, deadlines, and other settings) is stored exclusively in your device\'s internal memory. We do not have access to this data, do not back it up to the cloud, and do not share it with any third parties.')
                        ),
                        _buildTermItem(
                          '2', 
                          tr('IZIN SISTEM PERANGKAT', 'DEVICE SYSTEM PERMISSIONS'), 
                          tr('Untuk memastikan fitur pengingat berjalan dengan sempurna, aplikasi ini mewajibkan pengguna untuk memberikan izin akses Notifikasi dan Alarm Tepat Waktu (Exact Alarms). Anda bertanggung jawab untuk memastikan bahwa pengaturan penghemat baterai (Battery Saver) di perangkat Anda tidak memblokir aplikasi ini berjalan di latar belakang.', 
                             'To ensure the reminder feature runs perfectly, this app requires users to grant access to Notifications and Exact Alarms. You are responsible for ensuring that the Battery Saver settings on your device do not block this app from running in the background.')
                        ),
                        _buildTermItem(
                          '3', 
                          tr('PEMBATASAN TANGGUNG JAWAB', 'LIMITATION OF LIABILITY'), 
                          tr('SubTracker dirancang sebagai alat bantu produktivitas semata. Segala bentuk kerugian finansial, denda keterlambatan pembayaran langganan, atau pemutusan layanan yang disebabkan oleh kelalaian pengguna, kegagalan perangkat dalam memunculkan notifikasi, atau bug sistem, berada sepenuhnya di luar tanggung jawab pengembang.', 
                             'SubTracker is designed solely as a productivity tool. Any form of financial loss, subscription late payment fines, or service termination caused by user negligence, device failure to show notifications, or system bugs, are entirely beyond the developer\'s responsibility.')
                        ),
                        _buildTermItem(
                          '4', 
                          tr('PENGHAPUSAN APLIKASI', 'APP UNINSTALLATION'), 
                          tr('Karena data disimpan secara lokal, menghapus (uninstall) aplikasi dari perangkat Anda akan mengakibatkan hilangnya seluruh data catatan langganan secara permanen tanpa kemungkinan pemulihan.', 
                             'Because data is stored locally, uninstalling the app from your device will result in the permanent loss of all subscription record data without the possibility of recovery.')
                        ),
                        _buildTermItem(
                          '5', 
                          tr('PEMBARUAN KETENTUAN', 'TERMS UPDATE'), 
                          tr('Pengembang berhak untuk mengubah, memodifikasi, atau memperbarui Syarat & Ketentuan ini kapan saja tanpa pemberitahuan sebelumnya, demi menyesuaikan dengan kebijakan keamanan atau penambahan fitur baru.', 
                             'The developer reserves the right to change, modify, or update these Terms & Conditions at any time without prior notice, to adapt to security policies or the addition of new features.')
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12, thickness: 1),
                        const SizedBox(height: 16),
                        
                        Text(tr('Aplikasi ini dirancang dan dikembangkan secara independen.', 'This application is designed and developed independently.'), style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
                        const SizedBox(height: 4),
                        Text(tr('Dibuat oleh: Sofyan Ibnu', 'Created by: Sofyan Ibnu'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(tr('Tahun Rilis: 2026', 'Release Year: 2026'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12, thickness: 1),
                        const SizedBox(height: 16),
                        
                        Text(
                          tr('Harap klik "Terima & Lanjut" di bawah jika Anda memahami dan menyetujui seluruh kebijakan di atas.', 'Please click "Accept & Next" below if you understand and agree to all the policies above.'),
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : _declineTerms,
                      child: Text(tr('Tolak', 'Decline'), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488), padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : () => _acceptTerms(context),
                      child: Text(tr('TERIMA & LANJUT', 'ACCEPT & NEXT'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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

  Widget _buildTermItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}