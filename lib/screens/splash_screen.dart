import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

enum SplashState { onboarding, form, loading } // langSelect sudah dihapus dari sini

class SplashScreen extends StatefulWidget {
  final bool isNewUser;
  const SplashScreen({super.key, this.isNewUser = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashState _state;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _budgetCtrl = TextEditingController();
  String _selectedGoal = '';

  @override
  void initState() {
    super.initState();
    // Langsung mulai di onboarding (Pengenalan Fitur)
    _state = SplashState.onboarding;
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
      // pushAndRemoveUntil digunakan agar pengguna tidak bisa kembali lagi ke onboarding saat sudah masuk dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // ==================================
          // LAYAR FITUR & FORM PROFIL
          // ==================================
          if (_state == SplashState.onboarding || _state == SplashState.form)
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: screenHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // PANAH KEMBALI
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: () {
                                    if (_state == SplashState.form) {
                                      // Jika di form profil, kembali ke fitur
                                      setState(() => _state = SplashState.onboarding);
                                    } else if (_state == SplashState.onboarding && widget.isNewUser) {
                                      // Jika di fitur, kembali ke Syarat & Ketentuan
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                              const Spacer(),
                              
                              if (_state == SplashState.form) ...[
                                const Icon(Icons.face_retouching_natural_rounded, size: 80, color: Color(0xFFD4FF00)),
                                const SizedBox(height: 24),
                                Text(tr('Mari Berkenalan!', 'Let\'s Get Started!'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(tr('Atur profil dan target anggaran bulananmu.', 'Set your profile and monthly budget.'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                                const SizedBox(height: 40),
                                
                                TextField(
                                  controller: _nameCtrl,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Nama Panggilan *', 'Nickname *'),
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.person, color: Color(0xFFD4FF00)),
                                    filled: true, fillColor: const Color(0xFF1A1A1C),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
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
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                DropdownButtonFormField<String>(
                                  value: _selectedGoal.isEmpty ? tr('Pantau Pengeluaran', 'Track Expenses') : _selectedGoal,
                                  dropdownColor: const Color(0xFF1A1A1C),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    labelText: tr('Tujuan Keuangan', 'Financial Goal'),
                                    labelStyle: const TextStyle(color: Colors.white54),
                                    prefixIcon: const Icon(Icons.flag_circle_rounded, color: Color(0xFFD4FF00)),
                                    filled: true, fillColor: const Color(0xFF1A1A1C),
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
                                Container(
                                  width: 100, height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4FF00), borderRadius: BorderRadius.circular(32),
                                    boxShadow: [BoxShadow(color: const Color(0xFFD4FF00).withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                                  ),
                                  child: const Center(child: Text('S', style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1))),
                                ),
                                const SizedBox(height: 24),
                                const Text('SubTracker', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.0)),
                                const SizedBox(height: 48),
                                _buildFeatureItem(icon: Icons.edit_document, title: tr('Catat Semua Layanan', 'Record All Services'), desc: tr('Kumpulkan semua tagihan di satu tempat agar lebih rapi.', 'Keep all your subscriptions in one neat place.')),
                                const SizedBox(height: 28),
                                _buildFeatureItem(icon: Icons.notifications_active_rounded, title: tr('Pengingat Otomatis', 'Automatic Reminders'), desc: tr('Tidak ada lagi denda telat bayar karena lupa waktu.', 'No more late payment fines because you forgot the date.')),
                                const SizedBox(height: 28),
                                _buildFeatureItem(icon: Icons.insert_chart_rounded, title: tr('Pantau Pengeluaran', 'Track Expenses'), desc: tr('Analisis cerdas kemana uangmu habis setiap bulannya.', 'Smart analysis of where your money goes every month.')),
                              ],
                              
                              const Spacer(),
                              
                              SizedBox(
                                width: double.infinity, height: 65,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4FF00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (_state == SplashState.onboarding) {
                                      if (widget.isNewUser) {
                                        setState(() => _state = SplashState.form); 
                                      } else {
                                        _processEntry(); 
                                      }
                                    } else if (_state == SplashState.form) {
                                      _processEntry(); 
                                    }
                                  }, 
                                  child: Text(
                                    _state == SplashState.form ? tr('SIMPAN & MASUK', 'SAVE & ENTER') : (widget.isNewUser ? tr('LANJUT', 'NEXT') : tr('MASUK', 'ENTER')), 
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.0)
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ==================================
          // LAYAR 4: LOADING GELOMBANG
          // ==================================
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

  Widget _buildFeatureItem({required IconData icon, required String title, required String desc}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1C), borderRadius: BorderRadius.circular(24)),
          child: Icon(icon, color: const Color(0xFFD4FF00), size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
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