import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../services/email_service.dart';
import 'package:intl/intl.dart';

class SubProvider extends ChangeNotifier {
  List<Subscription> _subs = [];

  String _searchQuery = '';
  String _sortBy = 'Terdekat';
  String _categoryFilter = 'Semua Layanan';

  String get sortBy => _sortBy;
  String get categoryFilter => _categoryFilter;

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  bool _isLoaded = false;

  SubProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? '';
    final bool isManualMode = prefs.getBool('login_mode_manual') ?? false;
    final String dataKey = (!isManualMode && userName.isNotEmpty) ? 'saved_subs_$userName' : 'saved_subs';

    // Migrasi data lama jika pengguna belum memiliki data khusus namanya, tapi data global ada
    if (userName.isNotEmpty && !prefs.containsKey(dataKey) && prefs.containsKey('saved_subs')) {
      final String? globalData = prefs.getString('saved_subs');
      if (globalData != null) {
        await prefs.setString(dataKey, globalData);
      }
    }

    final String? savedData = prefs.getString(dataKey);

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      _subs = decodedData.map((item) => Subscription.fromJson(item)).toList();
    } else {
      _subs = [];
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? '';
    final bool isManualMode = prefs.getBool('login_mode_manual') ?? false;
    final String dataKey = (!isManualMode && userName.isNotEmpty) ? 'saved_subs_$userName' : 'saved_subs';
    
    await prefs.remove(dataKey);
    _subs.clear();
    notifyListeners();
  }

  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    while (!_isLoaded) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Subscription> get activeSubs => subs.where((s) => !s.isFinished).toList();
  List<Subscription> get historySubs => _subs.where((s) => s.isFinished).toList();

  List<Subscription> get subs {
    List<Subscription> filtered = _subs.where((sub) {
      bool matchesSearch = sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesCategory = _categoryFilter == 'Semua Layanan' || sub.category == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    if (_sortBy == 'Terdekat') {
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortBy == 'Termahal') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Termurah') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'A-Z') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  
  
  double get totalMonthly {
    return _subs.where((s) => !s.isFinished && !s.isPaused).fold(0, (sum, item) => sum + (item.price / item.splitCount));
  }


  double get totalYearly => totalMonthly * 12;

  Map<String, double> get categoryBreakdown {
    Map<String, double> breakdown = {};
    for (var sub in _subs.where((s) => !s.isFinished && !s.isPaused)) { 
      double effectivePrice = sub.price / sub.splitCount;
      if (breakdown.containsKey(sub.category)) {
        breakdown[sub.category] = breakdown[sub.category]! + effectivePrice;
      } else {
        breakdown[sub.category] = effectivePrice;
      }
    }
    

    var sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Map.fromEntries(sortedEntries);
  }


  void addSub(Subscription sub) async {
    _subs.add(sub);
    _saveData();
    notifyListeners();
    
    // Trigger EmailJS
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    if (userEmail != null && userEmail.isNotEmpty) {
      final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      final dateStr = DateFormat('dd MMMM yyyy').format(sub.dueDate);
      final message = 'Terdapat langganan baru untuk layanan ${sub.name} (Kategori: ${sub.category}) sebesar ${formatter.format(sub.price)} yang akan ditagihkan pada $dateStr. Mohon persiapkan dana Anda.';
      
      EmailService.sendNotificationEmail(
        toEmail: userEmail,
        subject: 'Tagihan Baru: ${sub.name}',
        message: message,
      );
    }
  }

  void removeSub(String id) {
    _subs.removeWhere((sub) => sub.id == id);
    _saveData();
    notifyListeners();
  }

  void togglePause(String id) {
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(isPaused: !_subs[index].isPaused);
      _saveData();
      notifyListeners();
    }
  }

  void deleteSub(String id) {
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(isFinished: true);
      _saveData();
      notifyListeners();
    }
  }

  void renewSub(String id) {
    final index = _subs.indexWhere((s) => s.id == id);
    if (index != -1) {
      final oldSub = _subs[index];
      // Create a history record for the paid bill
      final historySub = Subscription(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_history',
        name: oldSub.name,
        price: oldSub.price,
        dueDate: oldSub.dueDate,
        category: oldSub.category,
        isFinished: true,
        dateAdded: DateTime.now(),
      );
      _subs.add(historySub);
      
      // Update current subscription due date to next month
      DateTime nextDue;
      if (oldSub.dueDate.month == 12) {
        nextDue = DateTime(oldSub.dueDate.year + 1, 1, oldSub.dueDate.day);
      } else {
        nextDue = DateTime(oldSub.dueDate.year, oldSub.dueDate.month + 1, oldSub.dueDate.day);
      }
      
      _subs[index] = oldSub.copyWith(dueDate: nextDue);
      _saveData();
      notifyListeners();
    }
  }

  void markAsPaid(Subscription sub) {
    final index = _subs.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      _subs[index] = _subs[index].copyWith(isFinished: true);
      _saveData();
      notifyListeners();
    }
  }

  void updateSub(Subscription updated) {
    final index = _subs.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _subs[index] = updated;
      _saveData();
      notifyListeners();
    }
  }

  void addHistory(String name, double price, DateTime date) {
    // Add to history could be implemented by adding a finished subscription
    // Since we just updated the existing one to isFinished=false (renewed),
    // we can add a new finished record for the history.
    final historySub = Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      dueDate: date,
      category: 'History',
      isFinished: true,
      dateAdded: date,
    );
    _subs.add(historySub);
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String userName = prefs.getString('user_name') ?? '';
    final bool isManualMode = prefs.getBool('login_mode_manual') ?? false;
    final String dataKey = (!isManualMode && userName.isNotEmpty) ? 'saved_subs_$userName' : 'saved_subs';
    
    final String encodedData = jsonEncode(
      _subs.map((sub) => sub.toJson()).toList(),
    );
    await prefs.setString(dataKey, encodedData);
  }

  Future<void> _loadData() async {
    await loadData();
  }

  Future<String> exportBackup() async {
    try {
      final String encodedData = jsonEncode(
        _subs.map((sub) => sub.toJson()).toList(),
      );
      final Directory tempDir = Directory.systemTemp;
      final File tempFile = File('${tempDir.path}/subtracker_backup.json');
      await tempFile.writeAsString(encodedData);
      
      await Share.shareXFiles([XFile(tempFile.path)], text: 'Backup SubTracker Data');
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String contents = await file.readAsString();
        
        final List<dynamic> decodedData = jsonDecode(contents);
        _subs = decodedData.map((item) => Subscription.fromJson(item)).toList();
        await _saveData();
        notifyListeners();
        return 'success';
      }
      return 'cancelled';
    } catch (e) {
      return e.toString();
    }
  }

}
