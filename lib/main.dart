import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
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


class GateKeeper extends StatefulWidget {
  const GateKeeper({super.key});
  @override
  State<GateKeeper> createState() => _GateKeeperState();
}

class _GateKeeperState extends State<GateKeeper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<double> _fadeY, _fadeA, _fadeN, _fadeZ;
  late Animation<Offset> _slideY, _slideA, _slideN, _slideZ;
  late Animation<double> _scaleY, _scaleA, _scaleN, _scaleZ;
  
  late Animation<double> _fadeStudio;
  late Animation<Offset> _slideStudio;
  late Animation<double> _scaleStudio;

  late Animation<double> _fadeBackground;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), 
    );

    _fadeY = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeIn)));
    _slideY = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic)));
    _scaleY = Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic)));

    _fadeA = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.45, curve: Curves.easeIn)));
    _slideA = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.45, curve: Curves.easeOutCubic)));
    _scaleA = Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.45, curve: Curves.easeOutCubic)));

    _fadeN = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.65, curve: Curves.easeIn)));
    _slideN = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.65, curve: Curves.easeOutCubic)));
    _scaleN = Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.65, curve: Curves.easeOutCubic)));

    _fadeZ = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.85, curve: Curves.easeIn)));
    _slideZ = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic)));
    _scaleZ = Tween<double>(begin: 1.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic)));

    _fadeStudio = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeInOut)));
    _slideStudio = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic)));
    _scaleStudio = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeOutBack)));

    _fadeBackground = Tween<double>(begin: 0.0, end: 0.08).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.8, curve: Curves.easeInOut)),
    );

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
    
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _controller.forward();
          _playSyncSounds(); 
          _checkRoute(); 
        }
      });
    });
  }

  void _playSyncSounds() async {
    SystemSound.play(SystemSoundType.click); 
    await Future.delayed(const Duration(milliseconds: 1200));
    SystemSound.play(SystemSoundType.click); 
    await Future.delayed(const Duration(milliseconds: 1200));
    SystemSound.play(SystemSoundType.click); 
    await Future.delayed(const Duration(milliseconds: 1200));
    SystemSound.play(SystemSoundType.click); 
    await Future.delayed(const Duration(milliseconds: 1200));
    SystemSound.play(SystemSoundType.click); 
    await Future.delayed(const Duration(milliseconds: 150)); 
    SystemSound.play(SystemSoundType.click); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkRoute() async {
    await Future.delayed(const Duration(milliseconds: 8500));
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('hasAcceptedTerms') ?? false;
    if (mounted) {
      if (hasAccepted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SplashScreen())); 
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TermsScreen()));
      }
    }
  }

  Widget _buildLetter(String letter, Animation<double> fade, Animation<Offset> slide, Animation<double> scale, bool isLast) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(
          scale: scale,
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 18.0),
            child: Text(
              letter,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
        
          Center(
            child: FadeTransition(
              opacity: _fadeBackground,
              child: SizedBox(
                
                width: MediaQuery.of(context).size.width * 0.9,
                child: FittedBox(
                  fit: BoxFit.scaleDown, 
                  child: Text(
                    'YANZ',
                    style: TextStyle(
                      fontSize: 160, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8, 
                      height: 1.0, 
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3 
                        ..color = Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),

          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLetter('Y', _fadeY, _slideY, _scaleY, false),
                    _buildLetter('A', _fadeA, _slideA, _scaleA, false),
                    _buildLetter('N', _fadeN, _slideN, _scaleN, false),
                    _buildLetter('Z', _fadeZ, _slideZ, _scaleZ, true),
                  ],
                ),
                const SizedBox(height: 12), 
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD4FF00), letterSpacing: 6.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeStudio, 
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'SYSTEM BOOT • V 1.0.0',
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white38, 
                      letterSpacing: 4.0
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}