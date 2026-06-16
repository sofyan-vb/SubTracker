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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Selamat Datang di', 'Welcome to'), style: const TextStyle(fontSize: 18, color: Colors.black54)),
              Text('SubTracker', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -1.0)),
              const SizedBox(height: 24),

              Text(tr('Syarat & Ketentuan Penggunaan', 'Terms & Conditions of Use'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), 
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('Dengan menggunakan aplikasi SubTracker, Anda secara otomatis menyetujui seluruh ketentuan berikut:', 'By using the SubTracker application, you automatically agree to all of the following terms:'),
                          style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
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
                        const Divider(color: Colors.black12, thickness: 1),
                        const SizedBox(height: 16),
                        
                        Text(tr('Aplikasi ini dirancang dan dikembangkan secara independen.', 'This application is designed and developed independently.'), style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5)),
                        const SizedBox(height: 4),
                        Text(tr('Dibuat oleh: Sofyan Ibnu', 'Created by: Sofyan Ibnu'), style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(tr('Tahun Rilis: 2026', 'Release Year: 2026'), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.black12, thickness: 1),
                        const SizedBox(height: 16),
                        

                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _hasScrolledToBottom ? () => setState(() => _isAgreed = !_isAgreed) : () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Harap scroll sampai ke bawah terlebih dahulu', 'Please scroll to the bottom first')), behavior: SnackBarBehavior.floating));
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
                        side: BorderSide(color: _hasScrolledToBottom ? (_isAgreed ? const Color(0xFF2563EB) : Colors.black54) : Colors.black26, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr('Saya telah membaca dan menyetujui Syarat & Ketentuan', 'I have read and agree to the Terms & Conditions'),
                        style: TextStyle(color: _hasScrolledToBottom ? const Color(0xFF1E293B) : Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
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
                    child: Text(tr('Tolak', 'Decline'), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                              Text(tr('TERIMA & LANJUT', 'ACCEPT & NEXT'), style: TextStyle(color: _isAgreed ? Colors.white : Colors.white30, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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

  Widget _buildTermItem(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}