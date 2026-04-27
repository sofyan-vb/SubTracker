// lib/providers/subscription_provider.dart
import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubProvider extends ChangeNotifier {
  // Data dummy awal
  final List<Subscription> _subs = [
    Subscription(id: '1', name: 'Netflix', price: 186000, dueDate: DateTime.now().add(const Duration(days: 3)), category: 'Entertainment'),
    Subscription(id: '2', name: 'Spotify', price: 54900, dueDate: DateTime.now().add(const Duration(days: 12)), category: 'Music'),
  ];

  List<Subscription> get subs => _subs;

  double get totalMonthly {
    return _subs.fold(0, (sum, item) => sum + item.price);
  }

  void addSub(Subscription sub) {
    _subs.add(sub);
    notifyListeners();
  }

  void deleteSub(String id) {
    _subs.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}