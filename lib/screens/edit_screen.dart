import 'package:flutter/material.dart';
import '../widgets/category_selection_sheet.dart';
import '../utils/app_examples.dart';
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

class EditScreen extends StatefulWidget {
  final Subscription sub;
  const EditScreen({super.key, required this.sub});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
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
    
    final sub = widget.sub;
    _nameCtrl.text = sub.name;
    
    if (sub.currency == 'IDR' || sub.currency == 'JPY') {
      _priceCtrl.text = NumberFormat.decimalPattern('id').format(sub.price);
    } else {
      _priceCtrl.text = sub.price.toString().replaceAll(RegExp(r'\.0$'), '');
    }
    
    _selectedCategory = sub.category;
    _selectedDate = sub.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(sub.dueDate);
    _isTrial = sub.isTrial;
    _splitCount = sub.splitCount;
    _billingCycle = sub.billingCycle;
    _trialEndDate = sub.trialEndDate;
    if (sub.trialPrice != null) {
      if (sub.currency == 'IDR' || sub.currency == 'JPY') {
        _trialPriceCtrl.text = NumberFormat.decimalPattern('id').format(sub.trialPrice);
      } else {
        _trialPriceCtrl.text = sub.trialPrice.toString().replaceAll(RegExp(r'\.0$'), '');
      }
    }
    _cancelLinkCtrl.text = sub.cancellationLink ?? '';
    _isAutoRenew = sub.isAutoRenew;
    _selectedStatus = sub.isFinished ? tr('Non-Aktif', 'Inactive') : tr('Aktif', 'Active');
    _customLogoPath = sub.customLogoPath;
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
            title: Text(tr('Edit Langganan', 'Edit subscription'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                          LogoWidget(name: _nameCtrl.text, category: _selectedCategory, customLogoPath: _customLogoPath, size: 56, borderRadius: 16),
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
                        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.category, color: Color(0xFF8B5CF6), size: 20)),
                        title: Text(tr('Kategori', 'Category'), style: TextStyle(color: subTextColor, fontSize: 13)),
                        subtitle: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => CategorySelectionSheet(
                                currentCategory: _selectedCategory,
                                isID: languageNotifier.value == 'ID',
                                onCategorySelected: (category) {
                                  setState(() {
                                    _selectedCategory = category;
                                    _isShortcutUsed = false;
                                  });
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _selectedCategory.isEmpty
                                  ? Text(tr('Pilih kategori', 'Choose category'), style: TextStyle(color: hintColor))
                                  : Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: CategoryUtils.getColor(_selectedCategory),
                                          child: Icon(CategoryUtils.getIcon(_selectedCategory), size: 12, color: Colors.white),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(_selectedCategory, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                Icon(Icons.arrow_drop_down, color: hintColor),
                              ],
                            ),
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
                    id: widget.sub.id, 
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
                    paymentHistory: widget.sub.paymentHistory,
                    usageCount: widget.sub.usageCount,
                    dateAdded: widget.sub.dateAdded
                  );
                  context.read<SubProvider>().updateSub(newSub);

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
                    ToastUtils.show(context, tr('Berhasil diperbarui', 'Successfully updated'));
                    Navigator.pop(context); 
                  }
                } else {
                  ToastUtils.show(context, tr('Mohon isi nama dan harga', 'Please fill name and price'), icon: Icons.error_outline, iconColor: Colors.redAccent);
                }
              },
              icon: const Icon(Icons.check_rounded, size: 24),
              label: Text(tr('Simpan Perubahan', 'Save Changes'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }
    );
  }

  Widget _buildModernCategoryIcons(List<String> categories, Color cardBg, Color textColor, bool isDark) {
    Map<String, List<Map<String, dynamic>>> appExamples = AppExamples.getAppData();
    
    List<Map<String, dynamic>> allAppsWithCategory = [];
    appExamples.forEach((cat, apps) {
      for (var app in apps) {
        allAppsWithCategory.add({
          ...app,
          'categoryName': cat,
        });
      }
    });

    final filteredApps = _searchQuery.isEmpty 
        ? (_selectedCategory.isEmpty ? allAppsWithCategory : allAppsWithCategory.where((app) => app['categoryName'] == _selectedCategory).toList())
        : allAppsWithCategory.where((app) => app['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    
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
              _selectedCategory = app['categoryName'];
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
                  LogoWidget(name: app['name'], category: app['categoryName'], size: 24, borderRadius: 6),
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
