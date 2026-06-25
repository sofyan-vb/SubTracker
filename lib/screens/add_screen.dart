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
import 'package:image_picker/image_picker.dart';
import '../widgets/logo_widget.dart';
import 'dart:io';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String _searchQuery = "";
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _trialPriceCtrl = TextEditingController();
  final _cancelLinkCtrl = TextEditingController();
  
  String _selectedCategory = '';
  bool _isShortcutUsed = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now(); 
  
  bool _isAutoRenew = true;
  bool _isTrial = false;
  DateTime? _trialEndDate;
  String _billingCycle = 'Bulanan';
  
  int _splitCount = 1;
  String _selectedStatus = '';
  int _reminderDays = 0; 
  String _selectedNotifType = '';
  String? _customLogoPath;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _trialPriceCtrl.dispose();
    _cancelLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {required bool isTrial}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final DateTime? picked = await showDatePicker(
      context: context, initialDate: isTrial ? (_trialEndDate ?? DateTime.now()) : _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF2563EB), 
                  onPrimary: Colors.white, 
                  surface: surfaceColor, 
                  onSurface: onSurfaceColor,
                ),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: surfaceColor,
                  headerBackgroundColor: const Color(0xFF2563EB),
                  headerForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  dayStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB), 
                    textStyle: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              child: child!,
            );
      },
    );
    if (picked != null) {
      setState(() {
        if (isTrial) {
          _trialEndDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color onSurfaceColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final TimeOfDay? picked = await showGeneralDialog<TimeOfDay>(
      context: context, barrierDismissible: true, barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, barrierColor: Colors.black87, transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim, secAnim) {
        return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: const Color(0xFF2563EB), 
                    onPrimary: Colors.white, 
                    surface: surfaceColor, 
                    onSurface: onSurfaceColor,
                  ),
                  timePickerTheme: TimePickerThemeData(
                    backgroundColor: surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    dialHandColor: const Color(0xFF2563EB),
                    dialBackgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    hourMinuteTextStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB), 
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                child: TimePickerDialog(
                  initialTime: _selectedTime, 
                )
              ),
            );
      },
      transitionBuilder: (context, anim, secAnim, child) {
        return FadeTransition(opacity: anim, child: ScaleTransition(scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack), child: child));
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
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
    final List<String> billingCycles = [tr('Bulanan', 'Monthly'), tr('Tahunan', 'Yearly')];

    if (_selectedStatus.isEmpty) _selectedStatus = statuses.first;
    if (_selectedNotifType.isEmpty) _selectedNotifType = notifTypes.first;
    if (_billingCycle.isEmpty) _billingCycle = billingCycles.first;

    return ValueListenableBuilder<String>(
      valueListenable: themeNotifier,
      builder: (context, _, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor; 
        Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white; 
        Color textColor = isDark ? Colors.white : const Color(0xFF1E293B); 
        Color subTextColor = isDark ? Colors.white70 : Colors.black54; 
        Color hintColor = isDark ? Colors.white38 : Colors.black38; 
        Color dividerColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.08);
        Color appBarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A);

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: appBarBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(tr('Tambah Langganan', 'Add subscription'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimalistic Search Bar without borders
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                      hintText: tr('Cari layanan / katalog', 'Search catalog'),
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernCategoryIcons(categories, cardBg, textColor, isDark),
                
                const SizedBox(height: 24),
                Text(tr('Detail Utama', 'Main Details'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Name and Price
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => _customLogoPath = picked.path);
                        }
                      },
                      child: Stack(
                        children: [
                          _customLogoPath != null
                              ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(_customLogoPath!), width: 56, height: 56, fit: BoxFit.cover))
                              : LogoWidget(name: _nameCtrl.text, category: _selectedCategory, size: 56, borderRadius: 16),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 12),
                            )
                          )
                        ]
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                        child: TextField(
                          controller: _nameCtrl, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                          decoration: InputDecoration(hintText: tr('Nama Layanan', 'Service Name'), hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.normal), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16))
                        ),
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<String>(
                  valueListenable: currencyNotifier,
                  builder: (context, currency, _) {
                    final format = CurrencyUtils.getFormat(currency);
                    final isZeroDecimal = currency == 'IDR' || currency == 'JPY';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                      child: TextField(
                        controller: _priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                        inputFormatters: isZeroDecimal ? [ThousandsSeparatorInputFormatter()] : [],
                        decoration: InputDecoration(prefixText: '${format.currencySymbol} ', prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold), hintText: tr('Harga', 'Price'), hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.normal), border: InputBorder.none)
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 24),
                Text(tr('Informasi Tagihan', 'Billing Info'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // Billing Info (Category, Cycle, Next Renewal)
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.category, color: Color(0xFF2563EB), size: 20)),
                        title: Text(tr('Kategori', 'Category'), style: TextStyle(color: subTextColor, fontSize: 13)),
                        subtitle: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory.isEmpty ? null : _selectedCategory,
                            hint: Text(tr('Pilih kategori', 'Choose category'), style: TextStyle(color: textColor)),
                            isExpanded: true, dropdownColor: cardBg, style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) {
                              if (val == tr('+ Tambah Kategori Baru', '+ Add New Category')) {
                                _showAddCustomCategoryDialog();
                              } else {
                                setState(() { _selectedCategory = val!; _isShortcutUsed = false; });
                              }
                            }
                          ),
                        ),
                      ),
                      Divider(color: dividerColor, height: 1, indent: 60),
                      ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.autorenew_rounded, color: Color(0xFF10B981), size: 20)),
                        title: Text(tr('Siklus', 'Cycle'), style: TextStyle(color: subTextColor, fontSize: 13)),
                        subtitle: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _billingCycle,
                            isExpanded: true, dropdownColor: cardBg, style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
                            items: billingCycles.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                            onChanged: (val) => setState(() => _billingCycle = val!)
                          ),
                        ),
                      ),
                      Divider(color: dividerColor, height: 1, indent: 60),
                      ListTile(
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.calendar_month, color: Color(0xFFF59E0B), size: 20)),
                        title: Text(tr('Tanggal Perpanjangan', 'Next renewal date'), style: TextStyle(color: subTextColor, fontSize: 13)),
                        subtitle: Row(
                          children: [
                            Expanded(child: GestureDetector(onTap: () => _selectDate(context, isTrial: false), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate), style: TextStyle(color: textColor, fontWeight: FontWeight.w500))))),
                            Expanded(child: GestureDetector(onTap: () => _selectTime(context), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_selectedTime.format(context), style: TextStyle(color: textColor, fontWeight: FontWeight.w500), textAlign: TextAlign.right)))),
                          ],
                        ),
                      ),
                      Divider(color: dividerColor, height: 1, indent: 60),
                      SwitchListTile(
                        value: _isAutoRenew,
                        onChanged: (v) => setState(() => _isAutoRenew = v),
                        title: Text(tr('Perpanjangan Otomatis', 'Auto-renewing'), style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15)),
                        activeColor: const Color(0xFF2563EB),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Advanced / Trial inside ExpansionTiles
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.card_giftcard_rounded, color: Color(0xFFEC4899)),
                      title: Text(tr('Pelacakan Uji Coba', 'Trial Tracking'), style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tr('Sedang uji coba gratis', 'On free trial'), style: TextStyle(color: textColor)),
                                  Switch(value: _isTrial, onChanged: (v) => setState(() => _isTrial = v), activeColor: const Color(0xFF2563EB)),
                                ],
                              ),
                              if (_isTrial) ...[
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => _selectDate(context, isTrial: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_trialEndDate != null ? DateFormat('MMM dd, yyyy').format(_trialEndDate!) : tr('Pilih tanggal berakhir', 'Select end date'), style: TextStyle(color: _trialEndDate != null ? textColor : hintColor)), Icon(Icons.calendar_month, color: hintColor, size: 20)]),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ValueListenableBuilder<String>(
                                  valueListenable: currencyNotifier,
                                  builder: (context, currency, _) {
                                    final format = CurrencyUtils.getFormat(currency);
                                    final isZeroDecimal = currency == 'IDR' || currency == 'JPY';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                      child: TextField(
                                        controller: _trialPriceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        style: TextStyle(color: textColor),
                                        inputFormatters: isZeroDecimal ? [ThousandsSeparatorInputFormatter()] : [],
                                        decoration: InputDecoration(prefixText: '${format.currencySymbol} ', prefixStyle: TextStyle(color: textColor), hintText: tr('Harga normal setelah trial', 'Regular price after trial'), hintStyle: TextStyle(color: hintColor), border: InputBorder.none)
                                      ),
                                    );
                                  }
                                ),
                                const SizedBox(height: 8),
                              ]
                            ],
                          ),
                        )
                      ]
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white24 : Colors.black12)),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(Icons.settings_rounded, color: Color(0xFF64748B)),
                      title: Text(tr('Pengaturan Lanjutan', 'Advanced Settings'), style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                child: TextField(
                                  controller: _cancelLinkCtrl, style: TextStyle(color: textColor),
                                  decoration: InputDecoration(hintText: tr('Tautan pembatalan', 'Cancellation link'), hintStyle: TextStyle(color: hintColor), border: InputBorder.none, icon: Icon(Icons.link, color: hintColor, size: 20))
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: 'H-$_reminderDays',
                                          isExpanded: true, dropdownColor: cardBg, style: TextStyle(color: textColor),
                                          items: ['H-0', 'H-1', 'H-3', 'H-7'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                          onChanged: (val) { setState(() => _reminderDays = int.parse(val!.replaceAll('H-', ''))); }
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedNotifType,
                                          isExpanded: true, dropdownColor: cardBg, style: TextStyle(color: textColor),
                                          items: notifTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                          onChanged: (val) => setState(() => _selectedNotifType = val!)
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tr('Split Bill (Orang)', 'Split Bill (People)'), style: TextStyle(color: textColor)),
                                  Row(
                                    children: [
                                      IconButton(icon: Icon(Icons.remove_circle_outline, color: textColor), onPressed: _splitCount > 1 ? () => setState(() => _splitCount--) : null),
                                      Text('$_splitCount', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      IconButton(icon: Icon(Icons.add_circle_outline, color: textColor), onPressed: () => setState(() => _splitCount++)),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(tr('Sudah dinonaktifkan', 'Already cancelled'), style: TextStyle(color: textColor)),
                                  Switch(value: _selectedStatus == tr('Non-Aktif', 'Inactive'), onChanged: (v) => setState(() => _selectedStatus = v ? statuses.last : statuses.first), activeColor: Colors.redAccent),
                                ],
                              ),
                            ]
                          )
                        )
                      ]
                    )
                  )
                ),
                
                const SizedBox(height: 100), // padding for FAB
              ]
            )
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onPressed: () async { 
                if (_selectedCategory.isEmpty) {
                  ToastUtils.show(context, tr('Pilih kategori terlebih dahulu', 'Select a category first'), icon: Icons.warning_rounded, iconColor: Colors.redAccent);
                  return;
                }
                if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                  DateTime exactDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                  DateTime scheduledDateTime = exactDateTime.subtract(Duration(days: _reminderDays));

                  if (scheduledDateTime.isBefore(DateTime.now()) && _selectedStatus == statuses.first) {
                    ToastUtils.show(context, tr('Jadwal pengingat sudah terlewat', 'Reminder schedule has passed'), icon: Icons.info_outline, iconColor: Colors.blueAccent);
                  }

                  final newSub = Subscription(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), 
                    name: _nameCtrl.text, 
                    price: CurrencyUtils.parsePrice(_priceCtrl.text, currencyNotifier.value), 
                    dueDate: exactDateTime, 
                    category: _selectedCategory, 
                    isTrial: _isTrial, 
                    splitCount: _splitCount, 
                    currency: currencyNotifier.value,
                    billingCycle: _billingCycle,
                    trialEndDate: _trialEndDate,
                    trialPrice: _trialPriceCtrl.text.isNotEmpty ? CurrencyUtils.parsePrice(_trialPriceCtrl.text, currencyNotifier.value) : null,
                    cancellationLink: _cancelLinkCtrl.text,
                    isAutoRenew: _isAutoRenew,
                    isFinished: _selectedStatus == statuses.last,
                    customLogoPath: _customLogoPath,
                  );
                  context.read<SubProvider>().addSub(newSub);

                  final prefs = await SharedPreferences.getInstance();
                  final savedName = prefs.getString('user_name') ?? ''; 
                  
                  final notifTitle = savedName.isEmpty 
                      ? tr('Tagihan ${newSub.name} 💸', '${newSub.name} Bill 💸')
                      : tr('Halo $savedName! Tagihan ${newSub.name} 💸', 'Hi $savedName! ${newSub.name} Bill 💸');
                  
                  final notifBody = tr('Pembayaran layanan sebesar Rp ${_priceCtrl.text} telah tiba waktunya.', 'Your service payment of ${_priceCtrl.text} is due.');
                  final bool isUsingAlarm = _selectedNotifType == tr('Alarm Lagu (Terus Berdering)', 'Music Alarm (Rings Continuously)');

                  if (_selectedStatus == statuses.first) {
                    try { NotificationService.scheduleNotification(newSub.id.hashCode, notifTitle, notifBody, scheduledDateTime, isAlarm: isUsingAlarm); } catch (_) {}
                  }
                  if (mounted) {
                    ToastUtils.show(context, tr('Berhasil ditambahkan', 'Successfully added'));
                    Navigator.pop(context); 
                  }
                } else {
                  ToastUtils.show(context, tr('Mohon isi nama dan harga', 'Please fill name and price'), icon: Icons.error_outline, iconColor: Colors.redAccent);
                }
              },
              icon: const Icon(Icons.check_rounded, size: 24),
              label: Text(tr('Simpan Langganan', 'Save Subscription'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    );
  }

  Widget _buildModernCategoryIcons(List<String> categories, Color cardBg, Color textColor, bool isDark) {
    Map<String, List<Map<String, dynamic>>> appExamples = {
      'Hiburan': [
        {'name': 'Netflix', 'color': const Color(0xFFE50914), 'icon': Icons.movie},
        {'name': 'Disney+', 'color': const Color(0xFF113CCF), 'icon': Icons.movie_filter},
        {'name': 'Prime Video', 'color': const Color(0xFF00A8E1), 'icon': Icons.ondemand_video},
        {'name': 'HBO Go', 'color': const Color(0xFF5A1C8E), 'icon': Icons.live_tv},
        {'name': 'Vidio', 'color': const Color(0xFFED2324), 'icon': Icons.play_circle_filled},
        {'name': 'YouTube Premium', 'color': const Color(0xFFFF0000), 'icon': Icons.play_arrow},
        {'name': 'Viu', 'color': const Color(0xFFFFCC00), 'icon': Icons.ondemand_video},
        {'name': 'WeTV', 'color': const Color(0xFF00BFFF), 'icon': Icons.ondemand_video},
        {'name': 'iQIYI', 'color': const Color(0xFF00E676), 'icon': Icons.ondemand_video},
        {'name': 'Catchplay', 'color': const Color(0xFF000000), 'icon': Icons.ondemand_video},
        {'name': 'Apple TV+', 'color': const Color(0xFF000000), 'icon': Icons.apple},
        {'name': 'Crunchyroll', 'color': const Color(0xFFF47521), 'icon': Icons.ondemand_video},
        {'name': 'Mola TV', 'color': const Color(0xFF000000), 'icon': Icons.live_tv},
        {'name': 'MAXstream', 'color': const Color(0xFFED1C24), 'icon': Icons.live_tv},
        {'name': 'Vision+', 'color': const Color(0xFFED1C24), 'icon': Icons.live_tv},
        {'name': 'Hulu', 'color': const Color(0xFF1CE783), 'icon': Icons.live_tv},
        {'name': 'Paramount+', 'color': const Color(0xFF0064FF), 'icon': Icons.live_tv},
        {'name': 'Peacock', 'color': const Color(0xFF000000), 'icon': Icons.live_tv},
        {'name': 'Bilibili', 'color': const Color(0xFF00A1D6), 'icon': Icons.live_tv},
        {'name': 'Viki', 'color': const Color(0xFF00A5D2), 'icon': Icons.live_tv},
      ],
      'Musik': [
        {'name': 'Spotify', 'color': const Color(0xFF1DB954), 'icon': Icons.music_note},
        {'name': 'Apple Music', 'color': const Color(0xFFFA243C), 'icon': Icons.music_note},
        {'name': 'YouTube Music', 'color': const Color(0xFFFF0000), 'icon': Icons.music_video},
        {'name': 'Joox', 'color': const Color(0xFF24B351), 'icon': Icons.library_music},
        {'name': 'Resso', 'color': const Color(0xFF000000), 'icon': Icons.library_music},
        {'name': 'SoundCloud', 'color': const Color(0xFFFF5500), 'icon': Icons.library_music},
        {'name': 'Tidal', 'color': const Color(0xFF000000), 'icon': Icons.library_music},
        {'name': 'Deezer', 'color': const Color(0xFF00C7F2), 'icon': Icons.library_music},
        {'name': 'Amazon Music', 'color': const Color(0xFF00A8E1), 'icon': Icons.library_music},
        {'name': 'Pandora', 'color': const Color(0xFF005483), 'icon': Icons.library_music},
        {'name': 'Audiomack', 'color': const Color(0xFFFFA200), 'icon': Icons.library_music},
      ],
      'Software': [
        {'name': 'Adobe CC', 'color': const Color(0xFFFF0000), 'icon': Icons.brush},
        {'name': 'Microsoft 365', 'color': const Color(0xFF00A4EF), 'icon': Icons.dashboard},
        {'name': 'Canva Pro', 'color': const Color(0xFF00C4CC), 'icon': Icons.design_services},
        {'name': 'ChatGPT Plus', 'color': const Color(0xFF10A37F), 'icon': Icons.smart_toy},
        {'name': 'GitHub Copilot', 'color': const Color(0xFF000000), 'icon': Icons.code},
        {'name': 'Notion', 'color': const Color(0xFF000000), 'icon': Icons.note},
        {'name': 'Figma', 'color': const Color(0xFFF24E1E), 'icon': Icons.brush},
        {'name': 'Evernote', 'color': const Color(0xFF00A82D), 'icon': Icons.note},
        {'name': 'Zoom', 'color': const Color(0xFF2D8CFF), 'icon': Icons.video_call},
        {'name': 'Slack', 'color': const Color(0xFF4A154B), 'icon': Icons.chat},
        {'name': 'Midjourney', 'color': const Color(0xFF000000), 'icon': Icons.brush},
        {'name': 'Claude', 'color': const Color(0xFFD97757), 'icon': Icons.smart_toy},
        {'name': 'Gemini', 'color': const Color(0xFF1A73E8), 'icon': Icons.smart_toy},
        {'name': 'Perplexity', 'color': const Color(0xFF21BCA5), 'icon': Icons.search},
        {'name': 'JetBrains', 'color': const Color(0xFF000000), 'icon': Icons.code},
        {'name': 'AutoCAD', 'color': const Color(0xFFE60000), 'icon': Icons.architecture},
        {'name': 'Grammarly', 'color': const Color(0xFF15A97D), 'icon': Icons.text_snippet},
      ],
      'Utilitas': [
        {'name': 'PDAM', 'color': const Color(0xFF2563EB), 'icon': Icons.water_drop},
        {'name': 'PLN', 'color': const Color(0xFFF59E0B), 'icon': Icons.electric_bolt},
        {'name': 'IndiHome', 'color': const Color(0xFFED1C24), 'icon': Icons.wifi},
        {'name': 'Telkomsel', 'color': const Color(0xFFED1C24), 'icon': Icons.phone_android},
        {'name': 'by.U', 'color': const Color(0xFF005BAC), 'icon': Icons.phone_android},
        {'name': 'XL', 'color': const Color(0xFF00B2E5), 'icon': Icons.phone_android},
        {'name': 'Indosat', 'color': const Color(0xFFFFD400), 'icon': Icons.phone_android},
        {'name': 'Smartfren', 'color': const Color(0xFFED1C24), 'icon': Icons.phone_android},
        {'name': 'Tri', 'color': const Color(0xFFE3000F), 'icon': Icons.phone_android},
        {'name': 'Axis', 'color': const Color(0xFF6B1D7C), 'icon': Icons.phone_android},
        {'name': 'MyRepublic', 'color': const Color(0xFF6B2C91), 'icon': Icons.wifi},
        {'name': 'Biznet', 'color': const Color(0xFF00A859), 'icon': Icons.wifi},
        {'name': 'First Media', 'color': const Color(0xFFED1C24), 'icon': Icons.wifi},
        {'name': 'Oxygen', 'color': const Color(0xFF000000), 'icon': Icons.wifi},
        {'name': 'BPJS', 'color': const Color(0xFF00A859), 'icon': Icons.health_and_safety},
        {'name': 'MNC Play', 'color': const Color(0xFF0F1568), 'icon': Icons.wifi},
        {'name': 'CBN', 'color': const Color(0xFF1C75BC), 'icon': Icons.wifi},
        {'name': 'Iconnet', 'color': const Color(0xFF00A859), 'icon': Icons.wifi},
        {'name': 'Megavision', 'color': const Color(0xFFE30613), 'icon': Icons.wifi},
        {'name': 'Transvision', 'color': const Color(0xFF003D7C), 'icon': Icons.live_tv},
      ],
      'Game': [
        {'name': 'PlayStation Plus', 'color': const Color(0xFF003791), 'icon': Icons.gamepad},
        {'name': 'Xbox Game Pass', 'color': const Color(0xFF107C10), 'icon': Icons.gamepad},
        {'name': 'Nintendo Switch Online', 'color': const Color(0xFFE60012), 'icon': Icons.gamepad},
        {'name': 'Steam', 'color': const Color(0xFF000000), 'icon': Icons.videogame_asset},
        {'name': 'EA Play', 'color': const Color(0xFFFF0000), 'icon': Icons.videogame_asset},
        {'name': 'Ubisoft+', 'color': const Color(0xFF000000), 'icon': Icons.videogame_asset},
        {'name': 'Riot Games', 'color': const Color(0xFFD32F2F), 'icon': Icons.videogame_asset},
        {'name': 'Roblox Premium', 'color': const Color(0xFF000000), 'icon': Icons.videogame_asset},
        {'name': 'Epic Games', 'color': const Color(0xFF000000), 'icon': Icons.videogame_asset},
        {'name': 'GeForce Now', 'color': const Color(0xFF76B900), 'icon': Icons.videogame_asset},
        {'name': 'Twitch', 'color': const Color(0xFF9146FF), 'icon': Icons.videogame_asset},
        {'name': 'Discord Nitro', 'color': const Color(0xFF5865F2), 'icon': Icons.chat},
      ],
      'Cloud Storage': [
        {'name': 'Google One', 'color': const Color(0xFF4285F4), 'icon': Icons.cloud},
        {'name': 'iCloud+', 'color': const Color(0xFF000000), 'icon': Icons.cloud},
        {'name': 'Dropbox', 'color': const Color(0xFF0061FE), 'icon': Icons.cloud},
        {'name': 'OneDrive', 'color': const Color(0xFF00A4EF), 'icon': Icons.cloud},
        {'name': 'Mega', 'color': const Color(0xFFD9272E), 'icon': Icons.cloud},
        {'name': 'Box', 'color': const Color(0xFF0061D5), 'icon': Icons.cloud},
        {'name': 'pCloud', 'color': const Color(0xFF00B0FF), 'icon': Icons.cloud},
        {'name': 'MediaFire', 'color': const Color(0xFF1296DF), 'icon': Icons.cloud},
        {'name': 'Terabox', 'color': const Color(0xFF0084FF), 'icon': Icons.cloud},
        {'name': 'Sync', 'color': const Color(0xFF00B2E2), 'icon': Icons.cloud},
      ],
      'Edukasi': [
        {'name': 'Ruangguru', 'color': const Color(0xFF0054A6), 'icon': Icons.school},
        {'name': 'Zenius', 'color': const Color(0xFF5A1C8E), 'icon': Icons.school},
        {'name': 'Udemy', 'color': const Color(0xFFA435F0), 'icon': Icons.school},
        {'name': 'Coursera', 'color': const Color(0xFF0056D2), 'icon': Icons.school},
        {'name': 'Skillshare', 'color': const Color(0xFF00FF84), 'icon': Icons.school},
        {'name': 'Duolingo', 'color': const Color(0xFF58CC02), 'icon': Icons.school},
        {'name': 'Memrise', 'color': const Color(0xFFFFB000), 'icon': Icons.school},
        {'name': 'MasterClass', 'color': const Color(0xFF000000), 'icon': Icons.school},
        {'name': 'Quipper', 'color': const Color(0xFF00A859), 'icon': Icons.school},
        {'name': 'Brainly', 'color': const Color(0xFF000000), 'icon': Icons.school},
        {'name': 'Kahoot', 'color': const Color(0xFF46178F), 'icon': Icons.school},
        {'name': 'LinkedIn Learning', 'color': const Color(0xFF0A66C2), 'icon': Icons.school},
        {'name': 'edX', 'color': const Color(0xFFB32332), 'icon': Icons.school},
        {'name': 'Codecademy', 'color': const Color(0xFF000000), 'icon': Icons.school},
      ],
      'Belanja': [
        {'name': 'Shopee', 'color': const Color(0xFFEE4D2D), 'icon': Icons.shopping_cart},
        {'name': 'Tokopedia', 'color': const Color(0xFF00AA5B), 'icon': Icons.shopping_bag},
        {'name': 'Lazada', 'color': const Color(0xFF0F1568), 'icon': Icons.shopping_cart},
        {'name': 'Blibli', 'color': const Color(0xFF0095DA), 'icon': Icons.shopping_bag},
        {'name': 'Bukalapak', 'color': const Color(0xFFE31E52), 'icon': Icons.shopping_cart},
        {'name': 'Amazon Prime', 'color': const Color(0xFFFF9900), 'icon': Icons.shopping_cart},
        {'name': 'AliExpress', 'color': const Color(0xFFFF4747), 'icon': Icons.shopping_cart},
        {'name': 'Gojek', 'color': const Color(0xFF00AA13), 'icon': Icons.motorcycle},
        {'name': 'Grab', 'color': const Color(0xFF00B14F), 'icon': Icons.motorcycle},
        {'name': 'Maxim', 'color': const Color(0xFFFFCC00), 'icon': Icons.motorcycle},
        {'name': 'Traveloka', 'color': const Color(0xFF00A1E4), 'icon': Icons.flight},
        {'name': 'Tiket.com', 'color': const Color(0xFF0064D2), 'icon': Icons.flight},
        {'name': 'Zalora', 'color': const Color(0xFF000000), 'icon': Icons.shopping_bag},
        {'name': 'Sociolla', 'color': const Color(0xFFE5007D), 'icon': Icons.shopping_bag},
        {'name': 'Agoda', 'color': const Color(0xFF000000), 'icon': Icons.hotel},
        {'name': 'Airbnb', 'color': const Color(0xFFFF5A5F), 'icon': Icons.hotel},
        {'name': 'eBay', 'color': const Color(0xFFE53238), 'icon': Icons.shopping_cart},
        {'name': 'Alibaba', 'color': const Color(0xFFFF6A00), 'icon': Icons.shopping_cart},
      ],
    };
    appExamples['Entertainment'] = appExamples['Hiburan']!;
    appExamples['Music'] = appExamples['Musik']!;
    appExamples['Utilities'] = appExamples['Utilitas']!;
    appExamples['Gaming'] = appExamples['Game']!;
    appExamples['Education'] = appExamples['Edukasi']!;
    appExamples['Shopping'] = appExamples['Belanja']!;

    final allApps = appExamples.values.expand((e) => e).toList();
    final filteredApps = _searchQuery.isEmpty 
        ? (appExamples[_selectedCategory] ?? [])
        : allApps.where((app) => app['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
    if (filteredApps.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filteredApps.length,
        itemBuilder: (context, index) {
          final app = filteredApps[index];
          final isAppSelected = _nameCtrl.text == app['name'];
          
          return GestureDetector(
            onTap: () => setState(() {
              _nameCtrl.text = app['name'];
              if (app['name'] == 'Gojek (GoClub)') _nameCtrl.text = 'Gojek';
              if (app['name'] == 'Grab (GrabUnlimited)') _nameCtrl.text = 'Grab';
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isAppSelected ? app['color'].withOpacity(0.15) : cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isAppSelected ? app['color'] : (isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  LogoWidget(name: app['name'], category: _selectedCategory.isEmpty ? 'Lainnya' : _selectedCategory, size: 24, borderRadius: 6),
                  if (isAppSelected) ...[
                    const SizedBox(width: 8),
                    Text(app['name'], style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
                  ]
                ],
              ),
            ),
          );
        },
      ),
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
