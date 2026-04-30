// lib/providers/subscription_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class SubProvider extends ChangeNotifier {
  List<Subscription> _subs = [];
  List<Subscription> get subs => _subs;

  // Begitu aplikasi dibuka, langsung panggil fungsi muat data dari memori HP
  SubProvider() {
    _loadData(); 
  }

  double get totalMonthly {
    return _subs.fold(0, (sum, item) => sum + item.price);
  }

  void addSub(Subscription sub) {
    _subs.add(sub);
    _saveData(); // Simpan ke HP setiap kali ada langganan baru ditambahkan
    notifyListeners();
  }

  void removeSub(String id) {
    _subs.removeWhere((sub) => sub.id == id);
    _saveData(); // Simpan ke HP setiap kali ada langganan dihapus
    notifyListeners();
  }

  // --- LOGIKA PENYIMPANAN PERMANEN ---
  
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    // Ubah daftar langganan jadi teks panjang (JSON)
    final String encodedData = jsonEncode(
      _subs.map((sub) => sub.toJson()).toList(),
    );
    // Simpan ke brankas HP dengan kunci 'saved_subs'
    await prefs.setString('saved_subs', encodedData);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    // Cek apakah sebelumnya sudah ada data yang tersimpan
    final String? savedData = prefs.getString('saved_subs');

    if (savedData != null) {
      // Jika ada, kembalikan teks tersebut menjadi daftar catatan di layar
      final List<dynamic> decodedData = jsonDecode(savedData);
      _subs = decodedData.map((item) => Subscription.fromJson(item)).toList();
      notifyListeners();
    }
  }
}