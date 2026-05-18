// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

enum SplashState { onboarding, form, loading, returningWelcome } 

class SplashScreen extends StatefulWidget {
  final bool isNewUser;
  const SplashScreen({super.key, this.isNewUser = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashState _state;
  PageController? _pageController;
  int _onboardingPageIndex = 0;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _budgetCtrl = TextEditingController();
  String _selectedGoal = '';
  
  String _savedName = ''; // Untuk menyimpan nama pengguna lama

  @override
  void initState() {
    super.initState();
    // LOGIKA CERDAS: Pisahkan rute pengguna baru dan pengguna lama
    if (widget.isNewUser) {
      _state = SplashState.onboarding; 
      _pageController = PageController(initialPage: 0);
    } else {
      _state = SplashState.returningWelcome;
      _loadReturningUser();
    }
  }

  // Fungsi khusus untuk menangani pengguna lama
  Future<void> _loadReturningUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('user_name') ?? '';
    });
    
    // Tampilkan layar transisi "Welcome Back" selama 2.5 detik
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
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
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  String _getButtonText() {
    if (_state == SplashState.form) {
      return tr('SIMPAN & MASUK', 'SAVE & ENTER');
    }
    if (_onboardingPageIndex < 2) {
      return tr('LANJUT', 'NEXT');
    }
    return widget.isNewUser ? tr('LANJUT', 'NEXT') : tr('MASUK', 'ENTER');
  }

  @override
  Widget build(BuildContext context) {
    bool showTopExitButton = widget.isNewUser || _state == SplashState.form;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // ==========================================
          // 1. LAYAR TRANSISI KHUSUS PENGGUNA LAMA
          // ==========================================
          if (_state == SplashState.returningWelcome)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF09090B),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4FF00), 
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                              ),
                              child: const Center(child: Text('S', style: TextStyle(fontSize: 55, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1))),
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 40),
                      Text(tr('Selamat Datang Kembali!', 'Welcome Back!'), style: const TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(_savedName.isEmpty ? 'SubTracker' : _savedName, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 40),
                      const WaveDotLoading(), 
                    ],
                  ),
                ),
              ),
            ),

          // ==========================================
          // 2. BACKGROUND ALBUM UNTUK FORM (PENGGUNA BARU)
          // ==========================================
          if (_state == SplashState.form)
            Positioned.fill(
              child: const StaggeredAlbumBackground(
                img1: 'assets/welcome1.jpg',
                img2: 'assets/welcome2.jpg', 
                img3: 'assets/welcome3.jpg',
              ),
            ),

          // ==========================================
          // 3. LAYER KONTEN UTAMA (ONBOARDING & FORM PENGGUNA BARU)
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
                                              if (_pageController != null && _pageController!.hasClients) {
                                                _pageController!.jumpToPage(2);
                                              }
                                            });
                                          } else {
                                            Navigator.pop(context); 
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
                              else ...[
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
                                                _pageController?.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
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
                                                  _pageController?.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                                } else {
                                                  if (widget.isNewUser) {
                                                    setState(() => _state = SplashState.form); 
                                                  } else {
                                                    _processEntry(); 
                                                  }
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
                                          _pageController?.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
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
          // 4. LAYER LOADING (SAAT PROSES SIMPAN)
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
// WIDGET ALBUM BACKGROUND EKSKLUSIF (FORM PERKENALAN PENGGUNA BARU)
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

    _zoom1 = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack)));
    _fade1 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)));

    _zoom3 = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.7, curve: Curves.easeOutBack)));
    _fade3 = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.25, 0.55, curve: Curves.easeIn)));

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
        Center(
          child: SizedBox(
            height: 300, 
            width: sw,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: sw * 0.02,
                  child: _buildAlbumItem(widget.img1, _zoom1, _fade1, -0.15, sw * 0.40, 220, Alignment.center),
                ),
                Positioned(
                  right: sw * 0.02,
                  child: _buildAlbumItem(widget.img3, _zoom3, _fade3, 0.15, sw * 0.40, 220, Alignment.center),
                ),
                Positioned(
                  child: _buildAlbumItem(widget.img2, _zoom2, _fade2, 0.0, sw * 0.48, 270, Alignment.center),
                ),
              ],
            ),
          ),
        ),
        Container(color: const Color(0xFF09090B).withOpacity(0.70)),
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
  void dispose() { _controller.dispose(); super.dispose(); }
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
  Widget build(BuildContext context) { return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]); }
}