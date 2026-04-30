// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; 

class SplashScreen extends StatefulWidget {
  // PENTING: Jangan hapus super.key ini, tapi biarkan class ini tanpa 'const' saat dipanggil di main.dart
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Mengatur berapa lama loading berputar sebelum pindah ke Dashboard (3000 ms = 3 detik)
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          // Transisi memudar (fade) bisa ditambahkan di sini nanti jika ingin lebih halus
          MaterialPageRoute(builder: (context) => const DashboardScreen()), 
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Latar belakang hitam pekat
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Logo SubTracker
            Image.asset(
              'assets/splash.png',
              width: 250, 
              fit: BoxFit.contain,
            ),
            
            // Jarak antara logo dan animasi loading
            const SizedBox(height: 70), 
            
            // 2. Animasi Loading Neon (Berputar)
            const SizedBox(
              width: 45,
              height: 45,
              child: CircularProgressIndicator(
                color: Color(0xFFD4FF00), // Warna Hijau Neon
                strokeWidth: 4,           // Ketebalan garis
                strokeCap: StrokeCap.round, // Ujung garis membulat agar lebih elegan
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 3. Teks Status Loading
            const Text(
              'MEMUAT DATA...',
              style: TextStyle(
                color: Color(0xFFD4FF00), // Senada dengan animasi
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0, // Jarak antar huruf dijauhkan agar terlihat futuristik
              ),
            ),
          ],
        ),
      ),
    );
  }
}