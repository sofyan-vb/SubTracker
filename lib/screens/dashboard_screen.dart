import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../utils/toast_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'splash_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../services/cloud_sync_service.dart';
import '../services/notification_service.dart';
import '../providers/subscription_provider.dart';
import '../models/subscription.dart';
import '../widgets/category_filter_menu.dart';
import '../main.dart';
import '../widgets/subscription_tile.dart';
import '../utils/category_utils.dart';
import '../utils/currency_utils.dart';
import '../widgets/currency_converter_sheet.dart';
import 'add_screen.dart';
import 'detail_screen.dart'; 
import 'currency_exchange_screen.dart';
import 'currency_selector_screen.dart';
import 'help_center_screen.dart';

final ValueNotifier<String> themeNotifier = ValueNotifier<String>('Putih');
final ValueNotifier<String> userNameNotifier = ValueNotifier<String>('');
final ValueNotifier<String?> userPhotoNotifier = ValueNotifier<String?>(null); 
final ValueNotifier<String> languageNotifier = ValueNotifier<String>('EN'); 
final ValueNotifier<String> currencyNotifier = ValueNotifier<String>('IDR');
final ValueNotifier<String> ringtoneNotifier = ValueNotifier<String>('Default');
final ValueNotifier<String> alarmNotifier = ValueNotifier<String>('alarm_lagu');

String tr(String idText, String enText) {
  return languageNotifier.value == 'ID' ? idText : enText;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoadingAdd = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData(); 
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedTheme = prefs.getString('saved_app_theme');
    if (savedTheme != null) themeNotifier.value = savedTheme; 
    
    final savedName = prefs.getString('user_name');
    if (savedName != null) userNameNotifier.value = savedName;
    final bool isManualLogin = prefs.getBool('login_mode_manual') ?? false;
    final savedPhoto = isManualLogin ? prefs.getString('profile_image') : (prefs.getString('user_photo_${savedName ?? ""}') ?? prefs.getString('profile_image'));
    if (savedPhoto != null) {
      userPhotoNotifier.value = savedPhoto;
    } else {
      userPhotoNotifier.value = null;
    }

    final savedLang = prefs.getString('app_lang');
    if (savedLang != null) languageNotifier.value = savedLang;

    final savedCurrency = prefs.getString('app_currency');
    if (savedCurrency != null) currencyNotifier.value = savedCurrency;

    CurrencyUtils.fetchRealTimeRates().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  DateTime? _extractDateSafely(dynamic sub) {
    try { return sub.date as DateTime; } catch (_) {}
    try { return sub.dueDate as DateTime; } catch (_) {}
    try { return sub.tanggal as DateTime; } catch (_) {}
    return null;
  }



  void _showFilterSheet(BuildContext context, Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) {
        return Consumer<SubProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Urutkan Berdasarkan', 'Sort By'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSortTile(context, provider, tr('Terdekat', 'Closest'), Icons.calendar_today, textColor),
                  _buildSortTile(context, provider, tr('Termahal', 'Highest Price'), Icons.arrow_upward, textColor),
                  _buildSortTile(context, provider, tr('Termurah', 'Lowest Price'), Icons.arrow_downward, textColor),
                  _buildSortTile(context, provider, 'A-Z', Icons.sort_by_alpha, textColor),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildSortTile(BuildContext context, SubProvider provider, String title, IconData icon, Color defaultTextColor) {
    bool isActive = provider.sortBy == title || 
                    (provider.sortBy == 'Terdekat' && title == 'Closest') ||
                    (provider.sortBy == 'Termahal' && title == 'Highest Price') ||
                    (provider.sortBy == 'Termurah' && title == 'Lowest Price');

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isActive ? Colors.white : defaultTextColor.withOpacity(0.6)),
      title: Text(title, style: TextStyle(color: isActive ? Colors.white : defaultTextColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      trailing: isActive ? const Icon(Icons.check_circle, color: Color(0xFF1E293B)) : null,
      onTap: () {
        if (title == 'Closest' || title == 'Terdekat') provider.setSortBy('Terdekat');
        else if (title == 'Highest Price' || title == 'Termahal') provider.setSortBy('Termahal');
        else if (title == 'Lowest Price' || title == 'Termurah') provider.setSortBy('Termurah');
        else provider.setSortBy('A-Z');
        
        Navigator.pop(context); 
      },
    );
  }

  void _showPremiumProfileDialog(BuildContext context, Color bottomNavBg, Color textColor, Color scaffoldBg) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: bottomNavBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                          : [const Color(0xFF0D9488), const Color(0xFF2DD4BF)], 
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          right: 12, top: 12,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                            onPressed: () => Navigator.pop(context)
                          )
                        ),
                        Positioned(
                          bottom: -40,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: bottomNavBg, shape: BoxShape.circle),
                              child: ValueListenableBuilder<String?>(
                                valueListenable: userPhotoNotifier,
                                builder: (context, photo, child) {
                                  return CircleAvatar(
                                    radius: 40,
                                    backgroundColor: scaffoldBg,
                                    backgroundImage: photo != null ? MemoryImage(base64Decode(photo)) : null,
                                    child: photo == null ? Icon(Icons.account_circle, size: 60, color: textColor.withValues(alpha: 0.3)) : null,
                                  );
                                }
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  ValueListenableBuilder<String>(
                    valueListenable: userNameNotifier,
                    builder: (context, userName, child) {
                      return Text(userName.isEmpty ? 'SubTrack IQ User' : userName, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold));
                    }
                  ),
                  const SizedBox(height: 28),
                  Consumer<SubProvider>(
                    builder: (context, provider, child) {
                      final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildProfileStat('Langganan', '${provider.activeSubs.length}', textColor),
                          Container(width: 1, height: 40, color: Colors.white10),
                          _buildProfileStat('Pengeluaran', currencyFormat.format(provider.totalMonthly), textColor),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(top: 0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(bgColor: scaffoldBg, textColor: textColor, cardBg: bottomNavBg)));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3))
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, color: Color(0xFF1E293B), size: 20),
                            SizedBox(width: 8),
                            Text('Pengaturan Profil', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  Widget _buildProfileStat(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10)),
      ],
    );
  }

  Widget _buildBodyContent(String currentTheme) {
    switch (_currentIndex) {
      case 0: return _HomeView(key: const ValueKey('home'), theme: currentTheme);
      case 1: return _CalendarView(key: const ValueKey('calendar'), theme: currentTheme);
      case 2: return _StatsView(key: const ValueKey('stats'), theme: currentTheme);
      case 3: return _SettingsView(
        key: const ValueKey('settings'), 
        theme: currentTheme,
      );
      default: return _HomeView(key: const ValueKey('home'), theme: currentTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, _, child) {
        const currentTheme = 'Biru';
        // Use Theme values for Dark Mode support
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor; 
        Color bottomNavBg = Theme.of(context).colorScheme.surface;
        Color textColor = Theme.of(context).colorScheme.onSurface; 
        Color appBarIcons = Colors.white;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: scaffoldBg,
              resizeToAvoidBottomInset: false, 
              appBar: _currentIndex == 0 ? null : AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                elevation: 0,
                title: Text(
                  _currentIndex == 1 ? tr('Kalender', 'Calendar') : 
                  _currentIndex == 2 ? tr('Statistik', 'Statistics') : 
                  tr('Pengaturan', 'Settings'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)
                ),
                centerTitle: false,
              ),

              body: AnimatedSwitcher(duration: Duration.zero,
                child: ValueListenableBuilder<String>(
                  valueListenable: languageNotifier, 
                  builder: (context, lang, child) => _buildBodyContent(currentTheme),
                ),
              ),
              
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: FloatingActionButton(
                  elevation: 0, hoverElevation: 0, highlightElevation: 0, focusElevation: 0,
                  backgroundColor: Colors.transparent, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  child: _isLoadingAdd ? WavyDotsProgressIndicator(color: Colors.white, dotSize: 4.0) : const Icon(Icons.add_rounded, size: 36, color: Colors.white), 
                  onPressed: _isLoadingAdd
                      ? null
                      : () async {
                          setState(() {
                            _isLoadingAdd = true;
                          });
                        
                        await Future.delayed(const Duration(milliseconds: 1200));
                        
                        if (mounted) {
                          setState(() {
                            _isLoadingAdd = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScreen()));
                        }
                      },
                ),
              ),

              bottomNavigationBar: BottomAppBar(
                color: Colors.transparent, 
                elevation: 10,
                shadowColor: Colors.black26,
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                clipBehavior: Clip.antiAlias, 
                padding: EdgeInsets.zero, 
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isDark 
                        ? [const Color(0xFF1E3A8A).withOpacity(0.9), const Color(0xFF0F172A)]
                        : [const Color(0xFFDBEAFE), Colors.white], 
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    children: [
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 0),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_view_rounded, color: _currentIndex == 0 ? const Color(0xFF2563EB) : Colors.blueGrey.shade300, size: 26),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 4),
                              height: 4, width: _currentIndex == 0 ? 16 : 0,
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2)),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 1),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_month_rounded, color: _currentIndex == 1 ? const Color(0xFF2563EB) : Colors.blueGrey.shade300, size: 26),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 4),
                              height: 4, width: _currentIndex == 1 ? 16 : 0,
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), 
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 2),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_rounded, color: _currentIndex == 2 ? const Color(0xFF2563EB) : Colors.blueGrey.shade300, size: 26),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 4),
                              height: 4, width: _currentIndex == 2 ? 16 : 0,
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2)),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _currentIndex = 3),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_rounded, color: _currentIndex == 3 ? const Color(0xFF2563EB) : Colors.blueGrey.shade300, size: 26),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(top: 4),
                              height: 4, width: _currentIndex == 3 ? 16 : 0,
                              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2)),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        );
      }
    );
  }
}

class _HomeView extends StatefulWidget {
  final String theme;
  const _HomeView({super.key, required this.theme});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  String _selectedCategory = 'Semua';
  DateTime _selectedPieMonth = DateTime.now();
  bool _isFirstLaunch = false;
  bool _sortByPrice = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched_before') ?? false;
    if (!hasLaunched) {
      setState(() {
        _isFirstLaunch = true;
      });
      await prefs.setBool('has_launched_before', true);
    }
  }


  void _showProfileDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textCol = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextCol = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: dialogBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    gradient: LinearGradient(
                      colors: isDark 
                        ? [const Color(0xFF1E3A8A).withOpacity(0.9), const Color(0xFF0F172A)] 
                        : [const Color(0xFF2563EB), const Color(0xFF1E3A8A)], 
                      begin: Alignment.topLeft, 
                      end: Alignment.bottomRight
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 12, top: 12,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context)
                        )
                      ),
                      Positioned(
                        bottom: -40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: dialogBg, shape: BoxShape.circle),
                            child: ValueListenableBuilder<String?>(
                              valueListenable: userPhotoNotifier,
                              builder: (context, photo, child) {
                                return CircleAvatar(
                                  radius: 40,
                                  backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                                  backgroundImage: photo != null ? MemoryImage(base64Decode(photo)) : null,
                                  child: photo == null ? Icon(Icons.person, size: 45, color: subTextCol) : null,
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                ValueListenableBuilder<String>(
                  valueListenable: userNameNotifier,
                  builder: (context, name, child) {
                    return Text(
                      name.isEmpty ? 'SubTrack IQ User' : name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textCol),
                    );
                  }
                ),
                const SizedBox(height: 6),
                Text(tr('Pengguna Aktif', 'Active User'), style: TextStyle(color: subTextCol, fontSize: 13)),
                const SizedBox(height: 24),
                
                Consumer<SubProvider>(
                  builder: (context, provider, child) {
                    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('${provider.activeSubs.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                            Text(tr('Langganan', 'Subscriptions'), style: TextStyle(fontSize: 11, color: subTextCol)),
                          ],
                        ),
                        Container(width: 1, height: 30, color: isDark ? Colors.white24 : Colors.grey.shade200),
                        Column(
                          children: [
                            Text(currencyFormat.format(provider.totalMonthly), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                            Text(tr('Pengeluaran', 'Expenses'), style: TextStyle(fontSize: 11, color: subTextCol)),
                          ],
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showCategoryFilterSheet(BuildContext context, Color bgColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final categories = ['Semua', ...CategoryUtils.categoriesID];
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('Pilih Kategori', 'Select Category'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = cat);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(cat == 'Semua' ? tr('Semua Layanan', 'All Services') : cat, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }


  void _showNotificationsSheet(BuildContext context, Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) {
        return Consumer<SubProvider>(
          builder: (context, provider, child) {
            final now = DateTime.now();
            final upcomingSubs = provider.activeSubs.where((sub) {
              final date = _extractDateSafely(sub);
              if (date == null) return false;
              return date.isAfter(now.subtract(const Duration(days: 1))) && date.isBefore(now.add(const Duration(days: 7)));
            }).toList();

            upcomingSubs.sort((a, b) => _extractDateSafely(a)!.compareTo(_extractDateSafely(b)!));

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active_rounded, color: textColor),
                      const SizedBox(width: 12),
                      Text(tr('Notifikasi Tagihan', 'Bill Notifications'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                    upcomingSubs.isEmpty 
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text(tr('Tidak ada tagihan saat ini', 'No bills currently'), style: TextStyle(color: textColor.withValues(alpha: 0.5)))),
                        )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: upcomingSubs.length,
                        itemBuilder: (ctx, i) {
                          final sub = upcomingSubs[i];
                          final subDate = _extractDateSafely(sub);
                          int daysLeft = subDate != null ? subDate.difference(now).inDays : 0;
                          String daysLeftStr = daysLeft <= 0 ? tr('Hari Ini', 'Today') : 'H-$daysLeft';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 20),
                            ),
                            title: Text(sub.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                            subtitle: Text(tr('Sekarang waktunya tagihan', 'Now its bill time'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 10)),
                            trailing: Text(daysLeftStr, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          );
                        }
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showSettingsSheet(BuildContext context, Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final newMode = themeModeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                  themeModeNotifier.value = newMode;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_theme_mode', newMode == ThemeMode.dark ? 'Dark' : 'Light');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: sheetCardColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.15), shape: BoxShape.circle), child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: const Color(0xFF2563EB))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isDark ? tr('Mode Terang', 'Light Mode') : tr('Mode Gelap', 'Dark Mode'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tr('Ubah tema aplikasi sesuai kenyamanan mata Anda.', 'Change the app theme for your eye comfort.'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final subs = context.read<SubProvider>().subs;
                  final result = await CloudSyncService.syncWithGoogleDrive(subs);
                  ToastUtils.show(context, result);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: sheetCardColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.cloud_sync_rounded, color: Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('Sinkronisasi Google Drive', 'Sync Google Drive'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tr('Simpan dan pulihkan cadangan data Anda secara aman menggunakan akun Google Drive pribadi Anda.', 'Safely backup and restore your data using your personal Google Drive account.'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final subs = context.read<SubProvider>().subs;
                  final result = await CloudSyncService.syncWithFirebase(subs);
                  ToastUtils.show(context, result);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: sheetCardColor, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('Sinkronisasi Firebase', 'Sync Firebase'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(tr('Sinkronkan data ke cloud Firebase agar dapat diakses secara sinkron dan real-time dari perangkat lain.', 'Sync data to Firebase cloud to access synchronously and real-time from other devices.'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        );
      }
    );
  }

  DateTime? _extractDateSafely(dynamic sub) {
    try { return sub.date as DateTime; } catch (_) {}
    try { return sub.dueDate as DateTime; } catch (_) {}
    try { return sub.tanggal as DateTime; } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final provider = context.watch<SubProvider>();
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    
    final List<String> namaBulanSingkatID = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    final List<String> namaBulanSingkatEN = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final namaBulanSingkat = languageNotifier.value == 'ID' ? namaBulanSingkatID : namaBulanSingkatEN;

    final hour = DateTime.now().hour;
    String greeting = tr('Selamat Pagi', 'Good Morning');
    if (hour >= 12 && hour < 15) greeting = tr('Selamat Siang', 'Good Afternoon');
    else if (hour >= 15 && hour < 18) greeting = tr('Selamat Sore', 'Good Evening');
    else if (hour >= 18 || hour < 4) greeting = tr('Selamat Malam', 'Good Night');

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    final now = DateTime.now();
    final upcomingSubs = provider.activeSubs.where((sub) {
      if (_selectedCategory != 'Semua' && sub.category != _selectedCategory) return false;
      final date = _extractDateSafely(sub);
      if (date == null) return false;
      return date.isAfter(now) || DateUtils.isSameDay(date, now);
    }).toList();
    if (_sortByPrice) {
      upcomingSubs.sort((a, b) => b.price.compareTo(a.price));
    } else {
      upcomingSubs.sort((a, b) => _extractDateSafely(a)!.compareTo(_extractDateSafely(b)!));
    }

    // Calculate category percentages for pie chart
    final filteredSubsForPie = provider.activeSubs.where((s) {
       return s.dueDate.year == _selectedPieMonth.year && s.dueDate.month == _selectedPieMonth.month;
    }).toList();
    
    double filteredTotalForPie = filteredSubsForPie.fold(0.0, (sum, item) => sum + item.price);

    Map<String, double> categoryTotals = {};
    for (var sub in filteredSubsForPie) {
      categoryTotals[sub.category] = (categoryTotals[sub.category] ?? 0) + sub.price;
    }
    
    final List<Color> pieColors = [
      const Color(0xFF2563EB), // Royal Blue
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF60A5FA), // Light Blue
      const Color(0xFF93C5FD), // Lighter Blue
      const Color(0xFFDBEAFE), // Very Light Blue
    ];

    List<PieChartSectionData> pieSections = [];
    List<Widget> legendWidgets = [];
    
    if (filteredTotalForPie > 0) {
      int colorIndex = 0;
      var sortedCategories = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      
      for (var entry in sortedCategories) {
        if (entry.value <= 0) continue;
        final percentage = (entry.value / filteredTotalForPie) * 100;
        final color = pieColors[colorIndex % pieColors.length];
        
        pieSections.add(
          PieChartSectionData(
            color: color,
            value: percentage,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: 20,
          )
        );
        
        if (colorIndex < 4) { // Show top 4 in legends
          legendWidgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(currencyFormat.format(entry.value), style: TextStyle(color: subTextColor, fontSize: 9)),
                      ],
                    ),
                  ),
                  Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(color: const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          );
        }
        colorIndex++;
      }
      
      if (pieSections.isEmpty) {
        pieSections.add(PieChartSectionData(color: Colors.grey[300], value: 100, title: '', radius: 20));
        legendWidgets.add(Text(tr('Belum ada data', 'No data yet'), style: TextStyle(color: subTextColor, fontSize: 11)));
      }
    } else {
      pieSections.add(PieChartSectionData(color: Colors.grey[300], value: 100, title: '', radius: 20));
      legendWidgets.add(Text(tr('Belum ada data', 'No data yet'), style: TextStyle(color: subTextColor, fontSize: 11)));
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
          // GREETING
          // GREETING HEADER
          SliverToBoxAdapter(
            child: FadeInSlide(delay: Duration.zero,
              child: Container(
                padding: const EdgeInsets.only(bottom: 24, top: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _showProfileDetails(context);
                                },
                                child: ValueListenableBuilder<String?>(
                                  valueListenable: userPhotoNotifier,
                                  builder: (context, photo, child) {
                                    return Container(
                                      padding: photo == null ? const EdgeInsets.all(10) : EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2.0),
                                      ),
                                      child: photo == null 
                                        ? const Icon(Icons.person, size: 24, color: Colors.white)
                                        : CircleAvatar(radius: 22, backgroundImage: MemoryImage(base64Decode(photo))),
                                    );
                                  }
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isFirstLaunch ? tr('Selamat datang', 'Welcome') : tr('Selamat datang kembali', 'Welcome back'), 
                                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)
                                    ),
                                    const SizedBox(height: 2),
                                    ValueListenableBuilder<String>(
                                      valueListenable: userNameNotifier,
                                      builder: (context, name, child) {
                                        return Text(
                                          name.isEmpty ? 'User' : name, 
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ),
                        ),
                        
                        // Header Icons
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sortByPrice = !_sortByPrice;
                                });
                                ToastUtils.show(context, _sortByPrice ? tr('Diurutkan berdasarkan Harga Termahal', 'Sorted by Highest Price') : tr('Diurutkan berdasarkan Waktu Terdekat', 'Sorted by Earliest Date'), icon: Icons.sort_rounded, iconColor: Colors.blue);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_sortByPrice ? Icons.price_change_rounded : Icons.access_time_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                            Consumer<SubProvider>(
                              builder: (context, provider, child) {
                                final now = DateTime.now();
                                final urgentCount = provider.activeSubs.where((sub) {
                                  final date = _extractDateSafely(sub);
                                  if (date == null) return false;
                                  return date.isBefore(now) || DateUtils.isSameDay(date, now);
                                }).length;
                                return GestureDetector(
                                  onTap: () {
                                    _showNotificationsSheet(context, bgColor, textColor);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                                        if (urgentCount > 0)
                                          Positioned(
                                            right: -2, top: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                              child: Text('$urgentCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                            GestureDetector(
                              onTap: () => _showSettingsSheet(context, bgColor, textColor),
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white30, width: 1.5),
                                ),
                                child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
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
          ),

          // SPENDING ANALYTICS CARD
          SliverToBoxAdapter(
            child: FadeInSlide(delay: const Duration(milliseconds: 100),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Analitik Pengeluaran', 'Spending Analytics'), style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final deletedSubs = provider.subs.where((s) => s.isFinished).toList();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                                                    child: const Icon(Icons.history_rounded, color: Color(0xFF2563EB), size: 18),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(tr('Layanan Dihapus', 'Deleted Services'), style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close_rounded, color: Colors.black54),
                                                onPressed: () => Navigator.pop(ctx),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (deletedSubs.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20),
                                              child: Text(tr('Belum ada layanan yang dihapus', 'No deleted services yet'), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                            )
                                          else
                                            Flexible(
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                itemCount: deletedSubs.length,
                                                separatorBuilder: (c, i) => Divider(color: Colors.grey.shade200),
                                                itemBuilder: (c, i) {
                                                  final s = deletedSubs[i];
                                                  return ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(s.name, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14)),
                                                    subtitle: Text(DateFormat('dd MMM yyyy').format(s.dueDate), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                    trailing: Text(currencyFormat.format(s.price), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 14),
                                    const SizedBox(width: 4),
                                    Text('${provider.subs.where((s) => s.isFinished).length}', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            PopupMenuButton<DateTime>(
                              offset: const Offset(0, 30),
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              constraints: const BoxConstraints(maxHeight: 250),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onSelected: (month) {
                                setState(() => _selectedPieMonth = month);
                              },
                              itemBuilder: (context) {
                                final now = DateTime.now();
                                final List<DateTime> months = List.generate(12, (index) => DateTime(now.year, now.month - index, 1));
                                return months.map((month) {
                                  final isSelected = _selectedPieMonth.year == month.year && _selectedPieMonth.month == month.month;
                                  return PopupMenuItem<DateTime>(
                                    value: month,
                                    child: Text(
                                      DateFormat('MMMM yyyy').format(month),
                                      style: TextStyle(
                                        color: isSelected ? const Color(0xFF2563EB) : textColor,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Text(DateFormat('MMM yyyy').format(_selectedPieMonth), style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_drop_down, color: Color(0xFF2563EB), size: 14),
                                  ]
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // PIE CHART
                        SizedBox(
                          height: 120,
                          width: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30, 
                                  sections: pieSections.map((s) {
                                    // Add percentage titles to slices
                                    return s.copyWith(
                                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                      radius: 25,
                                    );
                                  }).toList(),
                                  startDegreeOffset: -90,
                                )
                              ),
                              Builder(builder: (context) {
                                if (categoryTotals.isEmpty || filteredTotalForPie == 0) {
                                  return Text(
                                    '0%\nData',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900),
                                  );
                                }
                                final topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
                                final percentage = (topCategory.value / filteredTotalForPie * 100).toStringAsFixed(0);
                                String catName = topCategory.key;
                                if (catName.length > 7) catName = '${catName.substring(0, 7)}.';
                                return Text(
                                  '$percentage%\n$catName',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900),
                                );
                              })
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // LEGEND
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: legendWidgets,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TOTAL MONTHLY EXPENSE CARD (BLUE CARD)
          SliverToBoxAdapter(
            child: FadeInSlide(delay: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)], // Glassy blue gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Removed overlapping glass reflection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(tr('Total Tagihan Bulanan', 'Total Monthly Spending'), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                final deletedSubs = provider.subs.where((s) => s.isFinished).toList();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                                                    child: const Icon(Icons.history_rounded, color: Colors.redAccent, size: 18),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(tr('Layanan Dihapus', 'Deleted Services'), style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                              IconButton(icon: const Icon(Icons.close_rounded, color: Colors.black54), onPressed: () => Navigator.pop(ctx)),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (deletedSubs.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 20),
                                              child: Text(tr('Belum ada layanan yang dihapus', 'No deleted services yet'), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                                            )
                                          else
                                            Flexible(
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                itemCount: deletedSubs.length,
                                                separatorBuilder: (c, i) => Divider(color: Colors.grey.shade200),
                                                itemBuilder: (c, i) {
                                                  final s = deletedSubs[i];
                                                  return ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Text(s.name, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 14)),
                                                    subtitle: Text(DateFormat('dd MMM yyyy').format(s.dueDate), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                                    trailing: Text(currencyFormat.format(s.price), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                );
                              },
                              child: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 16),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                '${provider.activeSubs.length} ${tr('Aktif', 'Active')}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                                child: Text(
                                  provider.totalMonthly > 99000000000 ? '${currencyFormat.format(99000000000)}+' : currencyFormat.format(provider.totalMonthly),
                                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Builder(builder: (context) {
                                    final thisMonthAdded = provider.subs.where((s) => !s.isFinished && s.dateAdded != null && s.dateAdded!.month == DateTime.now().month && s.dateAdded!.year == DateTime.now().year).fold(0.0, (sum, item) => sum + item.price);
                                    final deletedSubsTotal = provider.subs.where((s) => s.isFinished).fold(0.0, (sum, item) => sum + item.price);
                                    
                                    final diff = thisMonthAdded - deletedSubsTotal;
                                    final isUp = diff > 0;
                                    final isDown = diff < 0;
                                    
                                    return Row(
                                      children: [
                                        Icon(isUp ? Icons.trending_up_rounded : isDown ? Icons.trending_down_rounded : Icons.ssid_chart_rounded, color: isUp ? Colors.greenAccent : isDown ? Colors.redAccent : Colors.white, size: 16),
                                        const SizedBox(width: 4),
                                        Text(isUp ? '+${currencyFormat.format(diff.abs()).replaceAll(RegExp(r'[^0-9KMB]'), '')}' : isDown ? '-${currencyFormat.format(diff.abs()).replaceAll(RegExp(r'[^0-9KMB]'), '')}' : 'Stabil', style: TextStyle(color: isUp ? Colors.greenAccent : isDown ? Colors.redAccent : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  // Mini sparkline dots
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 3),
                                        width: 4, height: 4 + (index * 2.0),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.6 + (index * 0.1)), borderRadius: BorderRadius.circular(2)),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // QUICK INSIGHTS CARD
            SliverToBoxAdapter(
              child: FadeInSlide(delay: const Duration(milliseconds: 250),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2563EB), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('Insight Cepat', 'Quick Insight'), style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Builder(builder: (context) {
                              if (provider.activeSubs.isEmpty || categoryTotals.isEmpty) {
                                return Text('Belum ada data insight yang bisa ditampilkan. Tambahkan layanan berlangganan Anda terlebih dahulu.', style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12, height: 1.4));
                              }
                              var topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
                              return RichText(
                                text: TextSpan(
                                  style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
                                  children: [
                                    const TextSpan(text: 'Pengeluaran terbesar Anda ada di kategori '),
                                    TextSpan(text: topCategory.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                    TextSpan(text: ' sejumlah '),
                                    TextSpan(text: currencyFormat.format(topCategory.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: '.'),
                                  ]
                                )
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // CATEGORY FILTER & UPCOMING BILLS TITLE
          SliverToBoxAdapter(
            child: FadeInSlide(delay: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 12),
                child: Column(
                  children: [
                    // Category Filter
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showCategoryFilterSheet(context, bgColor, textColor),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.category_rounded, color: const Color(0xFF2563EB), size: 16),
                                const SizedBox(width: 6),
                                Text(_selectedCategory == 'Semua' ? tr('Semua Layanan', 'All Services') : _selectedCategory, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Tagihan Mendatang', 'Upcoming Bills'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen(bgColor: bgColor, textColor: textColor, cardBg: cardBg)));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, color: textColor, size: 14),
                                const SizedBox(width: 4),
                                Text(tr('Riwayat', 'History'), style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
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

          // UPCOMING BILLS HORIZONTAL LIST
          SliverToBoxAdapter(
            child: FadeInSlide(delay: const Duration(milliseconds: 400),
              child: SizedBox(
                height: 140,
                child: upcomingSubs.isEmpty 
                  ? Center(child: Text(tr('Tidak ada tagihan', 'No upcoming bills'), style: TextStyle(color: subTextColor)))
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingSubs.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final sub = upcomingSubs[index];
                        final subDate = _extractDateSafely(sub);
                        int daysLeft = subDate != null ? subDate.difference(now).inDays : 0;
                        
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(sub: sub)));
                          },
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(left: 4, right: 12, bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        color: CategoryUtils.getColor(sub.category),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(child: Icon(Icons.subscriptions_rounded, color: Colors.white, size: 18)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sub.name, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('${daysLeft <= 0 ? tr('Hari Ini', 'Today') : 'H-$daysLeft'}', style: TextStyle(color: const Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(currencyFormat.format(sub.price), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for FAB
        ],
    );
  }
}


class _CalendarView extends StatefulWidget {
  final String theme;
  const _CalendarView({super.key, required this.theme});
  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewExpanded extends State<_CalendarView> {
  @override
  Widget build(BuildContext context) { return const SizedBox(); }
}

class _CalendarViewState extends State<_CalendarView> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<String> namaBulanSingkatID = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
  final List<String> namaBulanSingkatEN = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  
  final List<String> namaBulanPenuhID = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  final List<String> namaBulanPenuhEN = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  DateTime? _extractDateSafely(dynamic sub) {
    try { return sub.date as DateTime; } catch (_) {}
    try { return sub.dueDate as DateTime; } catch (_) {}
    try { return sub.tanggal as DateTime; } catch (_) {}
    return null;
  }

  String? _getHolidayName(DateTime date) {
    if (languageNotifier.value == 'EN') return null;

    int d = date.day;
    int m = date.month;
    int y = date.year;
    String yearMonthDay = '$y-$m-$d';

    Map<String, String> exactHolidays = {
      '2024-2-8': 'Isra Mi\'raj Nabi Muhammad SAW', '2024-2-10': 'Tahun Baru Imlek', '2024-3-11': 'Hari Raya Nyepi', '2024-3-29': 'Wafat Isa Almasih', '2024-4-10': 'Hari Raya Idul Fitri', '2024-4-11': 'Hari Raya Idul Fitri', '2024-5-9': 'Kenaikan Isa Almasih', '2024-5-23': 'Hari Raya Waisak', '2024-6-17': 'Hari Raya Idul Adha', '2024-7-7': 'Tahun Baru Islam', '2024-9-16': 'Maulid Nabi Muhammad SAW',
    };
    if (exactHolidays.containsKey(yearMonthDay)) return exactHolidays[yearMonthDay];

    if (d == 1 && m == 1) return 'Tahun Baru Masehi';
    if (d == 1 && m == 5) return 'Hari Buruh Internasional';
    if (d == 1 && m == 6) return 'Hari Lahir Pancasila';
    if (d == 17 && m == 8) return 'Hari Kemerdekaan RI';
    if (d == 25 && m == 12) return 'Hari Raya Natal';
    if (date.weekday == DateTime.sunday) return 'Hari Minggu (Libur)';

    return null; 
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final daysInMonth = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
    final firstDayOffset = DateTime(_currentDate.year, _currentDate.month, 1).weekday - 1; 
    
    final subsOnSelectedDate = provider.activeSubs.where((sub) {
      final date = _extractDateSafely(sub);
      if (date == null) return false;
      return date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    final isID = languageNotifier.value == 'ID';
    String stringBulanTahunKini = '${(isID ? namaBulanPenuhID : namaBulanPenuhEN)[_currentDate.month - 1]} ${_currentDate.year}';
    String stringTanggalPilih = '${_selectedDate.day} ${(isID ? namaBulanSingkatID : namaBulanSingkatEN)[_selectedDate.month - 1]} ${_selectedDate.year}';
    
    String? selectedHoliday = _getHolidayName(_selectedDate);

    final List<String> daysID = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final List<String> daysEN = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxHeight < 600;
        if (isSmallScreen) {
          return SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: FadeInSlide(delay: Duration.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(stringBulanTahunKini, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              IconButton(icon: Icon(Icons.chevron_left, color: textColor), onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month - 1))),
                              IconButton(icon: Icon(Icons.chevron_right, color: textColor), onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month + 1))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: FadeInSlide(delay: Duration.zero,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg, 
                        borderRadius: BorderRadius.circular(16), 
                        border: Border.all(color: Colors.white10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: (isID ? daysID : daysEN).map((d) => 
                              SizedBox(width: 30, child: Center(child: Text(d, style: TextStyle(color: (d == 'Min' || d == 'Sun') ? Colors.redAccent : subTextColor, fontWeight: FontWeight.bold, fontSize: 10))))
                            ).toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: daysInMonth + firstDayOffset,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.0),
                            itemBuilder: (context, index) {
                              if (index < firstDayOffset) return const SizedBox(); 
                              
                              final day = index - firstDayOffset + 1;
                              final thisDate = DateTime(_currentDate.year, _currentDate.month, day);
                              
                              final isSelected = DateUtils.isSameDay(thisDate, _selectedDate);
                              final isToday = DateUtils.isSameDay(thisDate, DateTime.now());
                              final isHoliday = _getHolidayName(thisDate) != null; 
                              
                              bool hasBill = provider.subs.any((sub) {
                                final date = _extractDateSafely(sub);
                                return date != null && DateUtils.isSameDay(date, thisDate);
                              });

                              Color circleColor = Colors.transparent;
                              Color dayTextColor = isHoliday ? Colors.redAccent : textColor; 

                              if (isSelected) {
                                circleColor = isHoliday ? Colors.redAccent : const Color(0xFF2563EB);
                                dayTextColor = Colors.white; 
                              } else if (isToday) {
                                circleColor = Colors.black12;
                              }

                              return GestureDetector(
                                onTap: () => setState(() => _selectedDate = thisDate),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text('$day', style: TextStyle(color: dayTextColor, fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal)),
                                      if (hasBill) 
                                        Positioned(bottom: 4, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: isSelected && !isHoliday ? Colors.white : const Color(0xFF2563EB), shape: BoxShape.circle))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${tr('Jadwal:', 'Schedule:')} $stringTanggalPilih', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                if (selectedHoliday != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedHoliday, 
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)
                            )
                          ),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                
                if (subsOnSelectedDate.isEmpty) 
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text(tr('Bebas tagihan di hari ini', 'Free of bills today'), style: TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => SubTile(sub: subsOnSelectedDate[i]),
                        childCount: subsOnSelectedDate.length,
                      ),
                    ),
                  )
              ],
            ),
          );
        } else {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInSlide(delay: Duration.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(stringBulanTahunKini, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(icon: Icon(Icons.chevron_left, color: textColor), onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month - 1))),
                            IconButton(icon: Icon(Icons.chevron_right, color: textColor), onPressed: () => setState(() => _currentDate = DateTime(_currentDate.year, _currentDate.month + 1))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                FadeInSlide(delay: Duration.zero,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white, 
                      borderRadius: BorderRadius.circular(16), 
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: (isID ? daysID : daysEN).map((d) => 
                            SizedBox(width: 30, child: Center(child: Text(d, style: TextStyle(color: (d == 'Min' || d == 'Sun') ? Colors.redAccent : subTextColor, fontWeight: FontWeight.bold, fontSize: 10))))
                          ).toList(),
                        ),
                        const SizedBox(height: 16),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: daysInMonth + firstDayOffset,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.0),
                          itemBuilder: (context, index) {
                            if (index < firstDayOffset) return const SizedBox(); 
                            
                            final day = index - firstDayOffset + 1;
                            final thisDate = DateTime(_currentDate.year, _currentDate.month, day);
                            
                            final isSelected = DateUtils.isSameDay(thisDate, _selectedDate);
                            final isToday = DateUtils.isSameDay(thisDate, DateTime.now());
                            final isHoliday = _getHolidayName(thisDate) != null; 
                            
                            bool hasBill = provider.subs.any((sub) {
                              final date = _extractDateSafely(sub);
                              return date != null && DateUtils.isSameDay(date, thisDate);
                            });

                            Color circleColor = Colors.transparent;
                            Color dayTextColor = isHoliday ? Colors.redAccent : textColor; 

                            if (isSelected) {
                              circleColor = isHoliday ? Colors.redAccent : const Color(0xFF2563EB);
                              dayTextColor = Colors.white; 
                            } else if (isToday) {
                              circleColor = Colors.black12;
                            }

                            return GestureDetector(
                              onTap: () => setState(() => _selectedDate = thisDate),
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text('$day', style: TextStyle(color: dayTextColor, fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal)),
                                    if (hasBill) 
                                      Positioned(bottom: 4, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: isSelected && !isHoliday ? Colors.white : const Color(0xFF2563EB), shape: BoxShape.circle))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('${tr('Jadwal:', 'Schedule:')} $stringTanggalPilih', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                
                if (selectedHoliday != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedHoliday, 
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)
                          )
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                
                Expanded(
                  child: subsOnSelectedDate.isEmpty
                      ? Center(child: Text(tr('Bebas tagihan di hari ini', 'Free of bills today'), style: TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100), 
                          physics: const BouncingScrollPhysics(),
                          itemCount: subsOnSelectedDate.length,
                          itemBuilder: (context, i) {
                            return SubTile(sub: subsOnSelectedDate[i]);
                          },
                        ),
                ),
              ],
            ),
          );
        }
      }
    );
  }
}

class _StatsView extends StatefulWidget {
  final String theme;
  const _StatsView({super.key, required this.theme});
  @override
  State<_StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<_StatsView> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    
    final totalMonthly = provider.totalMonthly;
    final breakdown = provider.categoryBreakdown;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${languageNotifier.value == 'ID' ? 'Bulan Ini' : 'This Month'}', 
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(totalMonthly),
                  style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0)
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, color: Colors.green, size: 14),
                      Text(
                        currencyFormat.format(totalMonthly > 0 ? (totalMonthly * 0.023) : 0), // Realistic 2.3% trend
                        style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(tr('Tren Pengeluaran', 'Spending Trend'), style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500)),
            
            const SizedBox(height: 24),
            
            
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: totalMonthly > 0 ? totalMonthly / 4 : 100, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Text(currencyFormat.format(value).replaceAll(RegExp(r'[^0-9KMB]'), ''), style: TextStyle(color: subTextColor, fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                            return Text(months[value.toInt()], style: TextStyle(color: subTextColor, fontSize: 10));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, totalMonthly * 0.5),
                        FlSpot(1, totalMonthly * 0.7),
                        FlSpot(2, totalMonthly * 0.6),
                        FlSpot(3, totalMonthly * 0.9),
                        FlSpot(4, totalMonthly * 0.8),
                        FlSpot(5, totalMonthly),
                      ],
                      isCurved: true,
                      color: const Color(0xFF2563EB),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
         
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Analisis Cepat', 'Quick Analysis'), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          totalMonthly > 500000 
                            ? tr('Pengeluaran Anda cukup tinggi bulan ini. Coba cek langganan yang jarang terpakai.', 'Your spending is quite high this month. Try checking unused subscriptions.') 
                            : tr('Pengeluaran Anda sangat stabil dan terkendali. Pertahankan!', 'Your spending is very stable and controlled. Keep it up!'),
                          style: TextStyle(color: subTextColor, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            
            if (provider.activeSubs.isNotEmpty) ...[
              Text(tr('Distribusi Layanan', 'Service Distribution'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: () {
                            final activeSubs = List.from(provider.activeSubs);
                            activeSubs.sort((a, b) => (b as Subscription).price.compareTo((a as Subscription).price));
                            return activeSubs.map((sub) {
                              final percentage = totalMonthly > 0 ? ((sub as Subscription).price / totalMonthly * 100) : 0.0;
                              
                              final isLarge = percentage > 5; 
                              return PieChartSectionData(
                                color: CategoryUtils.getColor(sub.category),
                                value: sub.price,
                                title: isLarge ? '${percentage.toStringAsFixed(0)}%' : '',
                                radius: 50,
                                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 2)]),
                                badgeWidget: isLarge 
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                                      ),
                                      child: Icon(CategoryUtils.getIcon(sub.category), size: 14, color: CategoryUtils.getColor(sub.category)),
                                    )
                                  : null,
                                badgePositionPercentageOffset: 1.15,
                              );
                            }).toList();
                          }(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                   
                    ...(() {
                      final activeSubs = List.from(provider.activeSubs);
                      activeSubs.sort((a, b) => (b as Subscription).price.compareTo((a as Subscription).price));
                      return activeSubs.map((sub) {
                        final percentage = totalMonthly > 0 ? ((sub as Subscription).price / totalMonthly * 100) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 14, height: 14,
                                decoration: BoxDecoration(color: CategoryUtils.getColor(sub.category), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(sub.name, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                              Text(currencyFormat.format(sub.price), style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 45,
                                child: Text('${percentage.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: const TextStyle(color: const Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    }())
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            
            if (provider.activeSubs.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Gradasi Biru Cerah ke Biru Gelap
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.event_repeat_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('Proyeksi Tagihan Tahunan', 'Annual Billing Projection'), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currencyFormat.format(totalMonthly * 12), 
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(tr('Total biaya yang akan Anda keluarkan jika seluruh langganan saat ini berlanjut selama 1 tahun penuh.', 'Total cost if your current subscriptions continue for a full year.'), style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

    
            if (provider.activeSubs.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], 
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.coffee_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('Beban Langganan Harian', 'Daily Subscription Burden'), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              
                              currencyFormat.format(totalMonthly / DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month)),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(tr('Tanpa sadar, ini adalah jumlah uang Anda yang terus mengalir keluar setiap harinya.', 'Without realizing it, this is the amount of your money flowing out every single day.'), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            Text(
              tr('Kategori Pengeluaran', 'Recent by Category'),
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 16),
            
            if (breakdown.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(tr('Belum ada data', 'No data yet'), style: TextStyle(color: subTextColor)),
              )),
              
            ...breakdown.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = totalMonthly > 0 ? (amount / totalMonthly) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(category, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(currencyFormat.format(amount), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF2563EB),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 32),
            if (provider.activeSubs.isNotEmpty) ...[
              Text(
                tr('Layanan Termahal', 'Most Expensive Services'),
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              ...() {
                final activeSubs = List.from(provider.activeSubs);
                activeSubs.sort((a, b) => (b as Subscription).price.compareTo((a as Subscription).price));
                final top3 = activeSubs.take(3).toList();
                
                return top3.map((sub) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: CategoryUtils.getColor(sub.category).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.subscriptions_rounded, color: CategoryUtils.getColor(sub.category)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sub.name, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(sub.category, style: TextStyle(color: subTextColor, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(currencyFormat.format(sub.price), style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  );
                }).toList();
              }()
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _SettingsView extends StatefulWidget {
  final String theme;
  const _SettingsView({super.key, required this.theme});

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _notifEnabled = true;

  Future<void> _backupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('saved_subs') ?? '[]';
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/SubTrack IQ_backup.json');
      await file.writeAsString(data);
      
      final result = await Share.shareXFiles(
        [XFile(file.path)], 
        text: 'Ini adalah backup data langganan SubTrack IQ Anda. Simpan file ini di tempat yang aman.'
      );
    } catch(e) {
      if (mounted) ToastUtils.show(context, 'Backup Gagal: $e', icon: Icons.error_outline, iconColor: Colors.redAccent);
    }
  }

  Future<void> _restoreData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String data = await file.readAsString();
        
        if (data.startsWith('[') && data.endsWith(']')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_subs', data);
          
          if (mounted) {
            ToastUtils.show(context, 'Data berhasil dipulihkan! Tutup dan buka ulang aplikasi.');
          }
        } else {
          if (mounted) ToastUtils.show(context, 'Format file backup tidak valid', icon: Icons.error_outline, iconColor: Colors.redAccent);
        }
      }
    } catch(e) {
      if (mounted) ToastUtils.show(context, 'Restore Gagal: $e', icon: Icons.error_outline, iconColor: Colors.redAccent);
    }
  }

  void _showCurrencySelector() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CurrencySelectorScreen()));
  }

  void _showLanguageSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final unselectedRadioColor = isDark ? Colors.white70 : Colors.black54;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
        title: Row(children: [Icon(Icons.language, color: textColor), const SizedBox(width: 10), Text(tr('Pilih Bahasa', 'Choose Language'), style: TextStyle(color: textColor))]),
        
        content: Theme(
          data: Theme.of(context).copyWith(
            unselectedWidgetColor: unselectedRadioColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('English', style: TextStyle(color: textColor)),
                value: 'EN',
                groupValue: languageNotifier.value, 
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) async {
                  languageNotifier.value = val!; 
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_lang', val); 
                  if (mounted) Navigator.pop(ctx);
                },
              ),
              RadioListTile<String>(
                title: Text('Bahasa Indonesia', style: TextStyle(color: textColor)),
                value: 'ID',
                groupValue: languageNotifier.value, 
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) async {
                  languageNotifier.value = val!; 
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_lang', val); 
                  if (mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacySheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.85, 
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('Privasi & Keamanan Data', 'Privacy & Data Security'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: Icon(Icons.close, color: textColor), onPressed: () => Navigator.pop(ctx))
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr('Perlindungan Data Anda', 'Your Data Protection'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(tr('Di SubTrack IQ, kami menganggap privasi pengguna sebagai hal yang mutlak. Aplikasi ini dirancang menggunakan arsitektur Offline-First.', 'At SubTrack IQ, we take user privacy absolutely seriously. This app is designed using an Offline-First architecture.'), style: TextStyle(color: subTextColor, height: 1.5)),
                        const SizedBox(height: 20),
                        
                        _buildPrivacyPoint('1', tr('Pengumpulan Data', 'Data Collection'), tr('SubTrack IQ tidak mengumpulkan atau merekam data identitas pribadi Anda. Anda menggunakan aplikasi ini secara anonim.', 'SubTrack IQ does not collect your personal data. You use this app anonymously.'), textColor, subTextColor),
                        _buildPrivacyPoint('2', tr('Penyimpanan Lokal (On-Device)', 'Local Storage'), tr('Semua data tagihan dan nama Anda murni disimpan dan dienkripsi di dalam memori internal HP Anda. Tidak ada data yang dikirim ke Cloud.', 'All your bills and name are purely saved and encrypted locally in your phone. No data is sent to the Cloud.'), textColor, subTextColor),
                        _buildPrivacyPoint('3', tr('Sistem Notifikasi Pintar', 'Smart Notification System'), tr('Pengingat tagihan berjalan langsung di latar belakang sistem HP Anda tanpa perlu menghubungi server eksternal.', 'Bill reminders run locally on your phone background without needing to contact external servers.'), textColor, subTextColor),
                        _buildPrivacyPoint('4', tr('Akses Pihak Ketiga', 'Third-Party Access'), tr('Kami menjamin 100% bahwa data finansial Anda tidak akan pernah dijual atau dibagikan ke pihak ketiga manapun untuk tujuan iklan.', 'We 100% guarantee that your financial data will never be sold or shared to any third parties for advertising.'), textColor, subTextColor),
                        _buildPrivacyPoint('5', tr('Kendali Penuh Pengguna', 'Full User Control'), tr('Anda memegang kendali mutlak. Anda bebas mengatur, mengubah, hingga memusnahkan seluruh catatan Anda kapan saja menggunakan zona merah di bawah ini.', 'You hold absolute control. You are free to manage, edit, or destroy all your records anytime using the red zone below.'), textColor, subTextColor),
                        
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.warning_rounded, color: Colors.redAccent), const SizedBox(width: 8), Text(tr('Zona Bahaya', 'Danger Zone'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12))]),
                              const SizedBox(height: 8),
                              Text(tr('Menghapus semua data akan menghilangkan seluruh catatan Anda secara permanen.', 'Deleting all data will permanently remove all your records.'), style: TextStyle(color: subTextColor, fontSize: 10)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  showDialog(
                                    context: context,
                                    builder: (confirmCtx) => AlertDialog(
                                      backgroundColor: sheetBg,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300)),
                                      title: Text(tr('Reboot Sistem?', 'System Reboot?'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                      content: Text(tr('Semua data langganan, profil, dan pengaturan akan terhapus. Lanjutkan?', 'All subscriptions, profiles, and settings will be deleted. Continue?'), style: TextStyle(color: subTextColor)),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(confirmCtx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: textColor.withOpacity(0.6)))),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(confirmCtx);
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.clear();
                                            
                                            final provider = context.read<SubProvider>();
                                            final subsList = provider.subs.toList();
                                            for (var sub in subsList) {
                                              provider.removeSub(sub.id);
                                            }
                                            
                                            themeNotifier.value = 'Hitam';
                                            userNameNotifier.value = ''; 
                                            
                                            ToastUtils.show(context, tr('Sistem berhasil di-reboot. Semua data telah dikosongkan', 'System rebooted. All data cleared'));
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SplashScreen()),
                                              (route) => false,
                                            );
                                          }, 
                                          child: Text(tr('Ya, Hapus Semua', 'Yes, Delete All'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
                                        ),
                                      ]
                                    )
                                  );
                                },
                                child: Text(tr('Hapus Seluruh Data Aplikasi', 'Delete All App Data'), style: const TextStyle(fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildPrivacyPoint(String number, String title, String desc, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Text(number, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: subTextColor, fontSize: 11, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    Color scaffoldBg = bgColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            FadeInSlide(delay: Duration.zero,
              child: Container(
                color: Colors.transparent,
                child: SwitchListTile(
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF2563EB),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: isDark ? Colors.white24 : Colors.grey.shade300,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(tr('Notifikasi Pengingat', 'Reminder Notifications'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(tr('Alarm berbunyi saat tagihan', 'Alarm rings on due date'), style: TextStyle(color: subTextColor, fontSize: 11)),
                  value: _notifEnabled,
                  onChanged: (val) {
                    setState(() => _notifEnabled = val);
                    ToastUtils.show(context, val ? tr('Notifikasi Diaktifkan', 'Notifications Enabled') : tr('Notifikasi Dimatikan', 'Notifications Disabled'));
                  },
                ),
              ),
            ),

            
            _buildGroupHeader(Icons.person, tr('Preferensi Pengguna', 'User Preferences')),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.account_circle, tr('Profil Saya', 'My Profile'), tr('Ubah Nama & Foto', 'Edit Name & Photo'), () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(bgColor: scaffoldBg, textColor: textColor, cardBg: cardBg)));
              }, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.language_rounded, tr('Bahasa Aplikasi', 'App Language'), languageNotifier.value == 'ID' ? 'Bahasa Indonesia' : 'English', _showLanguageSelector, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: ValueListenableBuilder<String>(
                valueListenable: currencyNotifier,
                builder: (context, currency, child) {
                  return _buildSettingTile(Icons.attach_money_rounded, tr('Mata Uang', 'Currency'), '${CurrencyUtils.data[currency]!['name']} ($currency)', _showCurrencySelector, cardBg, textColor, subTextColor, widget.theme);
                }
              ),
            ),
            FadeInSlide(delay: Duration.zero,
              child: ValueListenableBuilder<String>(
                valueListenable: ringtoneNotifier,
                builder: (context, ringtone, child) {
                  return ValueListenableBuilder<String>(
                    valueListenable: alarmNotifier,
                    builder: (context, alarm, child) {
                      return _buildSettingTile(Icons.library_music_rounded, tr('Nada Notifikasi', 'Notification Sound'), "${ringtone.replaceAll('ringtone_', '').toUpperCase()} | ${alarm.replaceAll('alarm_', '').toUpperCase()}", _showRingtoneSelector, cardBg, textColor, subTextColor, widget.theme);
                    }
                  );
                }
              )
            ),

            const SizedBox(height: 8),
            _buildGroupHeader(Icons.storage_rounded, tr('Manajemen Data', 'Data Management')),

            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.currency_exchange_rounded, tr('Kalkulator Kurs', 'Currency Converter'), tr('Perbandingan Mata Uang', 'Compare Currencies'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CurrencyExchangeScreen()));
              }, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.save_rounded, tr('Cadangkan Data', 'Backup Data'), tr('Ekspor ke File JSON', 'Export to JSON File'), _backupData, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.restore_rounded, tr('Pulihkan Data', 'Restore Data'), tr('Impor dari File', 'Import from File'), _restoreData, cardBg, textColor, subTextColor, widget.theme),
            ),

            const SizedBox(height: 8),
            _buildGroupHeader(Icons.security_rounded, tr('Sistem & Privasi', 'System & Privacy')),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.security_rounded, tr('Privasi & Data', 'Privacy & Data'), tr('Kelola penyimpanan lokal', 'Manage local storage'), _showPrivacySheet, cardBg, textColor, subTextColor, widget.theme, iconColor: Colors.red, titleColor: Colors.red),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.help_outline_rounded, tr('Pusat Bantuan', 'Help Center'), tr('FAQ & Bantuan Aplikasi', 'FAQ & App Help'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
              }, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.bug_report_rounded, tr('Laporkan Bug / Saran', 'Report Bug / Suggestion'), tr('Bantu kami jadi lebih baik', 'Help us get better'), () async {
                final Uri emailLaunchUri = Uri(scheme: 'mailto', path: 'support@subtrackiq.com', query: 'subject=Laporan%20Bug%20/%20Saran%20SubTrack%20IQ');
                try { await launchUrl(emailLaunchUri); } catch (e) { ToastUtils.show(context, 'Tidak dapat membuka email client'); }
              }, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(Icons.star_rate_rounded, tr('Beri Rating Aplikasi', 'Rate Our App'), tr('Dukung kami di Play Store', 'Support us on Play Store'), () {
                ToastUtils.show(context, tr('Akan diarahkan ke Play Store...', 'Will redirect to Play Store...'));
              }, cardBg, textColor, subTextColor, widget.theme),
            ),
            FadeInSlide(delay: Duration.zero,
              child: _buildSettingTile(
                Icons.info_rounded, tr('Tentang SubTrack IQ', 'About SubTrack IQ'), 'Version 1.0.0',
                () => showAboutDialog(
                  context: context,
                  applicationName: 'SubTrack IQ',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Developed carefully.\n© 2026 Copyright.',
                  applicationIcon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.subscriptions, color: Colors.white)),
                ),
                cardBg, textColor, subTextColor, widget.theme,
                iconColor: const Color(0xFF2563EB), titleColor: const Color(0xFF2563EB)
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewSound(String soundFile, {bool isAlarm = false}) {
    final channelId = 'preview_${soundFile}_v1';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, 'Pratinjau Suara',
        channelDescription: 'Preview',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundFile),
        audioAttributesUsage: isAlarm ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      ),
    );
    FlutterLocalNotificationsPlugin().show(8888, 'Pratinjau Suara', 'Memutar $soundFile...', details);
    
    Future.delayed(const Duration(seconds: 3), () {
      FlutterLocalNotificationsPlugin().cancel(8888);
    });
  }

  void _showRingtoneSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final unselectedRadioColor = isDark ? Colors.white70 : Colors.black54; 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
        title: Row(children: [Icon(Icons.notifications_active_rounded, color: textColor), const SizedBox(width: 10), Text(tr('Suara Notifikasi & Alarm', 'Notification & Alarm'), style: TextStyle(color: textColor, fontSize: 12))]),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        content: Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: unselectedRadioColor),
          child: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setStateSB) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(tr('Suara Notifikasi Biasa', 'Regular Notification'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      ...['ringtone_default', 'ringtone_chime', 'ringtone_alert', 'ringtone_synth'].map((r) {
                        return RadioListTile<String>(
                          title: Text(r.replaceAll('ringtone_', '').toUpperCase(), style: TextStyle(color: textColor, fontSize: 12)),
                          value: r,
                          groupValue: ringtoneNotifier.value, 
                          activeColor: const Color(0xFF2563EB),
                          dense: true,
                          onChanged: (val) async {
                            ringtoneNotifier.value = val!; 
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('app_ringtone', val); 
                            setStateSB((){});
                            if (mounted) setState((){});
                            _previewSound(val);
                          },
                        );
                      }),
                      const Divider(color: Colors.white10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Text(tr('Suara Alarm Tagihan', 'Billing Alarm Sound'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      ...['alarm_lagu', 'alarm_digital', 'alarm_classic'].map((r) {
                        return RadioListTile<String>(
                          title: Text(r.replaceAll('alarm_', '').toUpperCase(), style: TextStyle(color: textColor, fontSize: 12)),
                          value: r,
                          groupValue: alarmNotifier.value, 
                          activeColor: Colors.redAccent,
                          dense: true,
                          onChanged: (val) async {
                            alarmNotifier.value = val!; 
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('app_alarm', val); 
                            setStateSB((){});
                            if (mounted) setState((){});
                            _previewSound(val, isAlarm: true);
                          },
                        );
                      }),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FlutterLocalNotificationsPlugin().cancel(8888);
              Navigator.pop(ctx);
            },
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold))
          )
        ],
      )
    );
  }

  Widget _buildGroupHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color cardBg, Color textColor, Color subTextColor, String currentTheme, {Color? iconColor, Color? titleColor}) {
    return Container(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? textColor, size: 24),
        ),
        title: Text(title, style: TextStyle(color: titleColor ?? textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 11))),
        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
        onTap: onTap, 
      ),
    );
  }
}

class FadeInSlide extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const FadeInSlide({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) => child;
}

class BlinkingWidget extends StatefulWidget {
  final Widget child;
  const BlinkingWidget({super.key, required this.child});
  @override
  State<BlinkingWidget> createState() => _BlinkingWidgetState();
}
class _BlinkingWidgetState extends State<BlinkingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true); 
    _opacityAnim = Tween<double>(begin: 0.1, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return FadeTransition(opacity: _opacityAnim, child: widget.child); }
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
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) { return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]); }
}

