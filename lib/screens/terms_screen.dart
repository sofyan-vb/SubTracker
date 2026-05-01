import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'splash_screen.dart'; 

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _isLoading = false;

  Future<void> _acceptTerms(BuildContext context) async {
    setState(() => _isLoading = true);

    bool hasInternet = false;

    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasInternet = true; 
      }
    } catch (_) {
      hasInternet = false; 
    }

    if (!context.mounted) return;

    if (hasInternet) {
      await Future.delayed(const Duration(milliseconds: 600)); // Jeda agar animasi loading terlihat
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasAcceptedTerms', true); 
      
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );
      }
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Gagal tersambung! Pastikan internet aktif.', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _declineTerms() {
    SystemNavigator.pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang di', style: TextStyle(fontSize: 18, color: Colors.white54)),
                    const Text('SubTracker', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.0)),
                    const SizedBox(height: 24),

                    const Text('Syarat & Ketentuan Penggunaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 12),
                    
                    
                    Container(
                      height: 400, 
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
                            const Text(
                              'Dengan menggunakan aplikasi SubTracker, Anda secara otomatis menyetujui seluruh ketentuan berikut:',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                            const SizedBox(height: 20),

                            
                            _buildTermItem('1', 'PENYIMPANAN DATA LOKAL', 'Semua data yang Anda masukkan ke dalam aplikasi ini (termasuk nama langganan, harga, tenggat waktu, dan pengaturan lainnya) disimpan secara eksklusif di dalam memori internal perangkat Anda. Kami tidak memiliki akses ke data tersebut, tidak mencadangkannya di cloud, dan tidak membagikannya ke pihak ketiga manapun.'),
                            _buildTermItem('2', 'IZIN SISTEM PERANGKAT', 'Untuk memastikan fitur pengingat berjalan dengan sempurna, aplikasi ini mewajibkan pengguna untuk memberikan izin akses Notifikasi dan Alarm Tepat Waktu (Exact Alarms). Anda bertanggung jawab untuk memastikan bahwa pengaturan penghemat baterai (Battery Saver) di perangkat Anda tidak memblokir aplikasi ini berjalan di latar belakang.'),
                            _buildTermItem('3', 'PEMBATASAN TANGGUNG JAWAB', 'SubTracker dirancang sebagai alat bantu produktivitas semata. Segala bentuk kerugian finansial, denda keterlambatan pembayaran langganan, atau pemutusan layanan yang disebabkan oleh kelalaian pengguna, kegagalan perangkat dalam memunculkan notifikasi, atau bug sistem, berada sepenuhnya di luar tanggung jawab pengembang.'),
                            _buildTermItem('4', 'PENGHAPUSAN APLIKASI', 'Karena data disimpan secara lokal, menghapus (uninstall) aplikasi dari perangkat Anda akan mengakibatkan hilangnya seluruh data catatan langganan secara permanen tanpa kemungkinan pemulihan.'),
                            _buildTermItem('5', 'PEMBARUAN KETENTUAN', 'Pengembang berhak untuk mengubah, memodifikasi, atau memperbarui Syarat & Ketentuan ini kapan saja tanpa pemberitahuan sebelumnya, demi menyesuaikan dengan kebijakan keamanan atau penambahan fitur baru.'),
                            
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12, thickness: 1),
                            const SizedBox(height: 16),

                          
                            const Text('Aplikasi ini dirancang dan dikembangkan secara independen.', style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
                            const SizedBox(height: 4),
                            const Text('Dibuat oleh: Sofyan Ibnu', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text('Tahun Rilis: 2026', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white12, thickness: 1),
                            const SizedBox(height: 16),
                            
                            const Text(
                              'Harap klik "Terima & Lanjut" di bawah jika Anda memahami dan menyetujui seluruh kebijakan di atas.',
                              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(color: Color(0xFF09090B), border: Border(top: BorderSide(color: Colors.white10))),
              child: Row(
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
                      child: const Text('Tolak', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4FF00),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isLoading ? null : () => _acceptTerms(context),
                      child: _isLoading ? const WaveDotLoading() : const Text('TERIMA & LANJUT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        
          Text(
            '$number.',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(width: 12),
          
         
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
         
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                
                
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class WaveDotLoading extends StatefulWidget {
  const WaveDotLoading({super.key});
  @override
  State<WaveDotLoading> createState() => _WaveDotLoadingState();
}

class _WaveDotLoadingState extends State<WaveDotLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value * 2 * pi;
        double offset = sin(t + (index * 1.5)) * 4.0; 
        return Transform.translate(
          offset: Offset(0, offset),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4), 
            width: 8, 
            height: 8, 
            decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [_buildDot(0), _buildDot(1), _buildDot(2)]
    );
  }
}