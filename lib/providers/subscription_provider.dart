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
    final String? savedData = prefs.getString('saved_subs');

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      _subs = decodedData.map((item) => Subscription.fromJson(item)).toList();
    }
    _isLoaded = true;
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
    return _subs.where((s) => !s.isFinished).fold(0, (sum, item) => sum + item.price);
  }


  double get totalYearly => totalMonthly * 12;

  Map<String, double> get categoryBreakdown {
    Map<String, double> breakdown = {};
    for (var sub in _subs.where((s) => !s.isFinished)) { 
      if (breakdown.containsKey(sub.category)) {
        breakdown[sub.category] = breakdown[sub.category]! + sub.price;
      } else {
        breakdown[sub.category] = sub.price;
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

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _subs.map((sub) => sub.toJson()).toList(),
    );
    await prefs.setString('saved_subs', encodedData);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_subs');

    if (savedData != null) {
      final List<dynamic> decodedData = jsonDecode(savedData);
      _subs = decodedData.map((item) => Subscription.fromJson(item)).toList();
      notifyListeners();
    }
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
