import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_choice_screen.dart'; 
import 'screens/terms_screen.dart'; 
import 'screens/dashboard_screen.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  languageNotifier.value = prefs.getString('app_lang') ?? 'EN';
  ringtoneNotifier.value = prefs.getString('app_ringtone') ?? 'ringtone_default';
  alarmNotifier.value = prefs.getString('app_alarm') ?? 'alarm_lagu';

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
        colorScheme: const ColorScheme.dark(primary: Color(0xFF0D9488), secondary: Color(0xFF0D9488)),
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

  
    if (name != null && name.trim().isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: false)),
        );
      }
    } else {
      
      await Future.delayed(const Duration(milliseconds: 8500));
      if (mounted) {
        if (hasAccepted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingChoiceScreen()),
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
                const Icon(Icons.language_rounded, size: 80, color: Color(0xFF0D9488)),
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
                      side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
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
                      side: const BorderSide(color: Color(0xFF0D9488), width: 1.5),
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

class _HandwritingWelcomeTextState extends State<HandwritingWelcomeText> with SingleTickerProviderStateMixin {
  String _currentText = "";
  late String _typingPart; 
  late String _staticPart; 
  int _charIndex = 0;
  Timer? _timer;
  bool _showStaticPart = false;
  late AnimationController _paintController;
  late Animation<double> _paintAnimation;

  @override
  void initState() {
    super.initState();
    
    _typingPart = tr('Selamat datang di', 'Welcome to');
    _staticPart = 'SubTracker';
    _paintController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _paintAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(CurvedAnimation(parent: _paintController, curve: Curves.easeInOutCubic));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _startAnimation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _paintController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
      if (_charIndex < _typingPart.length) {
        if (mounted) {
          setState(() {
            _currentText += _typingPart[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer?.cancel();
        if (mounted && !_showStaticPart) {
          setState(() {
            _showStaticPart = true;
          });
          _paintController.forward();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: _currentText,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontStyle: FontStyle.italic, fontFamily: 'cursive', height: 1.2),
              ),
            ],
          ),
        ),
        if (_showStaticPart)
          AnimatedBuilder(
            animation: _paintAnimation,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
                    stops: [
                      0.0,
                      (_paintAnimation.value).clamp(0.0, 1.0),
                      (_paintAnimation.value + 0.2).clamp(0.0, 1.0),
                      1.0,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: child,
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _staticPart,
                  style: const TextStyle(color: Color(0xFF0D9488), fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 1.5, height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}