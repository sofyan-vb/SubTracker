import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:async';
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart'; 
import 'screens/terms_screen.dart'; 
import 'screens/dashboard_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  languageNotifier.value = prefs.getString('app_lang') ?? 'EN';

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

class GateKeeper extends StatefulWidget {
  const GateKeeper({super.key});
  @override
  State<GateKeeper> createState() => _GateKeeperState();
}

class _GateKeeperState extends State<GateKeeper> {
  bool _showLanguageSelect = false;

  @override
  void initState() {
    super.initState();
    _checkRoute();
  }

  Future<void> _checkRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    final hasAccepted = prefs.getBool('hasAcceptedTerms') ?? false;

    // LOGIKA PENGGUNA LAMA: Langsung Lewati Semua Layar Awal!
    if (name != null && name.trim().isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: false)),
        );
      }
    } else {
      // LOGIKA PENGGUNA BARU
      await Future.delayed(const Duration(milliseconds: 4500));
      if (mounted) {
        if (hasAccepted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: true)),
          ); 
        } else {
          setState(() {
            _showLanguageSelect = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLanguageSelect) {
      return Scaffold(
        backgroundColor: const Color(0xFF09090B),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language_rounded, size: 80, color: Color(0xFFD4FF00)),
                const SizedBox(height: 24),
                const Text('Choose Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                const Text('Pilih Bahasa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white54)),
                const SizedBox(height: 40),
                
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: const BorderSide(color: Color(0xFFD4FF00), width: 1.5),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      languageNotifier.value = 'EN';
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('app_lang', 'EN');
                      if (mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const TermsScreen()),
                        );
                      }
                    },
                    child: const Text('🇬🇧   English', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: const BorderSide(color: Color(0xFFD4FF00), width: 1.5),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      languageNotifier.value = 'ID';
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('app_lang', 'ID');
                      if (mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const TermsScreen()),
                        );
                      }
                    },
                    child: const Text('🇮🇩   Bahasa Indonesia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      backgroundColor: Color(0xFF09090B),
      body: Center(
        child: HandwritingWelcomeText(), 
      ),
    );
  }
}

class HandwritingWelcomeText extends StatefulWidget {
  const HandwritingWelcomeText({super.key});
  @override
  State<HandwritingWelcomeText> createState() => _HandwritingWelcomeTextState();
}

class _HandwritingWelcomeTextState extends State<HandwritingWelcomeText> {
  String _currentText = "";
  late String _fullText; 
  int _charIndex = 0;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    // PERBAIKAN: Menambahkan kata "di" pada teks animasi bahasa Indonesia
    _fullText = tr('Selamat datang di\nSubTracker', 'Welcome to\nSubTracker');
    _startAnimation();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_charIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _currentText += _fullText[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String cursivePart = "";
    String boldPart = "";

    // Logika Pemotongan Teks Otomatis berdasarkan Enter (\n)
    int splitIndex = _fullText.indexOf('\n') + 1;

    if (_currentText.length <= splitIndex) { 
      cursivePart = _currentText;
    } else {
      cursivePart = _fullText.substring(0, splitIndex);
      boldPart = _currentText.substring(splitIndex); 
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: cursivePart,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32, 
              fontStyle: FontStyle.italic,
              fontFamily: 'cursive', 
              height: 1.2,
            ),
          ),
          TextSpan(
            text: boldPart,
            style: const TextStyle(
              color: Color(0xFFD4FF00), 
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              height: 1.5, 
            ),
          ),
          TextSpan(
            text: _showCursor ? "|" : " ",
            style: const TextStyle(color: Colors.white70, fontSize: 32, fontWeight: FontWeight.w200),
          ),
        ],
      ),
    );
  }
}