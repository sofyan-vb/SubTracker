// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; 
import 'dart:async'; 
import 'dart:ui'; // Diperlukan untuk ImageFilter (efek kaca/blur asli)
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

enum SplashState { welcomeNew, welcomeReturning, onboarding, form, loading } 

class SplashScreen extends StatefulWidget {
  final bool isNewUser;
  const SplashScreen({super.key, this.isNewUser = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashState _state;
  late PageController _pageController;
  int _onboardingPageIndex = 0;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _budgetCtrl = TextEditingController();
  String _selectedGoal = '';
  
  String _savedName = ''; 

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    // PEMISAHAN LOGIKA: Baru vs Sudah Pernah Install
    if (widget.isNewUser) {
      _state = SplashState.onboarding; // Langsung masuk ke onboarding slide untuk pengguna baru
      _onboardingPageIndex = 0;
    } else {
      _state = SplashState.welcomeReturning;
      _loadReturningUser();
    }
  }

  Future<void> _loadReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('user_name') ?? 'SubTracker';
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _processEntry() async {
    if (_state == SplashState.form) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr('Nama panggilan tidak boleh kosong!', 'Nickname cannot be empty!'), 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ), 
            backgroundColor: Colors.redAccent
          ),
        );
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('monthly_budget', _budgetCtrl.text.trim());
      await prefs.setString('financial_goal', _selectedGoal);
      userNameNotifier.value = _nameCtrl.text.trim();
    }

    setState(() => _state = SplashState.loading); 

    await Future.delayed(const Duration(milliseconds: 300)); 
    _goToDashboard();
  }

  String _getButtonText() {
    if (_state == SplashState.form) return tr('SIMPAN & MASUK', 'SAVE & ENTER');
    if (_onboardingPageIndex < 2) return tr('LANJUT', 'NEXT');
    return tr('MASUK', 'ENTER');
  }

  @override
  Widget build(BuildContext context) {
    bool showTopExitButton = _state == SplashState.form;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // ==========================================
          // 1. LAYAR PENGGUNA LAMA (SUDAH PERNAH INSTALL)
          // ==========================================
          if (_state == SplashState.welcomeReturning)
            Positioned.fill(
              child: WelcomeReturningView(
                userName: _savedName,
                onEnter: _goToDashboard,
              ),
            ),

          // ==========================================
          // 2. LAYAR WELCOME (PENGGUNA BARU) - TANPA ROKET
          // ==========================================
          if (_state == SplashState.welcomeNew)
            Positioned.fill(
              child: WelcomeNewView(
                onNext: () {
                  setState(() {
                    _state = SplashState.onboarding;
                    _onboardingPageIndex = 0;
                  });
                },
              ),
            ),

          // ==========================================
          // 3. BACKGROUND ALBUM FORM (GAMBAR TANGAN PEGANG HP PALING DEPAN)
          // ==========================================
          if (_state == SplashState.form)
            const Positioned.fill(
              child: StaggeredAlbumBackground(
                img1: 'assets/welcome1.jpg', // Gambar orang
                img2: 'assets/welcome3.jpg', // Gambar Tangan Pegang HP (Paling Depan)
                img3: 'assets/welcome2.jpg', // Gambar cewe cowo
              ),
            ),

          // ==========================================
          // 4. LAYER KONTEN UTAMA (ONBOARDING & FORM)
          // ==========================================
          if (_state == SplashState.onboarding || _state == SplashState.form)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight; 
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0), 
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: showTopExitButton
                                    ? IconButton(
                                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                                        onPressed: () {
                                          if (_state == SplashState.form) {
                                            setState(() {
                                              _state = SplashState.onboarding;
                                              _onboardingPageIndex = 2; 
                                            });
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              if (_pageController.hasClients) _pageController.jumpToPage(2);
                                            });
                                          }
                                        },
                                      )
                                    : const SizedBox(height: 48), 
                              ),
                              
                              const Spacer(),
                              
                              // --- TAMPILAN FORM PERKENALAN ---
                              if (_state == SplashState.form) ...[
                                const Icon(Icons.face_retouching_natural_rounded, size: 65, color: Color(0xFFD4FF00)), 
                                const SizedBox(height: 16),
                                Text(tr('Mari Berkenalan!', 'Let\'s Get Started!'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(tr('Atur profil dan target anggaran bulananmu.', 'Set your profile and monthly budget.'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                const SizedBox(height: 32),
                                
                                TextField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Nama Panggilan *', 'Nickname *'),
                                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                    prefixIcon: const Icon(Icons.person, color: Color(0xFFD4FF00), size: 22),
                                    filled: true, fillColor: const Color(0xFF1A1A1C).withOpacity(0.85),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD4FF00), width: 1.5)),
                                  ),
                                ),
                                const SizedBox(height: 20), 
                                
                                TextField(
                                  controller: _budgetCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Batas Anggaran Bulanan (Opsional)', 'Monthly Budget Limit (Optional)'),
                                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                    prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFFD4FF00), size: 22),
                                    prefixText: tr('Rp ', '\$ '),
                                    prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    filled: true, fillColor: const Color(0xFF1A1A1C).withOpacity(0.85),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD4FF00), width: 1.5)),
                                  ),
                                ),
                                const SizedBox(height: 20), 
                                
                                DropdownButtonFormField<String>(
                                  value: _selectedGoal.isEmpty ? tr('Pantau Pengeluaran', 'Track Expenses') : _selectedGoal,
                                  dropdownColor: const Color(0xFF1A1A1C),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Tujuan Keuangan', 'Financial Goal'),
                                    labelStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                                    prefixIcon: const Icon(Icons.flag_circle_rounded, color: Color(0xFFD4FF00), size: 22),
                                    filled: true, fillColor: const Color(0xFF1A1A1C).withOpacity(0.85),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD4FF00), width: 1.5)),
                                  ),
                                  items: [tr('Pantau Pengeluaran', 'Track Expenses'), tr('Lebih Hemat', 'Save More'), tr('Stop Langganan Boros', 'Stop Wasting Subs')]
                                      .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedGoal = val);
                                  },
                                ),
                              ] 
                              
                              // --- TAMPILAN SLIDE GAMBAR LAYANAN (ONBOARDING) ---
                              else if (_state == SplashState.onboarding) ...[
                                SizedBox(
                                  height: screenHeight * 0.58, 
                                  child: PageView(
                                    controller: _pageController,
                                    physics: const NeverScrollableScrollPhysics(), 
                                    onPageChanged: (index) {
                                      setState(() {
                                        _onboardingPageIndex = index;
                                      });
                                    },
                                    children: [
                                      _buildOnboardingSlide(
                                        imagePath: tr('assets/gambar1_id.png', 'assets/gambar1_en.png'), 
                                        title: tr('Catat Semua Layanan', 'Record All Services'),
                                        desc: tr('Kumpulkan semua tagihan di satu tempat agar lebih rapi.', 'Keep all your subscriptions in one neat place.'),
                                        alignment: const Alignment(0.15, -1.0),
                                      ),
                                      _buildOnboardingSlide(
                                        imagePath: tr('assets/gambar2_id.png', 'assets/gambar2_en.png'), 
                                        title: tr('Pengingat Otomatis', 'Automatic Reminders'),
                                        desc: tr('Tidak ada lagi denda telat bayar karena lupa waktu.', 'No more late payment fines because you forgot the date.'),
                                        alignment: const Alignment(0.0, -1.0),
                                      ),
                                      _buildOnboardingSlide(
                                        imagePath: tr('assets/gambar3_id.png', 'assets/gambar3_en.png'), 
                                        title: tr('Pantau Pengeluaran', 'Track Expenses'),
                                        desc: tr('Analisis cerdas kemana uangmu habis setiap bulannya.', 'Smart analysis of where your money goes every month.'),
                                        alignment: const Alignment(0.0, -1.0),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    height: 8,
                                    width: _onboardingPageIndex == index ? 24 : 8,
                                    decoration: BoxDecoration(
                                      color: _onboardingPageIndex == index ? const Color(0xFFD4FF00) : Colors.white24,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )),
                                ),
                              ],
                              
                              const Spacer(),
                              
                              // --- AREA TOMBOL NAVIGASI BAWAH ---
                              Builder(
                                builder: (context) {
                                  if (_state == SplashState.onboarding && _onboardingPageIndex > 0) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 3, 
                                          child: SizedBox(
                                            height: 60,
                                            child: OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 4), 
                                                side: const BorderSide(color: Colors.white24, width: 1.5),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                              ),
                                              onPressed: () {
                                                _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                              },
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(tr('KEMBALI', 'BACK'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          flex: 4, 
                                          child: SizedBox(
                                            height: 60,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFD4FF00),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                                elevation: 0,
                                              ),
                                              onPressed: () {
                                                if (_onboardingPageIndex < 2) {
                                                  _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                                } else {
                                                  setState(() => _state = SplashState.form); 
                                                }
                                              }, 
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(_getButtonText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  
                                  return SizedBox(
                                    width: double.infinity, height: 60,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFD4FF00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        if (_state == SplashState.onboarding) {
                                          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                        } else if (_state == SplashState.form) {
                                          _processEntry(); 
                                        }
                                      }, 
                                      child: Text(_getButtonText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ==========================================
          // 5. LAYER LOADING SAAT MENYIMPAN DATA
          // ==========================================
          if (_state == SplashState.loading)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF09090B),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4FF00), borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
                        ),
                        child: const Center(child: Text('S', style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1))),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(tr('Memuat', 'Loading'), style: const TextStyle(color: Color(0xFFD4FF00), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          const SizedBox(width: 8),
                          const WaveDotLoading(), 
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingSlide({required String imagePath, required String title, required String desc, required Alignment alignment}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover, alignment: alignment),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET KHUSUS PENGGUNA LAMA (TAMPILAN MEWAH GLASSMORPHISM KACA)
// ==========================================
class WelcomeReturningView extends StatefulWidget {
  final String userName;
  final VoidCallback onEnter;

  const WelcomeReturningView({super.key, required this.userName, required this.onEnter});

  @override
  State<WelcomeReturningView> createState() => _WelcomeReturningViewState();
}

class _WelcomeReturningViewState extends State<WelcomeReturningView> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _arrowCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _arrowSlide;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Animasi panah bergeser lembut pada tombol masuk
    _arrowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _arrowSlide = Tween<double>(begin: 0.0, end: 6.0).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _textCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09090B),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo S Box dengan Efek Kaca Minimalis (Tanpa Cahaya/Neon/Shadow)
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 45),
              
              // Kartu Frosted Glass Asli (Glassmorphism Premium Tanpa Shadow/Glow)
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tr('Selamat Datang Kembali,', 'Welcome Back,'),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.userName.isEmpty ? 'SubTracker' : widget.userName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Tombol Glassmorphism Kaca Elegan (Tanpa Shadow/Cahaya)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: widget.onEnter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        tr('MASUK KE DASHBOARD', 'ENTER DASHBOARD'),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      AnimatedBuilder(
                                        animation: _arrowSlide,
                                        builder: (context, child) {
                                          return Transform.translate(
                                            offset: Offset(_arrowSlide.value, 0),
                                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET KHUSUS PENGGUNA BARU (ANIMASI KETIK TANPA ROKET)
// ==========================================
class WelcomeNewView extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomeNewView({super.key, required this.onNext});

  @override
  State<WelcomeNewView> createState() => _WelcomeNewViewState();
}

class _WelcomeNewViewState extends State<WelcomeNewView> {
  bool _showSubTracker = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    // Timing Animasi yang Sangat Halus dan Berurutan:
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSubTracker = true);
    });
    
    Future.delayed(const Duration(milliseconds: 6500), () {
      if (mounted) setState(() => _showButton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09090B),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.06), blurRadius: 100, spreadRadius: 50)]),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Ketikan "Welcome to" dari awal (Sangat Halus)
              TypewriterText(
                'Welcome to',
                delay: const Duration(milliseconds: 500),
                speed: const Duration(milliseconds: 100),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontStyle: FontStyle.italic, color: Colors.white70, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),

              // 2. Teks SubTracker (Muncul Belakangan dengan Efek Mewah, Bukan Diketik)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showSubTracker ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  scale: _showSubTracker ? 1.0 : 0.5,
                  curve: Curves.easeOutBack,
                  child: const Text(
                    'SubTracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0, 
                      shadows: [Shadow(color: Color(0xFFD4FF00), blurRadius: 25)]
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Deskripsi Diketik (Sangat Halus)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TypewriterText(
                  tr('Aplikasi cerdas pemantau dan pengingat tagihan langgananmu.', 'Smart subscription tracking and reminder application.'),
                  delay: const Duration(milliseconds: 2800),
                  speed: const Duration(milliseconds: 50),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.5),
                ),
              ),

              const SizedBox(height: 60),

              // 4. Tombol Muncul Paling Terakhir
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showButton ? 1.0 : 0.0,
                child: _showButton ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4FF00),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: widget.onNext,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('MULAI SEKARANG', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                      ],
                    ),
                  ),
                ) : const SizedBox(height: 56), 
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGET EFEK KETIK TEKS (DIJAMIN DARI AWAL & HALUS)
// ==========================================
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final Duration speed;
  final Duration delay;

  const TypewriterText(this.text, {super.key, required this.style, this.textAlign = TextAlign.start, this.speed = const Duration(milliseconds: 50), this.delay = Duration.zero});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayed = "";
  Timer? _timer;
  Timer? _delayTimer;
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (!mounted) return;
      _startTyping();
    });
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (t) {
      if (_idx < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayed += widget.text[_idx];
            _idx++;
          });
        }
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_displayed, style: widget.style, textAlign: widget.textAlign);
  }
}

// ==========================================
// WIDGET ALBUM BACKGROUND EKSKLUSIF (FORM PERKENALAN)
// ==========================================
class StaggeredAlbumBackground extends StatefulWidget {
  final String img1, img2, img3;
  const StaggeredAlbumBackground({super.key, required this.img1, required this.img2, required this.img3});

  @override
  State<StaggeredAlbumBackground> createState() => _StaggeredAlbumBackgroundState();
}

class _StaggeredAlbumBackgroundState extends State<StaggeredAlbumBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoom1, _zoom2, _zoom3;
  late Animation<double> _fade1, _fade2, _fade3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    // Gambar Kiri Belakang (welcome1)
    _zoom1 = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack)));
    _fade1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)));

    // Gambar Kanan Belakang (welcome3)
    _zoom3 = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.7, curve: Curves.easeOutBack)));
    _fade3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeIn)));

    // Gambar TENGAH HP Spotify (welcome2) - Muncul Paling Akhir Agar Menimpa Kiri & Kanan
    _zoom2 = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack)));
    _fade2 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.8, curve: Curves.easeIn)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAlbumItem(String path, Animation<double> zoomAnim, Animation<double> fadeAnim, double angle, double width, double height, Alignment alignment) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnim.value,
          child: Transform.scale(
            scale: zoomAnim.value,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover, alignment: alignment),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, 10))],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // 1. Gambar Kiri & Kanan (Diletakkan di Lapisan Belakang)
        Center(
          child: SizedBox(
            height: 330, 
            width: sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -sw * 0.01,
                  child: _buildAlbumItem(widget.img1, _zoom1, _fade1, -0.20, sw * 0.42, 240, Alignment.center),
                ),
                Positioned(
                  right: -sw * 0.01,
                  child: _buildAlbumItem(widget.img3, _zoom3, _fade3, 0.20, sw * 0.42, 240, Alignment.center),
                ),
              ],
            ),
          ),
        ),

        // 2. Lapisan Meredupkan Gelap (Hanya meredupkan Gambar Kiri & Kanan di belakang)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: const Color(0xFF09090B).withOpacity(0.70),
            ),
          ),
        ),

        // 3. GAMBAR HP SPOTIFY (Diletakkan paling depan, di atas lapisan gelap agar tetap cerah)
        Center(
          child: SizedBox(
            height: 330, 
            width: sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: _buildAlbumItem(widget.img2, _zoom2, _fade2, 0.0, sw * 0.58, 320, const Alignment(0.0, 0.4)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// WIDGET ANIMASI LOADING GELOMBANG DOT
// ==========================================
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
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFD4FF00), shape: BoxShape.circle)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) { 
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]); 
  }
}