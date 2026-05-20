// lib/widgets/dashboard_tutorial.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../screens/dashboard_screen.dart';

class TutorialStep {
  final String titleId;
  final String titleEn;
  final String descId;
  final String descEn;
  final String highlightName;
  // Posisi sorotan relatif (0.0 s.d 1.0 dari tinggi layar)
  final double topPercent;
  final double heightPercent;
  final double leftPercent;
  final double widthPercent;
  // Posisi kartu tooltip tutorial
  final double? tooltipTop;
  final double? tooltipBottom;
  // Arah panah penunjuk: 'up' (atas), 'down' (bawah)
  final String arrowDirection;
  final Color themeColor;

  TutorialStep({
    required this.titleId,
    required this.titleEn,
    required this.descId,
    required this.descEn,
    required this.highlightName,
    required this.topPercent,
    required this.heightPercent,
    required this.leftPercent,
    required this.widthPercent,
    this.tooltipTop,
    this.tooltipBottom,
    required this.arrowDirection,
    required this.themeColor,
  });
}

class DashboardTutorial extends StatefulWidget {
  final VoidCallback onClose;
  const DashboardTutorial({super.key, required this.onClose});

  @override
  State<DashboardTutorial> createState() => _DashboardTutorialState();
}

class _DashboardTutorialState extends State<DashboardTutorial> with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _arrowController;
  late AnimationController _fadeController;
  late Animation<double> _arrowAnimation;
  late Animation<double> _fadeAnimation;

  final List<TutorialStep> _steps = [
    TutorialStep(
      titleId: 'Profil & Sapaan',
      titleEn: 'Profile & Greeting',
      descId: 'Bagian ini menyambut Anda secara dinamis dengan nama profil yang telah diatur.',
      descEn: 'This section greets you dynamically with your configured profile name.',
      highlightName: 'Greeting',
      topPercent: 0.08,
      heightPercent: 0.05,
      leftPercent: 0.05,
      widthPercent: 0.90,
      tooltipTop: 0.15,
      arrowDirection: 'up',
      themeColor: Colors.redAccent,
    ),
    TutorialStep(
      titleId: 'Total Pengeluaran',
      titleEn: 'Total Spending',
      descId: 'Kartu utama ini menampilkan total seluruh pengeluaran langganan bulanan Anda.',
      descEn: 'This main card displays the sum of all your monthly subscription expenses.',
      highlightName: 'Monthly Bill',
      topPercent: 0.14,
      heightPercent: 0.16,
      leftPercent: 0.05,
      widthPercent: 0.90,
      tooltipTop: 0.32,
      arrowDirection: 'up',
      themeColor: const Color(0xFFD4FF00),
    ),
    TutorialStep(
      titleId: 'Statistik Layanan',
      titleEn: 'Service Statistics',
      descId: 'Melihat jumlah layanan aktif dan rata-rata biaya per langganan Anda secara cerdas.',
      descEn: 'View active services count and your smart average cost per subscription.',
      highlightName: 'Stats Row',
      topPercent: 0.31,
      heightPercent: 0.09,
      leftPercent: 0.05,
      widthPercent: 0.90,
      tooltipTop: 0.42,
      arrowDirection: 'up',
      themeColor: Colors.cyanAccent,
    ),
    TutorialStep(
      titleId: 'Tagihan Terdekat',
      titleEn: 'Upcoming Bills',
      descId: 'Menampilkan tagihan terdekat yang harus dibayar agar tidak telat.',
      descEn: 'Shows the nearest upcoming bill to pay so you are never late.',
      highlightName: 'Upcoming Card',
      topPercent: 0.41,
      heightPercent: 0.10,
      leftPercent: 0.05,
      widthPercent: 0.90,
      tooltipBottom: 0.16,
      arrowDirection: 'up',
      themeColor: Colors.orangeAccent,
    ),
    TutorialStep(
      titleId: 'Tombol Tambah Offline',
      titleEn: 'Offline Add Button',
      descId: 'Tekan tombol ini untuk mencatat pengeluaran langganan baru Anda kapan saja secara offline.',
      descEn: 'Press this button to record a new subscription expense anytime fully offline.',
      highlightName: 'FAB',
      topPercent: 0.88,
      heightPercent: 0.11,
      leftPercent: 0.40,
      widthPercent: 0.20,
      tooltipBottom: 0.16,
      arrowDirection: 'down',
      themeColor: const Color(0xFFD4FF00),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _arrowAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() {
          _currentStepIndex++;
        });
        _fadeController.forward();
      });
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    // Hitung posisi sorotan dalam piksel
    final highlightTop = screenHeight * step.topPercent;
    final highlightHeight = screenHeight * step.heightPercent;
    final highlightLeft = screenWidth * step.leftPercent;
    final highlightWidth = screenWidth * step.widthPercent;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // 1. Latar Belakang Redup Gelap Transparan
          IgnorePointer(
            child: Container(
              color: Colors.black.withOpacity(0.75),
            ),
          ),

          // 2. Lingkaran/Kotak Sorotan Efek Glow
          Positioned(
            top: highlightTop - 4,
            left: highlightLeft - 4,
            width: highlightWidth + 8,
            height: highlightHeight + 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  step.highlightName == 'FAB' ? 35 : 18,
                ),
                border: Border.all(
                  color: step.themeColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: step.themeColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // 3. Panah Petunjuk Dinamis (Bergeser/Kedip Lembut)
          if (step.arrowDirection == 'up')
            Positioned(
              top: highlightTop + highlightHeight + 10,
              left: highlightLeft + (highlightWidth / 2) - 20,
              child: AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _arrowAnimation.value),
                    child: Column(
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: step.themeColor, size: 36),
                        const SizedBox(height: 2),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: step.themeColor, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          if (step.arrowDirection == 'down')
            Positioned(
              top: highlightTop - 50,
              left: highlightLeft + (highlightWidth / 2) - 20,
              child: AnimatedBuilder(
                animation: _arrowAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _arrowAnimation.value),
                    child: Column(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: step.themeColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(height: 2),
                        Icon(Icons.arrow_downward_rounded, color: step.themeColor, size: 36),
                      ],
                    ),
                  );
                },
              ),
            ),

          // 4. Kartu Tooltip Tutorial (Frosted Glassmorphism Premium)
          Positioned(
            top: step.tooltipTop != null ? screenHeight * step.tooltipTop! : null,
            bottom: step.tooltipBottom != null ? screenHeight * step.tooltipBottom! : null,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Kartu Tooltip (Title & Progress Indicator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: step.themeColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tr(step.titleId, step.titleEn),
                              style: TextStyle(
                                color: step.themeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '${_currentStepIndex + 1}/${_steps.length}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Deskripsi Petunjuk Kecil Lengkap
                      Text(
                        tr(step.descId, step.descEn),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Area Aksi Tombol
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Tombol Lewati / Skip
                          TextButton(
                            onPressed: widget.onClose,
                            child: Text(
                              tr('LEWATI', 'SKIP'),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Tombol Lanjut / Next
                          Container(
                            decoration: BoxDecoration(
                              color: step.themeColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: _nextStep,
                              child: Text(
                                _currentStepIndex == _steps.length - 1
                                    ? tr('MENGERTI', 'GOT IT')
                                    : tr('LANJUT', 'NEXT'),
                                style: TextStyle(
                                  color: step.themeColor == const Color(0xFFD4FF00) ? Colors.black : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
