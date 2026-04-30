// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import file yang dibutuhkan
import 'screens/splash_screen.dart'; 
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart'; // <-- Import layanan notifikasi

// Ubah main menjadi Future<void> main() async
Future<void> main() async {
  // 1. Wajib: Pastikan inti Flutter sudah siap sebelum memanggil layanan sistem (seperti notifikasi)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. KUNCI KONTAK: Nyalakan mesin notifikasi saat aplikasi baru saja dibuka!
  await NotificationService.init();

  // 3. Jalankan aplikasi seperti biasa
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTracker',
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "DEBUG" di pojok kanan atas
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF09090B),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4FF00), // Hijau Neon andalan kita
          secondary: Color(0xFFD4FF00),
        ),
        useMaterial3: true,
      ),
      // Mengarah ke SplashScreen yang sudah kita buat animasinya
      home: const SplashScreen(), 
    );
  }
}