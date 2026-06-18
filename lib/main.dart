import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'providers/subscription_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/terms_screen.dart'; 
import 'screens/dashboard_screen.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await NotificationService.init();

  final prefs = await SharedPreferences.getInstance();
  languageNotifier.value = prefs.getString('app_lang') ?? 'EN';
  ringtoneNotifier.value = prefs.getString('app_ringtone') ?? 'ringtone_default';
  alarmNotifier.value = prefs.getString('app_alarm') ?? 'alarm_lagu';
  
  final String savedTheme = prefs.getString('app_theme_mode') ?? 'System';
  if (savedTheme == 'Dark') {
    themeModeNotifier.value = ThemeMode.dark;
  } else if (savedTheme == 'Light') {
    themeModeNotifier.value = ThemeMode.light;
  } else {
    themeModeNotifier.value = ThemeMode.system;
  }

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'SubTracker',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7FA), 
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF1E293B)),
              titleTextStyle: TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB), 
              secondary: Color(0xFF2563EB),
              surface: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F172A), 
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6), // Blue 500
              secondary: Color(0xFF3B82F6),
              surface: Color(0xFF1E293B), // Slate 800
              onSurface: Colors.white,
            ),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          home: const GateKeeper(), 
        );
      }
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
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _checkRoute();
  }

  Future<void> _checkRoute() async {
    await context.read<SubProvider>().ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    final budget = prefs.getString('monthly_budget');
    final hasAccepted = prefs.getBool('hasAcceptedTerms') ?? false;

  
    if (budget != null && budget.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashScreen(isNewUser: false)),
        );
      }
    } else {
      
      await Future.delayed(const Duration(milliseconds: 6500));
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
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.language_rounded, size: 80, color: Color(0xFF2563EB)),
                    const SizedBox(height: 24),
                    const Text('Choose Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    const Text('Pilih Bahasa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(height: 48),

                    InkWell(
                      onTap: () => setState(() => _selectedLanguage = 'EN'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'EN' ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                          border: Border.all(color: _selectedLanguage == 'EN' ? const Color(0xFF2563EB) : Colors.black12, width: 1.5),
                        ),
                        child: Center(
                          child: Text('🇬🇧   English', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _selectedLanguage == 'EN' ? Colors.white : const Color(0xFF1E293B), letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => setState(() => _selectedLanguage = 'ID'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == 'ID' ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
                          border: Border.all(color: _selectedLanguage == 'ID' ? const Color(0xFF2563EB) : Colors.black12, width: 1.5),
                        ),
                        child: Center(
                          child: Text('🇮🇩   Bahasa Indonesia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _selectedLanguage == 'ID' ? Colors.white : const Color(0xFF1E293B), letterSpacing: 1.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
                if (_selectedLanguage != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        languageNotifier.value = _selectedLanguage!;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('app_lang', _selectedLanguage!);
                        if (mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TermsScreen()),
                          );
                        }
                      },
                      child: Text(_selectedLanguage == 'EN' ? 'NEXT' : 'LANJUT', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
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
                  style: const TextStyle(color: Color(0xFF2563EB), fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 1.5, height: 1.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}