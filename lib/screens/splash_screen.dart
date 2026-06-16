import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/toast_utils.dart';
import 'dart:math'; 
import 'dart:async'; 
import 'dart:ui'; 
import 'dart:io'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

enum SplashState { welcomeNew, welcomeReturning, onboarding, choice, form, loading } 

class SplashScreen extends StatefulWidget {
  final bool isNewUser;
  const SplashScreen({super.key, this.isNewUser = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late SplashState _state;
  late PageController _pageController;
  int _onboardingPageIndex = 0;
  bool _isFormLoading = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _budgetCtrl = TextEditingController();
  String _savedName = ''; 

  late AnimationController _arrowCtrl;
  late Animation<double> _arrowSlide;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _arrowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _arrowSlide = Tween<double>(begin: 0.0, end: 6.0).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));
    
    
    if (widget.isNewUser) {
      _state = SplashState.onboarding; 
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
    _emailCtrl.dispose();
    _budgetCtrl.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PopScope(
          canPop: false,
          child: DashboardScreen(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
          
          return SlideTransition(
            position: animation.drive(tween),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(-5, 0),
                  )
                ]
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      )
    );
  }

  Future<void> _processEntry() async {
    if (_state == SplashState.form) {
      if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _budgetCtrl.text.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Semua kolom wajib diisi!', 'All fields are required!')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
        );
        return;
      }
      
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(_emailCtrl.text.trim())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('Format email tidak valid', 'Invalid email format')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
        );
        return;
      }
      
      setState(() => _isFormLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameCtrl.text.trim());
      await prefs.setString('user_email', _emailCtrl.text.trim());
      await prefs.setString('monthly_budget', _budgetCtrl.text.trim());
      userNameNotifier.value = _nameCtrl.text.trim();
      
      await Future.delayed(const Duration(milliseconds: 800));
    }

    _goToDashboard();
  }

  String _getButtonText() {
    if (_state == SplashState.form) return tr('SIMPAN & MASUK', 'SAVE & ENTER');
    if (_state == SplashState.onboarding && _onboardingPageIndex < 2) return tr('LANJUT', 'NEXT');
    return tr('MASUK', 'ENTER');
  }

  @override
  Widget build(BuildContext context) {
    bool showTopExitButton = _state == SplashState.form || _state == SplashState.choice;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          resizeToAvoidBottomInset: true, 
          body: Stack(
            children: [
          
          if (_state == SplashState.welcomeReturning)
            Positioned.fill(
              child: WelcomeReturningView(
                userName: _savedName,
                onEnter: () async {
                  setState(() => _isFormLoading = true);
                  await Future.delayed(const Duration(milliseconds: 800));
                  _goToDashboard();
                },
              ),
            ),

          
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

          
          if (_state == SplashState.form || _state == SplashState.choice || _state == SplashState.loading) ...[
            const Positioned.fill(
              child: StaggeredAlbumBackground(
                img1: 'assets/welcome1.jpg', 
                img2: 'assets/welcome3.jpg', 
                img3: 'assets/welcome2.jpg', 
              ),
            ),
          ],

        
          if (_state == SplashState.onboarding || _state == SplashState.choice || _state == SplashState.form || _state == SplashState.loading)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight; 
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
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
                                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 28),
                                        onPressed: () {
                                          if (_state == SplashState.form) {
                                            setState(() {
                                              _state = SplashState.choice;
                                            });
                                          } else if (_state == SplashState.choice) {
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
                              
                              
                              if (_state == SplashState.form || _state == SplashState.loading) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                                  child: Column(
                                    children: [
                                      Text(tr('Mari Berkenalan!', 'Let\'s Get Started!'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 8),
                                      Text(tr('Masukkan nama pengguna', 'Enter username'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                      const SizedBox(height: 32),
                                      
                                      TextField(
                                        controller: _nameCtrl,
                                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          labelText: tr('Nama Pengguna', 'Username'),
                                          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                                          prefixIcon: const Icon(Icons.person, color: Color(0xFF1E293B), size: 22),
                                          filled: true, fillColor: Colors.grey[100],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _emailCtrl,
                                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: tr('Alamat Email', 'Email Address'),
                                          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                                          prefixIcon: const Icon(Icons.email, color: Color(0xFF1E293B), size: 22),
                                          filled: true, fillColor: Colors.grey[100],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _budgetCtrl,
                                        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, _BudgetThousandsFormatter()],
                                        decoration: InputDecoration(
                                          labelText: tr('Target Anggaran Per Bulan', 'Monthly Budget Target'),
                                          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                                          prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF1E293B), size: 22),
                                          prefixText: 'Rp ',
                                          prefixStyle: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 16),
                                          filled: true, fillColor: Colors.grey[100],
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18), 
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] 
                              else if (_state == SplashState.choice) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                                  child: Column(
                                    children: [
                                      Text(tr('Mulai Perjalanan', 'Start Your Journey'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                                      const SizedBox(height: 8),
                                      Text(tr('Pilih bagaimana Anda ingin memulai', 'Choose how you want to start'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                      const SizedBox(height: 48),
                                      
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.person_add_rounded, size: 24),
                                          label: Text(tr('PENGGUNA BARU', 'NEW USER'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2563EB),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 8,
                                            shadowColor: const Color(0xFF2563EB).withOpacity(0.5)
                                          ),
                                          onPressed: () {
                                            setState(() => _state = SplashState.form);
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.restore_rounded, size: 24),
                                          label: Text(tr('PULIHKAN DATA', 'RESTORE DATA'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(0xFF1E293B),
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2563EB))),
                                            elevation: 0,
                                          ),
                                          onPressed: () async {
                                            String res = await context.read<SubProvider>().importBackup();
                                            if (res == 'success') {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('user_name', 'SubTracker User');
                                              if (context.mounted) {
                                                ToastUtils.show(context, 'Data dipulihkan!');
                                                _goToDashboard();
                                              }
                                            } else if (res != 'null' && res != '') {
                                              if (context.mounted) ToastUtils.show(context, 'Gagal memulihkan data', icon: Icons.error, iconColor: Colors.red);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
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
                                      color: _onboardingPageIndex == index ? const Color(0xFF2563EB) : Colors.white24,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  )),
                                ),
                              ],
                              
                              const Spacer(),
                              
                           
                              Builder(
                                builder: (context) {
                                  if (_state == SplashState.choice) return const SizedBox.shrink();
                                  if (_state == SplashState.onboarding && _onboardingPageIndex > 0) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                          },
                                          child: Text(tr('KEMBALI', 'BACK'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            if (_onboardingPageIndex < 2) {
                                              _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                            } else {
                                              setState(() => _state = SplashState.choice); 
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(_getButtonText(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 1.0)),
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
                                      ],
                                    );
                                  }
                                  
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _state == SplashState.loading ? null : () {
                                        if (_state == SplashState.onboarding) {
                                          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
                                        } else if (_state == SplashState.form) {
                                          _processEntry(); 
                                        }
                                      },
                                      child: _isFormLoading 
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tr('Memuat', 'Loading'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 1.0)),
                                            const SizedBox(width: 8),
                                            const Padding(padding: EdgeInsets.only(top: 4.0), child: WavyDotsProgressIndicator(color: Color(0xFF1E293B), dotSize: 5.0)),
                                          ],
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(_getButtonText(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: 1.0)),
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

        ],
      ),
    ),

  ],
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
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, width: double.infinity, fit: BoxFit.cover, alignment: alignment),
            ),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}


class WelcomeReturningView extends StatefulWidget {
  final String userName;
  final VoidCallback onEnter;

  const WelcomeReturningView({super.key, required this.userName, required this.onEnter});

  @override
  State<WelcomeReturningView> createState() => _WelcomeReturningViewState();
}

class _WelcomeReturningViewState extends State<WelcomeReturningView> with TickerProviderStateMixin {
  String? _base64Image;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _arrowCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _arrowSlide;

  bool _isLoading = false; 


  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B30).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            color: Color(0xFFFF3B30),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          tr('Koneksi Gagal', 'Connection Failed'),
                          style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr(
                            'Koneksi internet aktif diperlukan untuk masuk ke dashboard. Silakan periksa jaringan Anda.',
                            'An active internet connection is required to enter the dashboard. Please check your network connection.'
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.white.withOpacity(0.15)),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              tr('COBA LAGI', 'TRY AGAIN'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
        );
      },
    );
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() { _base64Image = prefs.getString('profile_image'); });
  }

  @override
  void initState() {
    super.initState();
    _loadPhoto();
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
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Gambar Background Estetis (welcome3.jpg)
              Positioned.fill(
                child: Image.asset(
                  'assets/welcome3.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              
             
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFF5F7FA).withOpacity(0.90),
                ),
              ),

            
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr('Selamat Datang Kembali', 'Welcome Back'),
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    ScaleTransition(
                                      scale: _logoScale,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 2.5)),
                                        child: CircleAvatar(
                                          radius: 55,
                                          backgroundColor: Colors.white10,
                                          backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
                                          child: _base64Image == null ? const Icon(Icons.account_circle, size: 80, color: Colors.black54) : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      widget.userName.isEmpty ? 'SubTracker' : widget.userName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                    child: SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await context.read<SubProvider>().ensureLoaded();
                                  await Future.delayed(const Duration(milliseconds: 800));
                                  if (mounted) {
                                    widget.onEnter();
                                  }
                                },
                          child: _isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tr('Memuat', 'Loading'),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 1.2),
                                    ),
                                    const SizedBox(width: 8),
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: WavyDotsProgressIndicator(color: Color(0xFF1E293B), dotSize: 5.0),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'MASUK',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 1.2),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class WavyDotsProgressIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;

  const WavyDotsProgressIndicator({
    super.key,
    this.color = Colors.white,
    this.dotSize = 5.0,
  });

  @override
  State<WavyDotsProgressIndicator> createState() => _WavyDotsProgressIndicatorState();
}

class _WavyDotsProgressIndicatorState extends State<WavyDotsProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
           
            final double offset = sin((_controller.value * 2 * pi) - (index * pi / 3));
            return Transform.translate(
              offset: Offset(0, offset * 4.5),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: widget.dotSize,
                height: widget.dotSize,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}


class WelcomeNewView extends StatefulWidget {
  final VoidCallback onNext;
  const WelcomeNewView({super.key, required this.onNext});

  @override
  State<WelcomeNewView> createState() => _WelcomeNewViewState();
}

class _WelcomeNewViewState extends State<WelcomeNewView> {
  bool _showSubTracker = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showSubTracker = true);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.06), blurRadius: 100, spreadRadius: 50)]),
            ),
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _showSubTracker ? 1.0 : 0.0,
                child: Image.asset('assets/icon.png', height: 180),
              ),
              const SizedBox(height: 16),
              TypewriterText(
                'Welcome to',
                delay: const Duration(milliseconds: 500),
                speed: const Duration(milliseconds: 100),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.black54, letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),

        
              AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: _showSubTracker ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  scale: _showSubTracker ? 1.0 : 0.5,
                  curve: Curves.easeOutBack,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'SubTracker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0, 
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }
}


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
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: AssetImage(path), fit: BoxFit.cover, alignment: alignment),
                  border: Border.all(color: Colors.black12, width: 2),
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
    return Opacity(
      opacity: 0.6,
      child: Stack(
        children: [
          
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
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) { 
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]); 
  }
}

class _BudgetThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return const TextEditingValue();
    final intValue = int.tryParse(cleanText);
    if (intValue == null) return oldValue;
    final newText = NumberFormat.decimalPattern('id').format(intValue);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
