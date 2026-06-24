import 'package:flutter/material.dart';
import '../utils/toast_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';
import '../utils/currency_utils.dart';
import 'dashboard_screen.dart'; 
import 'package:flutter/services.dart';
import '../utils/category_utils.dart';

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
  bool _isTrial = false;
  int _splitCount = 1;
  String _selectedStatus = '';
  int _reminderDays = 0; 
  String _selectedNotifType = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: const Color(0xFF2563EB), onPrimary: Colors.white, surface: surfaceColor, onSurface: onSurfaceColor)), child: child!);
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final TimeOfDay? picked = await showGeneralDialog<TimeOfDay>(
      context: context, barrierDismissible: true, barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, barrierColor: Colors.black87, transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim, secAnim) {
        return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: const Color(0xFF2563EB), onPrimary: Colors.white, surface: surfaceColor, onSurface: onSurfaceColor)), child: TimePickerDialog(initialTime: _selectedTime));
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

  void _showAddCustomCategoryDialog() {
    final newCatCtrl = TextEditingController();
    Color tempColor = Colors.blue;
    IconData tempIcon = Icons.star_rounded;

    final List<Color> colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.pink, Colors.teal, Colors.brown];
    final List<IconData> icons = [Icons.star_rounded, Icons.favorite_rounded, Icons.work_rounded, Icons.home_rounded, Icons.sports_esports_rounded, Icons.fitness_center_rounded, Icons.pets_rounded, Icons.local_dining_rounded];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(tr('Kategori Baru', 'New Category'), style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: newCatCtrl, decoration: InputDecoration(hintText: tr('Nama Kategori', 'Category Name'))),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: colors.map((c) => GestureDetector(
                        onTap: () => setDialogState(() => tempColor = c),
                        child: CircleAvatar(backgroundColor: c, radius: 18, child: tempColor == c ? const Icon(Icons.check, color: Colors.white, size: 20) : null),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12, runSpacing: 12,
                      children: icons.map((i) => GestureDetector(
                        onTap: () => setDialogState(() => tempIcon = i),
                        child: CircleAvatar(backgroundColor: tempColor.withOpacity(0.1), radius: 18, child: Icon(i, color: tempIcon == i ? tempColor : Colors.grey, size: 24)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'))),
                TextButton(
                  onPressed: () async {
                    if (newCatCtrl.text.isNotEmpty) {
                      await CategoryUtils.addCustomCategory(newCatCtrl.text, tempColor, tempIcon);
                      Navigator.pop(ctx);
                      setState(() { _selectedCategory = newCatCtrl.text; });
                    }
                  }, 
                  child: Text(tr('Simpan', 'Save'), style: const TextStyle(fontWeight: FontWeight.bold))
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = CategoryUtils.getAllCategories(languageNotifier.value == 'ID');
    categories.add(tr('+ Tambah Kategori Baru', '+ Add New Category'));
    final List<String> statuses = [tr('Aktif', 'Active'), tr('Non-Aktif', 'Inactive')];
    final List<String> notifTypes = [tr('Notifikasi Biasa', 'Standard Notification'), tr('Alarm Lagu (Terus Berdering)', 'Music Alarm (Rings Continuously)')];

    if (_selectedStatus.isEmpty) _selectedStatus = statuses.first;
    if (_selectedNotifType.isEmpty) _selectedNotifType = notifTypes.first;

    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, _, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor; 
        Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white; 
        Color textColor = isDark ? Colors.white : const Color(0xFF1E293B); 
        Color subTextColor = isDark ? Colors.white70 : Colors.black54; 
        Color hintColor = isDark ? Colors.white38 : Colors.black38; 
        Color appBarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A);

        return Scaffold(
          backgroundColor: scaffoldBg, 
          appBar: AppBar(
            backgroundColor: appBarBg, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text(tr('Tambah Langganan', 'Add Subscription'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInSlide(delay: const Duration(milliseconds: 50), child: _buildCategoryIcons(categories, cardBg, textColor)),
                        const SizedBox(height: 12),
                        FadeInSlide(delay: const Duration(milliseconds: 100), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Kategori', 'Category'), subTextColor), _buildDropdown(_selectedCategory, categories, (val) {
                          if (val == tr('+ Tambah Kategori Baru', '+ Add New Category')) {
                            _showAddCustomCategoryDialog();
                          } else {
                            setState(() { _selectedCategory = val!; _isShortcutUsed = false; });
                          }
                        }, cardBg, textColor, disabled: _isShortcutUsed)])), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Status', subTextColor), _buildDropdown(_selectedStatus, statuses, (val) => setState(() => _selectedStatus = val!), cardBg, textColor)]))])),
                        
                        if (_selectedCategory.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          FadeInSlide(delay: const Duration(milliseconds: 150), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Nama Layanan', 'Service Name'), subTextColor), _buildTextField(_nameCtrl, _getHintForCategory(_selectedCategory), cardBg, textColor, hintColor)])),
                          FadeInSlide(delay: const Duration(milliseconds: 200), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Harga', 'Price'), subTextColor), 
                            ValueListenableBuilder<String>(
                              valueListenable: currencyNotifier,
                              builder: (context, currency, _) {
                                final format = CurrencyUtils.getFormat(currency);
                                final prefix = format.currencySymbol + ' ';
                                final isZeroDecimal = currency == 'IDR' || currency == 'JPY';
                                return _buildTextField(
                                  _priceCtrl, 
                                  isZeroDecimal ? tr('Misal: 150.000', 'E.g: 150,000') : tr('Misal: 9.99', 'E.g: 9.99'), 
                                  cardBg, textColor, hintColor, 
                                  isNumber: true, 
                                  prefixText: prefix, 
                                  formatters: isZeroDecimal ? [ThousandsSeparatorInputFormatter()] : []
                                );
                              }
                            )
                          ])),
                          FadeInSlide(delay: const Duration(milliseconds: 250), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Waktu Pengingat (Tanggal & Jam)', 'Reminder Time (Date & Time)'), subTextColor), Row(children: [Expanded(flex: 3, child: GestureDetector(onTap: () => _selectDate(context), child: _buildFakeInput(DateFormat('dd MMM yyyy').format(_selectedDate), Icons.calendar_month, cardBg, textColor, hintColor))), const SizedBox(width: 12), Expanded(flex: 2, child: GestureDetector(onTap: () => _selectTime(context), child: _buildFakeInput(_selectedTime.format(context), Icons.access_time_filled, cardBg, textColor, hintColor)))])])),
                          FadeInSlide(delay: const Duration(milliseconds: 300), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Ingatkan Saya Pada', 'Remind Me On'), subTextColor), _buildDropdown('H-$_reminderDays', ['H-0', 'H-1', 'H-3', 'H-7'], (val) { setState(() => _reminderDays = int.parse(val!.replaceAll('H-', ''))); }, cardBg, textColor)])),
                          FadeInSlide(delay: const Duration(milliseconds: 350), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel(tr('Tipe Pengingat', 'Reminder Type'), subTextColor), _buildDropdown(_selectedNotifType, notifTypes, (val) => setState(() => _selectedNotifType = val!), cardBg, textColor)])),
                          const SizedBox(height: 14),
                          FadeInSlide(delay: const Duration(milliseconds: 380), child: _buildSplitCounter(tr('Patungan / Split Bill (Orang)', 'Split Bill (People)'), _splitCount, (val) => setState(() => _splitCount = val), textColor, cardBg)),
                          const SizedBox(height: 14),
                          FadeInSlide(delay: const Duration(milliseconds: 400), child: _buildSwitch(tr('Masa Uji Coba (Free Trial)', 'Free Trial'), _isTrial, (val) => setState(() => _isTrial = val), textColor, hintColor)),
                          FadeInSlide(delay: const Duration(milliseconds: 420), child: _buildSwitch(tr('Perpanjangan Otomatis', 'Auto Renewal'), _isAutoRenew, (val) => setState(() => _isAutoRenew = val), textColor, hintColor)),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12), width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: () async { 
                      if (_selectedCategory.isEmpty) {
                        ToastUtils.show(context, tr('Pilih kategori terlebih dahulu', 'Select a category first'), icon: Icons.warning_rounded, iconColor: Colors.redAccent);
                        return;
                      }
                      if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                        DateTime exactDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                        DateTime scheduledDateTime = exactDateTime.subtract(Duration(days: _reminderDays));

                        if (scheduledDateTime.isBefore(DateTime.now())) {
                          ToastUtils.show(context, tr('Jadwal pengingat sudah terlewat', 'Reminder schedule has passed'), icon: Icons.info_outline, iconColor: Colors.blueAccent);
                          return; 
                        }

                        final newSub = Subscription(id: DateTime.now().millisecondsSinceEpoch.toString(), name: _nameCtrl.text, price: CurrencyUtils.parsePrice(_priceCtrl.text, currencyNotifier.value), dueDate: exactDateTime, category: _selectedCategory, isTrial: _isTrial, splitCount: _splitCount, currency: currencyNotifier.value);
                        context.read<SubProvider>().addSub(newSub);

                        final prefs = await SharedPreferences.getInstance();
                        final savedName = prefs.getString('user_name') ?? ''; 

                        
                        final notifTitle = savedName.isEmpty 
                            ? tr('Tagihan ${newSub.name} 💸', '${newSub.name} Bill 💸')
                            : tr('Halo $savedName! Tagihan ${newSub.name} 💸', 'Hi $savedName! ${newSub.name} Bill 💸');
                        
                        final notifBody = tr('Pembayaran layanan sebesar Rp ${_priceCtrl.text} telah tiba waktunya.', 'Your service payment of \$${_priceCtrl.text} is due.');
                        final bool isUsingAlarm = _selectedNotifType == tr('Alarm Lagu (Terus Berdering)', 'Music Alarm (Rings Continuously)');

                        try { NotificationService.scheduleNotification(newSub.id.hashCode, notifTitle, notifBody, scheduledDateTime, isAlarm: isUsingAlarm); } catch (_) {}
                        if (mounted) {
                          ToastUtils.show(context, tr('Berhasil ditambahkan', 'Successfully added'));
                          Navigator.pop(context); 
                        }
                      }
                    },
                    child: Text(tr('TAMBAHKAN', 'ADD NEW'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Text(tr('Pilih Pintasan Kategori', 'Select Category Shortcut'), style: TextStyle(color: textColor.withValues(alpha: 0.8), fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 65,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                IconData iconData = CategoryUtils.getIcon(cat);
                Color catColor = CategoryUtils.getColor(cat);

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
                    width: 70,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.black12, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(iconData, color: isSelected ? Colors.white : catColor, size: 22),
                        const SizedBox(height: 8),
                        Text(cat, style: TextStyle(color: isSelected ? Colors.white : textColor.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isShortcutUsed && appExamples[_selectedCategory] != null && appExamples[_selectedCategory]!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: appExamples[_selectedCategory]!.map((appName) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _nameCtrl.text = appName;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(appName, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildLabel(String text, Color color) { return Padding(padding: const EdgeInsets.only(bottom: 6, left: 4, top: 12), child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))); }
  Widget _buildTextField(TextEditingController ctrl, String hint, Color bg, Color textColor, Color hintColor, {bool isNumber = false, String? prefixText, List<TextInputFormatter>? formatters}) { 
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4), 
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)), 
      child: TextField(
        controller: ctrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), 
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold), 
        inputFormatters: formatters, 
        decoration: InputDecoration(prefixText: prefixText, prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12), hintText: hint, hintStyle: TextStyle(color: hintColor), border: InputBorder.none, contentPadding: const EdgeInsets.all(16))
      )
    ); 
  }
  Widget _buildDropdown(String? value, List<String> items, Function(String?) onChanged, Color bg, Color textColor, {bool disabled = false}) { 
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), 
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)), 
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
  Widget _buildFakeInput(String text, IconData icon, Color bg, Color textColor, Color hintColor) { 
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.transparent)), 
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Icon(icon, color: hintColor, size: 20)])
    ); 
  }
  Widget _buildSwitch(String label, bool value, Function(bool) onChanged, Color textColor, Color hintColor) { return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)), Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF2563EB), activeTrackColor: const Color(0xFF93C5FD), inactiveTrackColor: hintColor)]); }
  Widget _buildSplitCounter(String label, int count, Function(int) onChanged, Color textColor, Color cardBg) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove_circle_outline, color: textColor), onPressed: count > 1 ? () => onChanged(count - 1) : null),
            Text('$count', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(icon: Icon(Icons.add_circle_outline, color: textColor), onPressed: () => onChanged(count + 1)),
          ],
        )
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return oldValue;
    final intValue = int.tryParse(cleanText);
    if (intValue == null || intValue > 1000000000) return oldValue;
    final String newText = NumberFormat.decimalPattern('id').format(intValue);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}