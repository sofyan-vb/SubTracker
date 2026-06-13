import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import '../utils/currency_utils.dart';
import 'dashboard_screen.dart'; 
import 'package:flutter/services.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  String _selectedCategory = '';
  bool _isShortcutUsed = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now(); 
  
  bool _isAutoRenew = true;
  String _selectedStatus = '';
  int _reminderDays = 0; 
  String _selectedNotifType = '';

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
    if (currentTheme == 'Putih') { surfaceColor = Colors.white; onSurfaceColor = Colors.black87; } 
    else if (currentTheme == 'Biru') { surfaceColor = const Color(0xFF151B2B); }

    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: const Color(0xFF0D9488), onPrimary: Colors.white, surface: surfaceColor, onSurface: onSurfaceColor)), child: child!);
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final currentTheme = themeNotifier.value;
    Color surfaceColor = const Color(0xFF1A1A1C);
    Color onSurfaceColor = Colors.white;
    if (currentTheme == 'Putih') { surfaceColor = Colors.white; onSurfaceColor = Colors.black87; } 
    else if (currentTheme == 'Biru') { surfaceColor = const Color(0xFF151B2B); }

    final TimeOfDay? picked = await showGeneralDialog<TimeOfDay>(
      context: context, barrierDismissible: true, barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, barrierColor: Colors.black87, transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim, secAnim) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.dark(primary: const Color(0xFF0D9488), onPrimary: Colors.white, surface: surfaceColor, onSurface: onSurfaceColor)), child: TimePickerDialog(initialTime: _selectedTime));
      },
      transitionBuilder: (context, anim, secAnim, child) {
        return FadeTransition(opacity: anim, child: ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack), child: child));
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _getHintForCategory(String category) {
    if (category == 'Musik' || category == 'Music') return tr('Misal: Spotify', 'E.g: Spotify');
    if (category == 'Software') return tr('Misal: Adobe CC', 'E.g: Adobe CC');
    if (category == 'Utilitas' || category == 'Utilities') return tr('Misal: PLN / WiFi', 'E.g: PLN / WiFi');
    if (category == 'Belanja' || category == 'Shopping') return tr('Misal: Shopee', 'E.g: Shopee');
    if (category == 'Game') return tr('Misal: Xbox Game Pass', 'E.g: Xbox Game Pass');
    if (category == 'Edukasi' || category == 'Education') return tr('Misal: Ruangguru', 'E.g: Ruangguru');
    if (category == 'Cloud Storage') return tr('Misal: Google One', 'E.g: Google One');
    if (category == 'Hiburan' || category == 'Entertainment') return tr('Misal: Netflix', 'E.g: Netflix');
    return tr('Misal: Layanan Lain', 'E.g: Other Service');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      tr('Hiburan', 'Entertainment'), tr('Musik', 'Music'), tr('Software', 'Software'), 
      tr('Utilitas', 'Utilities'), tr('Belanja', 'Shopping'), tr('Game', 'Game'), 
      tr('Edukasi', 'Education'), tr('Cloud Storage', 'Cloud Storage'), tr('Lainnya', 'Others')
    ];
    final List<String> statuses = [tr('Aktif', 'Active'), tr('Non-Aktif', 'Inactive')];
    final List<String> notifTypes = [tr('Notifikasi Biasa', 'Standard Notification'), tr('Alarm Lagu (Terus Berdering)', 'Music Alarm (Rings Continuously)')];

    if (_selectedStatus.isEmpty) _selectedStatus = statuses.first;
    if (_selectedNotifType.isEmpty) _selectedNotifType = notifTypes.first;

    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, _, child) {
        const currentTheme = 'Biru';
        Color scaffoldBg = const Color(0xFF0B101E); Color cardBg = const Color(0xFF151B2B); Color textColor = Colors.white; Color subTextColor = Colors.white; Color hintColor = Colors.white54; Color iconColor = Colors.white;

        return Scaffold(
          backgroundColor: scaffoldBg, 
          appBar: AppBar(
            backgroundColor: scaffoldBg, elevation: 0,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: iconColor), onPressed: () => Navigator.pop(context)),
            title: Text(tr('Tambah Langganan', 'Add Subscription'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInSlide(delay: const Duration(milliseconds: 50), child: _buildCategoryIcons(categories, cardBg, textColor)),
                        const SizedBox(height: 16),
                        FadeInSlide(delay: const Duration(milliseconds: 100), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Kategori', 'Category'), subTextColor), _buildDropdown(_selectedCategory, categories, (val) => setState(() { _selectedCategory = val!; _isShortcutUsed = false; }), cardBg, textColor, disabled: _isShortcutUsed)])), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Status', subTextColor), _buildDropdown(_selectedStatus, statuses, (val) => setState(() => _selectedStatus = val!), cardBg, textColor)]))])),
                        
                        if (_selectedCategory.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          FadeInSlide(delay: const Duration(milliseconds: 150), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Nama Layanan', 'Service Name'), subTextColor), _buildTextField(_nameCtrl, _getHintForCategory(_selectedCategory), cardBg, textColor, hintColor)])),
                          FadeInSlide(delay: const Duration(milliseconds: 200), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Harga', 'Price'), subTextColor), 
                            ValueListenableBuilder<String>(
                              valueListenable: currencyNotifier,
                              builder: (context, currency, _) {
                                final format = CurrencyUtils.getFormat(currency);
                                final prefix = format.currencySymbol + ' ';
                                return _buildTextField(_priceCtrl, tr('Misal: 150.000', 'E.g: 150,000'), cardBg, textColor, hintColor, isNumber: true, prefixText: prefix, formatters: [ThousandsSeparatorInputFormatter()]);
                              }
                            )
                          ])),
                          FadeInSlide(delay: const Duration(milliseconds: 250), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Waktu Pengingat (Tanggal & Jam)', 'Reminder Time (Date & Time)'), subTextColor), Row(children: [Expanded(flex: 3, child: GestureDetector(onTap: () => _selectDate(context), child: _buildFakeInput(DateFormat('dd MMM yyyy').format(_selectedDate), Icons.calendar_month, cardBg, textColor, hintColor))), const SizedBox(width: 12), Expanded(flex: 2, child: GestureDetector(onTap: () => _selectTime(context), child: _buildFakeInput(_selectedTime.format(context), Icons.access_time_filled, cardBg, textColor, hintColor)))])])),
                          FadeInSlide(delay: const Duration(milliseconds: 300), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Ingatkan Saya Pada', 'Remind Me On'), subTextColor), _buildDropdown('H-$_reminderDays', ['H-0', 'H-1', 'H-3', 'H-7'], (val) { setState(() => _reminderDays = int.parse(val!.replaceAll('H-', ''))); }, cardBg, textColor)])),
                          FadeInSlide(delay: const Duration(milliseconds: 350), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Tipe Pengingat', 'Reminder Type'), subTextColor), _buildDropdown(_selectedNotifType, notifTypes, (val) => setState(() => _selectedNotifType = val!), cardBg, textColor)])),
                          const SizedBox(height: 20),
                          FadeInSlide(delay: const Duration(milliseconds: 400), child: _buildSwitch(tr('Perpanjangan Otomatis', 'Auto Renewal'), _isAutoRenew, (val) => setState(() => _isAutoRenew = val), textColor, hintColor)),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24), width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                    onPressed: () async { 
                      if (_selectedCategory.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Pilih kategori terlebih dahulu', 'Select a category first'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 15), Shadow(color: Colors.black, blurRadius: 8)])), backgroundColor: Colors.transparent, elevation: 0, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.only(bottom: 130)));
                        return;
                      }
                      if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                        DateTime exactDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                        DateTime scheduledDateTime = exactDateTime.subtract(Duration(days: _reminderDays));

                        if (scheduledDateTime.isBefore(DateTime.now())) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Jadwal pengingat sudah terlewat', 'Reminder schedule has passed'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 15), Shadow(color: Colors.black, blurRadius: 8)])), backgroundColor: Colors.transparent, elevation: 0, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.only(bottom: 130)));
                          return; 
                        }

                        final newSub = Subscription(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameCtrl.text, price: double.tryParse(_priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0, dueDate: exactDateTime, category: _selectedCategory);
                        context.read<SubProvider>().addSub(newSub);

                        final prefs = await SharedPreferences.getInstance();
                        final savedName = prefs.getString('user_name') ?? ''; 

                        
                        final notifTitle = savedName.isEmpty 
                            ? tr('Pengingat: Tagihan ${newSub.name} 💸', 'Reminder: ${newSub.name} Bill 💸')
                            : tr('Halo $savedName! Pengingat: Tagihan ${newSub.name} 💸', 'Hi $savedName! Reminder: ${newSub.name} Bill 💸');
                        
                        final notifBody = tr('Pembayaran layanan sebesar Rp ${_priceCtrl.text} telah tiba waktunya.', 'Your service payment of \$${_priceCtrl.text} is due.');
                        final bool isUsingAlarm = _selectedNotifType == tr('Alarm Lagu (Terus Berdering)', 'Music Alarm (Rings Continuously)');

                        try { NotificationService.scheduleNotification(newSub.id.hashCode, notifTitle, notifBody, scheduledDateTime, isAlarm: isUsingAlarm); } catch (_) {}
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('Berhasil ditambahkan', 'Successfully added'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 15), Shadow(color: Colors.black, blurRadius: 8)])),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.only(bottom: 130),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context); 
                        }
                      }
                    },
                    child: Text(tr('TAMBAHKAN', 'ADD NEW'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCategoryIcons(List<String> categories, Color cardBg, Color textColor) {
    Map<String, List<String>> appExamples = {
      'Hiburan': ['Netflix', 'Disney+', 'Prime Video', 'HBO Go', 'Vidio'],
      'Entertainment': ['Netflix', 'Disney+', 'Prime Video', 'HBO Go', 'Hulu'],
      'Musik': ['Spotify', 'Apple Music', 'YouTube Music', 'Joox'],
      'Music': ['Spotify', 'Apple Music', 'YouTube Music', 'Tidal'],
      'Software': ['Adobe CC', 'Microsoft 365', 'Canva Pro', 'Figma'],
      'Utilitas': ['PLN', 'IndiHome', 'Biznet', 'PDAM'],
      'Utilities': ['Electricity', 'Internet', 'Water', 'Gas'],
      'Belanja': ['Shopee', 'Tokopedia', 'Amazon Prime', 'Lazada'],
      'Shopping': ['Amazon Prime', 'Walmart+', 'Shopee'],
      'Game': ['Xbox Game Pass', 'PS Plus', 'Steam', 'Nintendo Switch'],
      'Edukasi': ['Duolingo', 'Ruangguru', 'Udemy', 'Coursera'],
      'Education': ['Duolingo', 'Udemy', 'Coursera', 'Skillshare'],
      'Cloud Storage': ['Google One', 'iCloud', 'Dropbox', 'OneDrive'],
      'Lainnya': [],
      'Others': [],
    };

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFF0D9488), size: 18),
              const SizedBox(width: 8),
              Text(tr('Pilih Pintasan Kategori', 'Select Category Shortcut'), style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                
                IconData iconData = Icons.category;
                if (cat == 'Hiburan' || cat == 'Entertainment') iconData = Icons.movie_creation_rounded;
                if (cat == 'Musik' || cat == 'Music') iconData = Icons.headphones_rounded;
                if (cat == 'Software') iconData = Icons.computer_rounded;
                if (cat == 'Utilitas' || cat == 'Utilities') iconData = Icons.bolt_rounded;
                if (cat == 'Belanja' || cat == 'Shopping') iconData = Icons.shopping_bag_rounded;
                if (cat == 'Game') iconData = Icons.videogame_asset_rounded;
                if (cat == 'Edukasi' || cat == 'Education') iconData = Icons.school_rounded;
                if (cat == 'Cloud Storage') iconData = Icons.cloud_rounded;
                if (cat == 'Lainnya' || cat == 'Others') iconData = Icons.dashboard_customize_rounded;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategory = '';
                        _isShortcutUsed = false;
                        _nameCtrl.text = '';
                      } else {
                        _selectedCategory = cat;
                        _isShortcutUsed = true;
                        _nameCtrl.text = ''; 
                      }
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D9488) : cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.white10, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconData, color: isSelected ? Colors.white : textColor.withValues(alpha: 0.5), size: 30),
                        const SizedBox(height: 8),
                        Text(cat, style: TextStyle(color: isSelected ? Colors.white : textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isShortcutUsed && appExamples[_selectedCategory] != null && appExamples[_selectedCategory]!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: appExamples[_selectedCategory]!.map((appName) {
                return ActionChip(
                  backgroundColor: cardBg,
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  label: Text(appName, style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: () {
                    setState(() {
                      _nameCtrl.text = appName;
                    });
                  },
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) { return Padding(padding: const EdgeInsets.only(bottom: 8, left: 4, top: 16), child: Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))); }
  Widget _buildTextField(TextEditingController ctrl, String hint, Color bg, Color textColor, Color hintColor, {bool isNumber = false, String? prefixText, List<TextInputFormatter>? formatters}) { return Container(padding: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)), child: TextField(controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold), inputFormatters: formatters, decoration: InputDecoration(prefixText: prefixText, prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16), hintText: hint, hintStyle: TextStyle(color: hintColor), border: InputBorder.none, contentPadding: const EdgeInsets.all(18)))); }
  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, Color bg, Color textColor, {bool disabled = false}) { 
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16), 
          decoration: BoxDecoration(color: disabled ? bg.withValues(alpha: 0.5) : bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)), 
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (value == null || value.isEmpty) ? null : value, 
              hint: Text(tr('Pilih', 'Select'), style: TextStyle(color: textColor.withValues(alpha: 0.5))),
              isExpanded: true, 
              dropdownColor: bg, 
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold), 
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
              onChanged: onChanged
            )
          )
        )
      )
    ); 
  }
  Widget _buildFakeInput(String text, IconData icon, Color bg, Color textColor, Color hintColor) { return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg == Colors.white ? Colors.grey.shade300 : Colors.transparent)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Icon(icon, color: hintColor, size: 20)])); }
  Widget _buildSwitch(String label, bool value, Function(bool) onChanged, Color textColor, Color hintColor) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)), Switch(value: value, onChanged: onChanged, activeColor: Colors.black, activeTrackColor: const Color(0xFF0D9488), inactiveTrackColor: hintColor)]); }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return oldValue;
    final intValue = int.tryParse(cleanText);
    if (intValue == null) return oldValue;
    final String newText = NumberFormat.decimalPattern('id').format(intValue);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}