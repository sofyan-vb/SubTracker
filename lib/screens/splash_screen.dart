import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io'; 
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;

  Future<void> _startApp() async {
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

    if (!mounted) return;

    if (hasInternet) {
      await Future.delayed(const Duration(milliseconds: 600));
      
     
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4FF00),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Center(
                  child: Text('S', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1)),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('SubTracker', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.0)),
              const SizedBox(height: 48),
              
              _buildFeatureItem(icon: Icons.edit_document, title: 'Catat Semua Layanan', desc: 'Kumpulkan semua tagihan langgananmu di satu tempat agar lebih rapi.'),
              const SizedBox(height: 28),
              _buildFeatureItem(icon: Icons.notifications_active_rounded, title: 'Pengingat Otomatis', desc: 'Tidak ada lagi denda telat bayar karena lupa waktu.'),
              const SizedBox(height: 28),
              _buildFeatureItem(icon: Icons.insert_chart_rounded, title: 'Pantau Pengeluaran', desc: 'Analisis cerdas kemana uangmu habis setiap bulannya.'),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4FF00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _startApp, 
                  child: _isLoading ? const WaveDotLoading() : const Text('MULAI SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String title, required String desc}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1C), borderRadius: BorderRadius.circular(24)),
          child: Icon(icon, color: const Color(0xFFD4FF00), size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
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
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]);
  }
}