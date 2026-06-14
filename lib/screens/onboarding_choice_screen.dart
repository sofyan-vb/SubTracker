import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/subscription_provider.dart';
import '../utils/toast_utils.dart';
import 'splash_screen.dart';
import 'dashboard_screen.dart';

class OnboardingChoiceScreen extends StatelessWidget {
  const OnboardingChoiceScreen({super.key});

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
              const Icon(Icons.cloud_sync_rounded, size: 80, color: Color(0xFF0D9488)),
              const SizedBox(height: 24),
              const Text('Mulai Perjalanan', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
              const Text('Start Your Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white54)),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.file_download_outlined, color: Color(0xFF0D9488)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    String result = await context.read<SubProvider>().importBackup();
                    if (result == 'success') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_name', 'User'); 
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
                      }
                    } else if (result != 'cancelled' && context.mounted) {
                      ToastUtils.show(context, 'Gagal memulihkan data: $result');
                    }
                  },
                  label: const Text('Pulihkan Data (JSON)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: true)),
                    );
                  },
                  label: const Text('Pengguna Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
