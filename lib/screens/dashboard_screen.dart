// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import 'add_screen.dart'; 

// =========================================================
// STATE GLOBAL UNTUK TEMA, PROFIL, DAN BAHASA (MULTILINGUAL)
// =========================================================
final ValueNotifier<String> themeNotifier = ValueNotifier<String>('Hitam');
final ValueNotifier<String> userNameNotifier = ValueNotifier<String>(''); 
final ValueNotifier<String> languageNotifier = ValueNotifier<String>('EN'); // Default English

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
  bool _isLoadingAdd = false; 
  final TextEditingController _searchCtrl = TextEditingController();

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

    final savedLang = prefs.getString('app_lang');
    if (savedLang != null) languageNotifier.value = savedLang;
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

  void _showNotificationsSheet(BuildContext context, Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Consumer<SubProvider>(
          builder: (context, provider, child) {
            final now = DateTime.now();
            final upcomingSubs = provider.subs.where((sub) {
              final date = _extractDateSafely(sub);
              if (date == null) return false;
              return date.isAfter(now.subtract(const Duration(days: 1))) && date.isBefore(now.add(const Duration(days: 7)));
            }).toList();

            upcomingSubs.sort((a, b) => _extractDateSafely(a)!.compareTo(_extractDateSafely(b)!));

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: Color(0xFFD4FF00)),
                      const SizedBox(width: 12),
                      Text(tr('Notifikasi Tagihan', 'Bill Notifications'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  upcomingSubs.isEmpty 
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text(tr('Tidak ada tagihan mendesak (7 hari ke depan).', 'No urgent bills (next 7 days).'), style: TextStyle(color: textColor.withOpacity(0.5)))),
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
                            subtitle: Text(tr('Segera jatuh tempo', 'Due soon'), style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
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

  void _showFilterSheet(BuildContext context, Color bgColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Consumer<SubProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('Urutkan Berdasarkan', 'Sort By'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
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
      leading: Icon(icon, color: isActive ? const Color(0xFFD4FF00) : defaultTextColor.withOpacity(0.6)),
      title: Text(title, style: TextStyle(color: isActive ? const Color(0xFFD4FF00) : defaultTextColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      trailing: isActive ? const Icon(Icons.check_circle, color: Color(0xFFD4FF00)) : null,
      onTap: () {
        if (title == 'Closest' || title == 'Terdekat') provider.setSortBy('Terdekat');
        else if (title == 'Highest Price' || title == 'Termahal') provider.setSortBy('Termahal');
        else if (title == 'Lowest Price' || title == 'Termurah') provider.setSortBy('Termurah');
        else provider.setSortBy('A-Z');
        
        Navigator.pop(context); 
      },
    );
  }

  Widget _buildBodyContent(String currentTheme) {
    switch (_currentIndex) {
      case 0: return _HomeView(key: const ValueKey('home'), theme: currentTheme);
      case 1: return _CalendarView(key: const ValueKey('calendar'), theme: currentTheme);
      case 2: return _StatsView(key: const ValueKey('stats'), theme: currentTheme);
      case 3: return _SettingsView(key: const ValueKey('settings'), theme: currentTheme);
      default: return _HomeView(key: const ValueKey('home'), theme: currentTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        
        Color scaffoldBg = const Color(0xFF09090B); 
        Color bottomNavBg = const Color(0xFF121214);
        Color textColor = Colors.white;
        Color appBarIcons = Colors.white;
        
        if (currentTheme == 'Putih') {
          scaffoldBg = const Color(0xFFF5F5F5); 
          bottomNavBg = Colors.white;
          textColor = Colors.black87;
          appBarIcons = Colors.black87;
        } else if (currentTheme == 'Biru') {
          scaffoldBg = const Color(0xFF0B101E); 
          bottomNavBg = const Color(0xFF151B2B); 
        }

        return Stack(
          children: [
            Scaffold(
              backgroundColor: scaffoldBg,
              resizeToAvoidBottomInset: false, 
              appBar: AppBar(
                backgroundColor: scaffoldBg,
                elevation: 0,
                title: _isSearching
                    ? TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: tr('Cari langganan...', 'Search subscriptions...'),
                          hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          context.read<SubProvider>().setSearchQuery(val); 
                        },
                      )
                    : Text(
                        'SubTracker',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5)
                      ),
                actions: [
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search, color: appBarIcons),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchCtrl.clear();
                          context.read<SubProvider>().setSearchQuery(''); 
                        }
                      });
                    },
                  ),
                  
                  if (!_isSearching)
                    IconButton(
                      icon: Stack(
                        children: [
                          Icon(Icons.notifications_none_rounded, color: appBarIcons),
                          Positioned(
                            right: 2, top: 2,
                            child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                          )
                        ]
                      ),
                      onPressed: () => _showNotificationsSheet(context, bottomNavBg, textColor),
                    ),

                  if (!_isSearching)
                    IconButton(
                      icon: Icon(Icons.tune, color: appBarIcons),
                      onPressed: () => _showFilterSheet(context, bottomNavBg, textColor),
                    ),
                  const SizedBox(width: 8),
                ],
              ),

              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ValueListenableBuilder<String>(
                  valueListenable: languageNotifier, 
                  builder: (context, lang, child) => _buildBodyContent(currentTheme),
                ),
              ),
              
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: FloatingActionButton(
                elevation: 0, hoverElevation: 0, highlightElevation: 0,
                backgroundColor: const Color(0xFFD4FF00), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.add, size: 32, color: Colors.black), 
                
                onPressed: _isLoadingAdd ? null : () async {
                  setState(() => _isLoadingAdd = true); 
                  bool hasInternet = false;
                  try {
                    final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
                    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) hasInternet = true; 
                  } catch (_) { hasInternet = false; }

                  if (!mounted) return;
                  if (hasInternet) {
                    await Future.delayed(const Duration(milliseconds: 600));
                    setState(() => _isLoadingAdd = false); 
                    if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScreen()));
                  } else {
                    setState(() => _isLoadingAdd = false); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.white), const SizedBox(width: 12),
                            Expanded(child: Text(tr('Gagal tersambung! Pastikan internet aktif.', 'Connection failed! Make sure internet is active.'), style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(20),
                      ),
                    );
                  }
                },
              ),

              bottomNavigationBar: BottomAppBar(
                color: bottomNavBg, 
                elevation: 0,
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                child: SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    children: [
                      IconButton(
                        icon: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? const Color(0xFFD4FF00) : (currentTheme == 'Putih' ? Colors.grey[400] : Colors.grey[700]), size: 28),
                        onPressed: () => setState(() => _currentIndex = 0),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month_rounded, color: _currentIndex == 1 ? const Color(0xFFD4FF00) : (currentTheme == 'Putih' ? Colors.grey[400] : Colors.grey[700]), size: 28),
                        onPressed: () => setState(() => _currentIndex = 1),
                      ),
                      const SizedBox(width: 48),
                      IconButton(
                        icon: Icon(Icons.insert_chart_rounded, color: _currentIndex == 2 ? const Color(0xFFD4FF00) : (currentTheme == 'Putih' ? Colors.grey[400] : Colors.grey[700]), size: 28),
                        onPressed: () => setState(() => _currentIndex = 2),
                      ),
                      IconButton(
                        icon: Icon(Icons.settings_rounded, color: _currentIndex == 3 ? const Color(0xFFD4FF00) : (currentTheme == 'Putih' ? Colors.grey[400] : Colors.grey[700]), size: 28),
                        onPressed: () => setState(() => _currentIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isLoadingAdd)
              Positioned.fill(
                child: Container(color: Colors.black87, child: const Center(child: WaveDotLoading())),
              ),
          ],
        );
      }
    );
  }
}

class _HomeView extends StatelessWidget {
  final String theme;
  const _HomeView({super.key, required this.theme});

  DateTime? _extractDateSafely(dynamic sub) {
    try { return sub.date as DateTime; } catch (_) {}
    try { return sub.dueDate as DateTime; } catch (_) {}
    try { return sub.tanggal as DateTime; } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final currencyFormat = NumberFormat.currency(locale: languageNotifier.value == 'ID' ? 'id_ID' : 'en_US', symbol: languageNotifier.value == 'ID' ? 'Rp ' : '\$ ', decimalDigits: 0);
    
    final List<String> namaBulanSingkatID = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    final List<String> namaBulanSingkatEN = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final namaBulanSingkat = languageNotifier.value == 'ID' ? namaBulanSingkatID : namaBulanSingkatEN;

    final hour = DateTime.now().hour;
    String greeting = tr('Selamat Pagi', 'Good Morning');
    if (hour >= 12 && hour < 15) greeting = tr('Selamat Siang', 'Good Afternoon');
    else if (hour >= 15 && hour < 18) greeting = tr('Selamat Sore', 'Good Evening');
    else if (hour >= 18 || hour < 4) greeting = tr('Selamat Malam', 'Good Night');

    Color cardBg = const Color(0xFF1A1A1C);
    Color textColor = Colors.white;
    Color subTextColor = Colors.white70;
    
    if (theme == 'Putih') {
      cardBg = Colors.white;
      textColor = Colors.black87;
      subTextColor = Colors.black54;
    } else if (theme == 'Biru') {
      cardBg = const Color(0xFF1A2235); 
    }

    final now = DateTime.now();
    final upcomingSubs = provider.subs.where((sub) {
      final date = _extractDateSafely(sub);
      if (date == null) return false;
      return date.isAfter(now) || DateUtils.isSameDay(date, now);
    }).toList();

    upcomingSubs.sort((a, b) => _extractDateSafely(a)!.compareTo(_extractDateSafely(b)!));

    final upcomingSub = upcomingSubs.isNotEmpty ? upcomingSubs.first : null;
    final double averagePrice = provider.subs.isEmpty ? 0 : (provider.totalMonthly / provider.subs.length);

    String upcomingDateStr = '';
    if (upcomingSub != null) {
      final date = _extractDateSafely(upcomingSub)!;
      upcomingDateStr = '${date.day} ${namaBulanSingkat[date.month - 1]}';
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: const Duration(milliseconds: 50),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 0),
              child: BlinkingWidget(
                child: ValueListenableBuilder<String>(
                  valueListenable: userNameNotifier,
                  builder: (context, userName, child) {
                    final displayText = userName.isEmpty ? greeting : '$greeting, $userName';
                    return Text(
                      displayText, 
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                    );
                  },
                ),
              ),
            ),
          ),

          FadeInSlide(
            delay: const Duration(milliseconds: 150),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFD4FF00), 
                borderRadius: BorderRadius.circular(24),
                boxShadow: theme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(tr('Total Tagihan Bulanan', 'Total Monthly Bills'), style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FittedBox(
                    fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
                    child: Text(
                      currencyFormat.format(provider.totalMonthly),
                      style: const TextStyle(color: Colors.black, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (provider.subs.isNotEmpty)
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme == 'Putih' ? Colors.grey.shade200 : Colors.white10)),
                        child: Row(
                          children: [
                            const Icon(Icons.widgets_rounded, color: Colors.cyanAccent, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tr('Layanan', 'Services'), style: TextStyle(color: subTextColor, fontSize: 11)),
                                Text('${provider.subs.length} ${tr('Aktif', 'Active')}', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme == 'Putih' ? Colors.grey.shade200 : Colors.white10)),
                        child: Row(
                          children: [
                            const Icon(Icons.analytics_rounded, color: Colors.orangeAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // PERBAIKAN: Menambahkan array children yang benar
                                children: [
                                  Text(tr('Rata-rata', 'Average'), style: TextStyle(color: subTextColor, fontSize: 11)),
                                  FittedBox(fit: BoxFit.scaleDown, child: Text(currencyFormat.format(averagePrice), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold))),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),

          if (provider.subs.isNotEmpty)
            FadeInSlide(
              delay: const Duration(milliseconds: 250),
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: theme == 'Putih' ? Colors.grey.shade200 : Colors.white10)
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: upcomingSub != null ? Colors.orange.withOpacity(0.15) : Colors.green.withOpacity(0.15), shape: BoxShape.circle),
                      child: Icon(upcomingSub != null ? Icons.notification_important_rounded : Icons.check_circle_rounded, color: upcomingSub != null ? Colors.orange : Colors.green, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(upcomingSub != null ? tr('Tagihan Terdekat', 'Upcoming Bill') : tr('Semua Tagihan Aman', 'All Bills Safe'), style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            upcomingSub != null 
                                ? '${upcomingSub.name} • $upcomingDateStr' 
                                : tr('Tidak ada tagihan dalam waktu dekat.', 'No upcoming bills soon.'), 
                            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          FadeInSlide(
            delay: const Duration(milliseconds: 350),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tr('Semua Layanan', 'All Services'), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),

          Expanded(
            child: provider.subs.isEmpty
                ? FadeInSlide(
                    delay: const Duration(milliseconds: 400),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: theme == 'Putih' ? Colors.grey.shade100 : Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined, 
                              size: 72, 
                              color: theme == 'Putih' ? Colors.grey.shade400 : Colors.white24
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            tr('Belum Ada Tagihan', 'No Bills Yet'), 
                            style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('Catat pengeluaran langganan pertamamu\ndengan menekan tombol (+) di bawah.', 'Record your first subscription expense\nby pressing the (+) button below.'), 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5)
                          ),
                          const SizedBox(height: 40),
                          BlinkingWidget(
                            child: Icon(Icons.keyboard_double_arrow_down_rounded, color: const Color(0xFFD4FF00).withOpacity(0.5), size: 32)
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100), 
                    physics: const BouncingScrollPhysics(),
                    itemCount: provider.subs.length,
                    itemBuilder: (context, index) {
                      return FadeInSlide(delay: Duration(milliseconds: 450 + (index * 100)), child: SubTile(sub: provider.subs[index]));
                    },
                  ),
          ),
        ],
      ),
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
    
    final subsOnSelectedDate = provider.subs.where((sub) {
      final date = _extractDateSafely(sub);
      if (date == null) return false;
      return date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
    }).toList();

    Color cardBg = const Color(0xFF1A1A1C);
    Color textColor = Colors.white;
    Color subTextColor = Colors.white54;
    
    if (widget.theme == 'Putih') {
      cardBg = Colors.white;
      textColor = Colors.black87;
      subTextColor = Colors.black54;
    } else if (widget.theme == 'Biru') {
      cardBg = const Color(0xFF1A2235); 
    }

    final isID = languageNotifier.value == 'ID';
    String stringBulanTahunKini = '${(isID ? namaBulanPenuhID : namaBulanPenuhEN)[_currentDate.month - 1]} ${_currentDate.year}';
    String stringTanggalPilih = '${_selectedDate.day} ${(isID ? namaBulanSingkatID : namaBulanSingkatEN)[_selectedDate.month - 1]} ${_selectedDate.year}';
    
    String? selectedHoliday = _getHolidayName(_selectedDate);

    final List<String> daysID = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final List<String> daysEN = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInSlide(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(stringBulanTahunKini, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
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
          
          FadeInSlide(
            delay: const Duration(milliseconds: 200),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg, 
                borderRadius: BorderRadius.circular(20), 
                border: Border.all(color: widget.theme == 'Putih' ? Colors.grey.shade200 : Colors.white10),
                boxShadow: widget.theme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: (isID ? daysID : daysEN).map((d) => 
                      SizedBox(width: 30, child: Center(child: Text(d, style: TextStyle(color: (d == 'Min' || d == 'Sun') ? Colors.redAccent : subTextColor, fontWeight: FontWeight.bold, fontSize: 12))))
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
                        circleColor = isHoliday ? Colors.redAccent : const Color(0xFFD4FF00);
                        dayTextColor = isHoliday ? Colors.white : Colors.black; 
                      } else if (isToday) {
                        circleColor = widget.theme == 'Putih' ? Colors.black12 : Colors.white12;
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
                                Positioned(bottom: 4, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: isSelected && !isHoliday ? Colors.white : const Color(0xFFD4FF00), shape: BoxShape.circle))),
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
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('${tr('Jadwal:', 'Schedule:')} $stringTanggalPilih', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          
          if (selectedHoliday != null)
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedHoliday, 
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)
                    )
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          
          Expanded(
            child: subsOnSelectedDate.isEmpty 
              ? Center(child: Text(tr('Bebas tagihan di hari ini', 'Free of bills today'), style: TextStyle(color: widget.theme == 'Putih' ? Colors.black38 : Colors.white30, fontSize: 14, fontWeight: FontWeight.bold)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: subsOnSelectedDate.length,
                  itemBuilder: (context, i) => SubTile(sub: subsOnSelectedDate[i]),
                ),
          )
        ],
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final String theme;
  const _StatsView({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final currencyFormat = NumberFormat.currency(locale: languageNotifier.value == 'ID' ? 'id_ID' : 'en_US', symbol: languageNotifier.value == 'ID' ? 'Rp ' : '\$ ', decimalDigits: 0);

    final totalMonthly = provider.totalMonthly;
    final breakdown = provider.categoryBreakdown;
    final activeSubs = provider.subs;
    final double averagePrice = activeSubs.isEmpty ? 0 : (totalMonthly / activeSubs.length);

    String mostExpensiveText = '-';
    if (activeSubs.isNotEmpty) {
      final mostExpensive = activeSubs.reduce((curr, next) => curr.price > next.price ? curr : next);
      mostExpensiveText = mostExpensive.name;
    }

    Color cardBg = const Color(0xFF121214);
    Color textColor = Colors.white;
    Color subTextColor = Colors.white54;
    
    if (theme == 'Putih') {
      cardBg = Colors.white;
      textColor = Colors.black87;
      subTextColor = Colors.black54;
    } else if (theme == 'Biru') {
      cardBg = const Color(0xFF151B2B); 
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(delay: const Duration(milliseconds: 100), child: Text(tr('Ringkasan', 'Summary'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryCard(tr('Tahunan', 'Yearly'), currencyFormat.format(provider.totalYearly), Icons.all_inclusive, Colors.purpleAccent, cardBg, textColor, subTextColor, theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard(tr('Layanan', 'Services'), '${activeSubs.length} ${tr('Aktif', 'Active')}', Icons.subscriptions_rounded, Colors.cyanAccent, cardBg, textColor, subTextColor, theme)),
                ],
              ),
            ),
            const SizedBox(height: 16), 

            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(child: _buildSummaryCard(tr('Rata-rata /Bulan', 'Average /Month'), currencyFormat.format(averagePrice), Icons.analytics_outlined, Colors.orangeAccent, cardBg, textColor, subTextColor, theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard(tr('Termahal', 'Most Expensive'), mostExpensiveText, Icons.diamond_outlined, Colors.pinkAccent, cardBg, textColor, subTextColor, theme)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            FadeInSlide(delay: const Duration(milliseconds: 400), child: Text(tr('Analisis Kategori', 'Category Analysis'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),

            if (breakdown.isEmpty)
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg, 
                    borderRadius: BorderRadius.circular(16),
                    border: theme == 'Putih' ? Border.all(color: Colors.grey.shade200) : null,
                  ),
                  child: Center(child: Text(tr('Belum ada data pengeluaran.', 'No expense data yet.'), style: TextStyle(color: subTextColor))),
                ),
              ),

            ...breakdown.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value.key;
              final amount = entry.value.value;
              final percentage = totalMonthly > 0 ? (amount / totalMonthly) : 0.0;

              return FadeInSlide(
                delay: Duration(milliseconds: 500 + (index * 150)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg, 
                    borderRadius: BorderRadius.circular(20),
                    border: theme == 'Putih' ? Border.all(color: Colors.grey.shade200) : null,
                    boxShadow: theme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(currencyFormat.format(amount), style: const TextStyle(color: Color(0xFFD4FF00), fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: theme == 'Putih' ? Colors.grey.shade200 : Colors.white.withOpacity(0.05),
                          color: const Color(0xFFD4FF00),
                          minHeight: 12, 
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(percentage * 100).toStringAsFixed(1)}% ${tr('dari total', 'of total')}', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            FadeInSlide(
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme == 'Putih' ? Colors.blue.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: Colors.blueAccent, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr('Proyeksi Bulan Depan', 'Next Month Projection'), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            activeSubs.isEmpty 
                              ? tr('Tambahkan tagihan untuk melihat proyeksi.', 'Add bills to see projections.') 
                              : tr('Jika semua langganan ini diperpanjang, kamu harus menyiapkan ${currencyFormat.format(totalMonthly)} lagi bulan depan. Yuk, evaluasi aplikasi yang jarang dipakai!', 'If all these subscriptions renew, you must prepare ${currencyFormat.format(totalMonthly)} next month. Let\'s evaluate unused apps!'),
                            style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor, Color cardBg, Color textColor, Color subTextColor, String theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg, 
        borderRadius: BorderRadius.circular(24),
        border: theme == 'Putih' ? Border.all(color: Colors.grey.shade200) : null,
        boxShadow: theme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900))),
        ],
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

  void _showSecuritySnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(tr('Fitur Keamanan Biometrik / PIN akan segera tersedia!', 'Biometric / PIN Security feature coming soon!'), style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showThemeSelector() {
    final isLight = widget.theme == 'Putih';
    final dialogBg = isLight ? Colors.white : (widget.theme == 'Biru' ? const Color(0xFF151B2B) : const Color(0xFF1A1A1C));
    final textColor = isLight ? Colors.black87 : Colors.white;
    final unselectedRadioColor = isLight ? Colors.black54 : Colors.white54; 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.white10)),
        title: Row(children: [const Icon(Icons.palette, color: Color(0xFFD4FF00)), const SizedBox(width: 10), Text(tr('Pilih Tema', 'Choose Theme'), style: TextStyle(color: textColor))]),
        
        content: Theme(
          data: Theme.of(context).copyWith(
            unselectedWidgetColor: unselectedRadioColor,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Hitam', 'Putih', 'Biru'].map((themeName) {
              return RadioListTile<String>(
                title: Text(themeName, style: TextStyle(color: textColor)),
                value: themeName,
                groupValue: themeNotifier.value, 
                activeColor: const Color(0xFFD4FF00),
                onChanged: (val) async {
                  themeNotifier.value = val!; 
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('saved_app_theme', val); 
                  if (mounted) Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final isLight = widget.theme == 'Putih';
    final dialogBg = isLight ? Colors.white : (widget.theme == 'Biru' ? const Color(0xFF151B2B) : const Color(0xFF1A1A1C));
    final textColor = isLight ? Colors.black87 : Colors.white;
    final unselectedRadioColor = isLight ? Colors.black54 : Colors.white54; 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.white10)),
        title: Row(children: [const Icon(Icons.language, color: Color(0xFFD4FF00)), const SizedBox(width: 10), Text(tr('Pilih Bahasa', 'Choose Language'), style: TextStyle(color: textColor))]),
        
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
                activeColor: const Color(0xFFD4FF00),
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
                activeColor: const Color(0xFFD4FF00),
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
    final isLight = widget.theme == 'Putih';
    final sheetBg = isLight ? Colors.white : (widget.theme == 'Biru' ? const Color(0xFF0B101E) : const Color(0xFF121214));
    final textColor = isLight ? Colors.black87 : Colors.white;
    final subTextColor = isLight ? Colors.black54 : Colors.white70;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.85, 
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tr('Privasi & Keamanan Data', 'Privacy & Data Security'), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
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
                        Text(tr('Perlindungan Data Anda', 'Your Data Protection'), style: const TextStyle(color: Color(0xFFD4FF00), fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(tr('Di SubTracker, kami menganggap privasi pengguna sebagai hal yang mutlak. Aplikasi ini dirancang menggunakan arsitektur Offline-First.', 'At SubTracker, we take user privacy absolutely seriously. This app is designed using an Offline-First architecture.'), style: TextStyle(color: subTextColor, height: 1.5)),
                        const SizedBox(height: 20),
                        
                        _buildPrivacyPoint('1', tr('Pengumpulan Data', 'Data Collection'), tr('SubTracker tidak mengumpulkan atau merekam data identitas pribadi Anda. Anda menggunakan aplikasi ini secara anonim.', 'SubTracker does not collect your personal data. You use this app anonymously.'), textColor, subTextColor),
                        _buildPrivacyPoint('2', tr('Penyimpanan Lokal (On-Device)', 'Local Storage'), tr('Semua data yang Anda input disimpan secara lokal dan dienkripsi di dalam memori internal HP Anda. Tidak ada Cloud.', 'All your inputted data is saved locally and encrypted in your phone. No Cloud storage.'), textColor, subTextColor),
                        
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [const Icon(Icons.warning_rounded, color: Colors.redAccent), const SizedBox(width: 8), Text(tr('Zona Bahaya', 'Danger Zone'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))]),
                              const SizedBox(height: 8),
                              Text(tr('Menghapus semua data akan menghilangkan seluruh catatan Anda secara permanen.', 'Deleting all data will permanently remove all your records.'), style: TextStyle(color: subTextColor, fontSize: 12)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0),
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  showDialog(
                                    context: context,
                                    builder: (confirmCtx) => AlertDialog(
                                      backgroundColor: sheetBg,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isLight ? Colors.grey.shade300 : Colors.white10)),
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
                                            // Jangan reset bahasa agar user tidak kaget
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Sistem berhasil di-reboot. Semua data telah dikosongkan.', 'System rebooted. All data cleared.'), style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cardBg = const Color(0xFF1A1A1C);
    Color textColor = Colors.white;
    Color subTextColor = Colors.white54;
    
    if (widget.theme == 'Putih') {
      cardBg = Colors.white;
      textColor = Colors.black87;
      subTextColor = Colors.black54;
    } else if (widget.theme == 'Biru') {
      cardBg = const Color(0xFF1A2235); 
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: Text(tr('Pengaturan', 'Settings'), style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            
            FadeInSlide(
              delay: const Duration(milliseconds: 150),
              child: _buildSettingTile(Icons.fingerprint_rounded, tr('Kunci Aplikasi', 'App Lock'), tr('Gunakan PIN atau Sidik Jari', 'Use PIN or Fingerprint'), _showSecuritySnackbar, cardBg, textColor, subTextColor, widget.theme),
            ),

            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardBg, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: widget.theme == 'Putih' ? Colors.grey.shade300 : Colors.white10),
                  boxShadow: widget.theme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
                ),
                child: SwitchListTile(
                  activeColor: Colors.black,
                  activeTrackColor: const Color(0xFFD4FF00),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  secondary: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFD4FF00), size: 24)),
                  title: Text(tr('Notifikasi Pengingat', 'Reminder Notifications'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text(tr('Alarm berbunyi saat tagihan', 'Alarm rings on due date'), style: TextStyle(color: subTextColor, fontSize: 12)),
                  value: _notifEnabled,
                  onChanged: (val) {
                    setState(() => _notifEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(val ? tr('Notifikasi Diaktifkan', 'Notifications Enabled') : tr('Notifikasi Dimatikan', 'Notifications Disabled'))));
                  },
                ),
              ),
            ),

            FadeInSlide(
              delay: const Duration(milliseconds: 250),
              child: _buildSettingTile(Icons.language_rounded, tr('Bahasa Aplikasi', 'App Language'), languageNotifier.value == 'ID' ? 'Bahasa Indonesia' : 'English', _showLanguageSelector, cardBg, textColor, subTextColor, widget.theme),
            ),

            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingTile(Icons.dark_mode_rounded, tr('Tema Aplikasi', 'App Theme'), widget.theme, _showThemeSelector, cardBg, textColor, subTextColor, widget.theme),
            ),

            FadeInSlide(
              delay: const Duration(milliseconds: 400),
              child: _buildSettingTile(Icons.security_rounded, tr('Privasi & Data', 'Privacy & Data'), tr('Kelola penyimpanan lokal', 'Manage local storage'), _showPrivacySheet, cardBg, textColor, subTextColor, widget.theme),
            ),

            FadeInSlide(
              delay: const Duration(milliseconds: 500),
              child: _buildSettingTile(
                Icons.info_rounded, tr('Tentang SubTracker', 'About SubTracker'), 'Version 1.0.0',
                () => showAboutDialog(
                  context: context,
                  applicationName: 'SubTracker',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Developed carefully.\n© 2026 Copyright.',
                  applicationIcon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFD4FF00), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.subscriptions, color: Colors.black)),
                ),
                cardBg, textColor, subTextColor, widget.theme
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback onTap, Color cardBg, Color textColor, Color subTextColor, String currentTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: currentTheme == 'Putih' ? Colors.grey.shade300 : Colors.white10),
        boxShadow: currentTheme == 'Putih' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFFD4FF00), size: 24)),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12))),
        trailing: Icon(Icons.chevron_right_rounded, color: subTextColor),
        onTap: onTap, 
      ),
    );
  }
}

class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const FadeInSlide({super.key, required this.child, required this.delay});
  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}
class _FadeInSlideState extends State<FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () { if (mounted) _controller.forward(); });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return FadeTransition(opacity: _opacityAnim, child: SlideTransition(position: _slideAnim, child: widget.child)); }
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
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) { return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildDot(0), _buildDot(1), _buildDot(2)]); }
}