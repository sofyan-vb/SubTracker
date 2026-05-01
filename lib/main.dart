// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart'; 
import 'screens/terms_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF09090B), elevation: 0),
        colorScheme: const ColorScheme.dark(primary: Color(0xFFD4FF00), secondary: Color(0xFFD4FF00)),
        useMaterial3: true,
      ),
      home: const GateKeeper(), 
    );
  }
}

// =================================================================
// GATEKEEPER: ANIMASI 6 DETIK (SANGAT LAMBAT & MAJESTIK)
// =================================================================
class GateKeeper extends StatefulWidget {
  const GateKeeper({super.key});
  @override
  State<GateKeeper> createState() => _GateKeeperState();
}

class _GateKeeperState extends State<GateKeeper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  final String _title = "YANZ";
  
  // Array untuk menyimpan animasi per huruf
  final List<Animation<double>> _letterFades = [];
  final List<Animation<Offset>> _letterSlides = [];
  final List<Animation<double>> _letterScales = [];
  
  // Animasi untuk teks "STUDIO" (Sekarang ada 3 efek sekaligus!)
  late Animation<double> _fadeStudio;
  late Animation<Offset> _slideStudio;
  late Animation<double> _scaleStudio; // Tambahan efek membesar

  @override
  void initState() {
    super.initState();
    
    // Waktu DIPERLAMBAT EKSTREM: 6 detik penuh! (6000 milliseconds)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), 
    );

    // Hitungan jeda per huruf
    double stepDelay = 0.15; // Jeda masuk antar huruf
    double letterDuration = 0.30; // Durasi masing-masing huruf bergerak

    for (int i = 0; i < _title.length; i++) {
      double start = i * stepDelay;
      double end = start + letterDuration;
      if (end > 1.0) end = 1.0;

      _letterFades.add(Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeIn)),
      ));

      _letterSlides.add(Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ));

      _letterScales.add(Tween<double>(begin: 1.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      ));
    }

    // ANIMASI "STUDIO" DI-UPGRADE (Mulai di titik 65% sampai 100% dari total 6 detik)
    // 1. Slide Up dari bawah
    _slideStudio = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic)),
    );
    // 2. Fade In memudar masuk
    _fadeStudio = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0, curve: Curves.easeInOut)),
    );
    // 3. Scale membesar perlahan (efek bernapas)
    _scaleStudio = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack)),
    );

    // Nyalakan Mesin Animasi!
    _controller.forward();
    
    _checkRoute();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkRoute() async {
    // Ditahan total selama 8.5 detik! (6 dtk animasi + 2.5 dtk diam dinikmati)
    await Future.delayed(const Duration(milliseconds: 8500));

    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('hasAcceptedTerms') ?? false;

    if (mounted) {
      if (hasAccepted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen()), 
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TermsScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BARISAN HURUF Y - A - N - Z
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_title.length, (index) {
                return FadeTransition(
                  opacity: _letterFades[index],
                  child: SlideTransition(
                    position: _letterSlides[index],
                    child: ScaleTransition(
                      scale: _letterScales[index],
                      child: Padding(
                        padding: EdgeInsets.only(right: index == _title.length - 1 ? 0 : 18.0),
                        child: Text(
                          _title[index],
                          style: const TextStyle(
                            fontSize: 48, 
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 12), 
            
            // TEKS AKSEN: "STUDIO" (Sekarang punya efek Scale, Slide, dan Fade!)
            FadeTransition(
              opacity: _fadeStudio,
              child: SlideTransition(
                position: _slideStudio,
                child: ScaleTransition(
                  scale: _scaleStudio,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FF00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4FF00).withOpacity(0.3)),
                    ),
                    child: const Text(
                      'STUDIO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4FF00),
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}