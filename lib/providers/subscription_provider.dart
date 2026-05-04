import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';

class SubProvider extends ChangeNotifier {
  List<Subscription> _subs = [];

  String _searchQuery = '';
  String _sortBy = 'Terdekat';

  String get sortBy => _sortBy;

  SubProvider() {
    _loadData();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Subscription> get subs {
    List<Subscription> filtered = _subs.where((sub) {
      return sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
    return _subs.fold(0, (sum, item) => sum + item.price);
  }


  double get totalYearly => totalMonthly * 12;

  Map<String, double> get categoryBreakdown {
    Map<String, double> breakdown = {};
    for (var sub in _subs) { 
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


  void addSub(Subscription sub) {
    _subs.add(sub);
    _saveData();
    notifyListeners();
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
}