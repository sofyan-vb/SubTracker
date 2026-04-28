// lib/providers/subscription_provider.dart
import 'package:flutter/material.dart';
import '../models/subscription.dart';

class SubProvider extends ChangeNotifier {
  final List<Subscription> _subs = [
    Subscription(id: '1', name: 'Netflix Premium', price: 186000, dueDate: DateTime.now().add(const Duration(days: 2)), category: 'Entertainment'),
    Subscription(id: '2', name: 'Spotify Duo', price: 64900, dueDate: DateTime.now().add(const Duration(days: 10)), category: 'Music'),
    Subscription(id: '3', name: 'Adobe Creative Cloud', price: 450000, dueDate: DateTime.now().add(const Duration(days: 15)), category: 'Software'),
    Subscription(id: '4', name: 'YouTube Premium', price: 59000, dueDate: DateTime.now().add(const Duration(days: 22)), category: 'Entertainment'),
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