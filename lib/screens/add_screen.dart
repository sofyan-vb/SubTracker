import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import 'dashboard_screen.dart'; 

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  String _selectedCategory = 'Hiburan';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now(); 
  
  bool _isAutoRenew = true;
  String _selectedStatus = 'Aktif';
  
  int _reminderDays = 0; 

  final List<String> _categories = ['Hiburan', 'Musik', 'Software', 'Utilitas', 'Lainnya'];
  final List<String> _statuses = ['Aktif', 'Non-Aktif'];

  // TAMBAHAN: Variabel untuk pilihan tipe notifikasi
  String _selectedNotifType = 'Notifikasi Biasa';
  final List<String> _notifTypes = ['Notifikasi Biasa', 'Alarm Lagu (Terus Berdering)'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentTheme = themeNotifier.value;
    Color surfaceColor = const Color(0xFF121214);
    Color onSurfaceColor = Colors.white;
    
    if (currentTheme == 'Putih') {
      surfaceColor = Colors.white;
      onSurfaceColor = Colors.black87;
    } else if (currentTheme == 'Biru') {
      surfaceColor = const Color(0xFF151B2B);
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFD4FF00),
              onPrimary: Colors.black,
              surface: surfaceColor,
              onSurface: onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final currentTheme = themeNotifier.value;
    Color surfaceColor = const Color(0xFF1A1A1C);
    Color onSurfaceColor = Colors.white;
    
    if (currentTheme == 'Putih') {
      surfaceColor = Colors.white;
      onSurfaceColor = Colors.black87;
    } else if (currentTheme == 'Biru') {
      surfaceColor = const Color(0xFF151B2B);
    }

    final TimeOfDay? picked = await showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87, 
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFFD4FF00),
              onPrimary: Colors.black,
              surface: surfaceColor, 
              onSurface: onSurfaceColor, 
            ),
          ),
          child: TimePickerDialog(
            initialTime: _selectedTime, 
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack, 
            ),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        
        Color scaffoldBg = const Color(0xFF09090B); 
        Color cardBg = const Color(0xFF121214);
        Color textColor = Colors.white;
        Color subTextColor = Colors.white54;
        Color hintColor = Colors.white24;
        Color iconColor = Colors.white;
        
        if (currentTheme == 'Putih') {
          scaffoldBg = const Color(0xFFF5F5F5); 
          cardBg = Colors.white;
          textColor = Colors.black87;
          subTextColor = Colors.black54;
          hintColor = Colors.black26;
          iconColor = Colors.black87;
        } else if (currentTheme == 'Biru') {
          scaffoldBg = const Color(0xFF0B101E); 
          cardBg = const Color(0xFF151B2B); 
        }

        return Scaffold(
          backgroundColor: scaffoldBg, 
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Tambah Langganan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Nama Layanan', subTextColor),
                              _buildTextField(_nameCtrl, 'Misal: Netflix', cardBg, textColor, hintColor),
                            ],
                          ),
                        ),
                        
                        FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Harga (Rp)', subTextColor),
                              _buildTextField(_priceCtrl, 'Misal: 150000', cardBg, textColor, hintColor, isNumber: true),
                            ],
                          ),
                        ),

                        FadeInSlide(
                          delay: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Kategori', subTextColor),
                                    _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!), cardBg, textColor),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('Status', subTextColor),
                                    _buildDropdown(_selectedStatus, _statuses, (val) => setState(() => _selectedStatus = val!), cardBg, textColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        FadeInSlide(
                          delay: const Duration(milliseconds: 400),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Waktu Pengingat (Tanggal & Jam)', subTextColor),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: _buildFakeInput(DateFormat('dd MMM yyyy').format(_selectedDate), Icons.calendar_month, cardBg, textColor, hintColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () => _selectTime(context),
                                      child: _buildFakeInput(_selectedTime.format(context), Icons.access_time_filled, cardBg, textColor, hintColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        FadeInSlide(
                          delay: const Duration(milliseconds: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Ingatkan Saya Pada', subTextColor),
                              _buildDropdown('H-$_reminderDays', ['H-0', 'H-1', 'H-3', 'H-7'], (val) {
                                setState(() => _reminderDays = int.parse(val!.replaceAll('H-', '')));
                              }, cardBg, textColor),
                            ],
                          ),
                        ),

                        // TAMBAHAN: Kolom Dropdown Pilihan Notifikasi / Alarm
                        FadeInSlide(
                          delay: const Duration(milliseconds: 550),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Tipe Pengingat', subTextColor),
                              _buildDropdown(_selectedNotifType, _notifTypes, (val) {
                                setState(() => _selectedNotifType = val!);
                              }, cardBg, textColor),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        FadeInSlide(
                          delay: const Duration(milliseconds: 600),
                          child: _buildSwitch('Perpanjangan Otomatis', _isAutoRenew, (val) => setState(() => _isAutoRenew = val), textColor, hintColor),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                
                FadeInSlide(
                  delay: const Duration(milliseconds: 700),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4FF00),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      onPressed: () async { 
                        if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                          
                          DateTime exactDateTime = DateTime(
                            _selectedDate.year, 
                            _selectedDate.month, 
                            _selectedDate.day,
                            _selectedTime.hour, 
                            _selectedTime.minute,
                          );

                          DateTime scheduledDateTime = exactDateTime.subtract(Duration(days: _reminderDays));

                          if (scheduledDateTime.isBefore(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Jadwal pengingat (H-$_reminderDays) sudah terlewat! Atur ke waktu yang akan datang.', style: const TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                            return; 
                          }

                          final newSub = Subscription(
                            id: DateTime.now().millisecondsSinceEpoch.toString(), 
                            name: _nameCtrl.text,
                            price: double.parse(_priceCtrl.text),
                            dueDate: exactDateTime, 
                            category: _selectedCategory,
                          );
                          
                          if (mounted) context.read<SubProvider>().addSub(newSub);

                          final prefs = await SharedPreferences.getInstance();
                          final savedName = prefs.getString('user_name') ?? ''; 

                          final notifTitle = savedName.isEmpty 
                              ? 'Pengingat: Tagihan ${newSub.name} 💸'
                              : 'Halo $savedName! Pengingat: Tagihan ${newSub.name} 💸';

                          
                          final bool isUsingAlarm = _selectedNotifType == 'Alarm Lagu (Terus Berdering)';

                          try {
                            NotificationService.scheduleNotification(
                              newSub.id.hashCode, 
                              notifTitle, 
                              'Pembayaran layanan sebesar Rp ${_priceCtrl.text} telah tiba waktunya.', 
                              scheduledDateTime,
                              isAlarm: isUsingAlarm, 
                            );
                          } catch (e) {
                            debugPrint('Gagal set notif: $e');
                          }

                          if (mounted) Navigator.pop(context); 
                        }
                      },
                      child: const Text('TAMBAHKAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
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

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 16),
      child: Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, Color bg, Color textColor, Color hintColor, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)), 
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: hintColor), border: InputBorder.none, contentPadding: const EdgeInsets.all(18)),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: bg,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFakeInput(String text, IconData icon, Color bg, Color textColor, Color hintColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), 
          Icon(icon, color: hintColor, size: 20)
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged, Color textColor, Color hintColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
        Switch(
          value: value, 
          onChanged: onChanged, 
          activeColor: Colors.black, 
          activeTrackColor: const Color(0xFFD4FF00),
          inactiveTrackColor: hintColor,
        ),
      ],
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