// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

enum SplashState { onboarding, form, loading } 

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

  @override
  void initState() {
    super.initState();
    _state = SplashState.onboarding;
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _processEntry() async {
    if (_state == SplashState.form) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('Nama panggilan tidak boleh kosong!', 'Nickname cannot be empty!'), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent),
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
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
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
                                            setState(() => _state = SplashState.onboarding);
                                          } else {
                                            Navigator.pop(context); 
                                          }
                                        },
                                      )
                                    : const SizedBox(height: 48), 
                              ),
                              
                              const Spacer(),
                              
                              if (_state == SplashState.form) ...[
                                const Icon(Icons.face_retouching_natural_rounded, size: 60, color: Color(0xFFD4FF00)), 
                                const SizedBox(height: 12),
                                Text(tr('Mari Berkenalan!', 'Let\'s Get Started!'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 6),
                                Text(tr('Atur profil dan target anggaran bulananmu.', 'Set your profile and monthly budget.'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                const SizedBox(height: 24),
                                
                                TextField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Nama Panggilan *', 'Nickname *'),
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.person, color: Color(0xFFD4FF00)),
                                    filled: true, fillColor: const Color(0xFF1A1A1C),
                                    contentPadding: const EdgeInsets.all(16), 
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                TextField(
                                  controller: _budgetCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Batas Anggaran Bulanan (Opsional)', 'Monthly Budget Limit (Optional)'),
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFFD4FF00)),
                                    prefixText: tr('Rp ', '\$ '),
                                    prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    filled: true, fillColor: const Color(0xFF1A1A1C),
                                    contentPadding: const EdgeInsets.all(16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                DropdownButtonFormField<String>(
                                  value: _selectedGoal.isEmpty ? tr('Pantau Pengeluaran', 'Track Expenses') : _selectedGoal,
                                  dropdownColor: const Color(0xFF1A1A1C),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Tujuan Keuangan', 'Financial Goal'),
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.flag_circle_rounded, color: Color(0xFFD4FF00)),
                                    filled: true, fillColor: const Color(0xFF1A1A1C),
                                    contentPadding: const EdgeInsets.all(16),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                  items: [tr('Pantau Pengeluaran', 'Track Expenses'), tr('Lebih Hemat', 'Save More'), tr('Stop Langganan Boros', 'Stop Wasting Subs')]
                                      .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedGoal = val);
                                  },
                                ),
                              ] 
                              else ...[
                                // ==========================================
                                // TAMPILAN SLIDE GAMBAR MEMAKAI onboarding.jpg
                                // ==========================================
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
                                      // Slide 1 - Memotong Otomatis Bagian Kiri (Pria)
                                      _buildOnboardingSlide(
                                        imagePath: 'assets/onboarding.jpg', // KUNCI UTAMA DI SINI
                                        alignment: Alignment.centerLeft,    // Memotong ke kiri
                                        title: tr('Catat Semua Layanan', 'Record All Services'),
                                        desc: tr('Kumpulkan semua tagihan di satu tempat agar lebih rapi.', 'Keep all your subscriptions in one neat place.')
                                      ),
                                      // Slide 2 - Memotong Otomatis Bagian Tengah (Wanita)
                                      _buildOnboardingSlide(
                                        imagePath: 'assets/onboarding.jpg', // KUNCI UTAMA DI SINI
                                        alignment: Alignment.center,        // Memotong ke tengah
                                        title: tr('Pengingat Otomatis', 'Automatic Reminders'),
                                        desc: tr('Tidak ada lagi denda telat bayar karena lupa waktu.', 'No more late payment fines because you forgot the date.')
                                      ),
                                      // Slide 3 - Memotong Otomatis Bagian Kanan (Pasangan)
                                      _buildOnboardingSlide(
                                        imagePath: 'assets/onboarding.jpg', // KUNCI UTAMA DI SINI
                                        alignment: Alignment.centerRight,   // Memotong ke kanan
                                        title: tr('Pantau Pengeluaran', 'Track Expenses'),
                                        desc: tr('Analisis cerdas kemana uangmu habis setiap bulannya.', 'Smart analysis of where your money goes every month.')
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
                                                _pageController.previousPage(
                                                  duration: const Duration(milliseconds: 500), 
                                                  curve: Curves.easeOutCubic
                                                );
                                              },
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  tr('KEMBALI', 'BACK'),
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
                                                  softWrap: false,
                                                  overflow: TextOverflow.visible,
                                                ),
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
                                                  if (widget.isNewUser) {
                                                    setState(() => _state = SplashState.form); 
                                                  } else {
                                                    _processEntry(); 
                                                  }
                                                }
                                              }, 
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  _getButtonText(),
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)
                                                ),
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
                                          if (_onboardingPageIndex < 2) {
                                            _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                          } else {
                                            if (widget.isNewUser) {
                                              setState(() => _state = SplashState.form); 
                                            } else {
                                              _processEntry(); 
                                            }
                                          }
                                        } else if (_state == SplashState.form) {
                                          _processEntry(); 
                                        }
                                      }, 
                                      child: Text(
                                        _getButtonText(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)
                                      ),
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
                          boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5))],
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

  // WIDGET FOTO DIKEMBALIKAN KE MODE POTONG ALIGNMENT
  Widget _buildOnboardingSlide({required String imagePath, required Alignment alignment, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: alignment, // FOKUS PEMOTONGAN OTOMATIS: Kiri, Tengah, Kanan
              ),
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