import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCategory {
  final String name;
  final int colorValue;
  final int iconCodePoint;

  CustomCategory({required this.name, required this.colorValue, required this.iconCodePoint});

  Map<String, dynamic> toJson() => {
    'name': name,
    'colorValue': colorValue,
    'iconCodePoint': iconCodePoint,
  };

  factory CustomCategory.fromJson(Map<String, dynamic> json) => CustomCategory(
    name: json['name'],
    colorValue: json['colorValue'],
    iconCodePoint: json['iconCodePoint'],
  );
}

class CategoryUtils {
  static const List<String> categoriesID = [
    'Tools AI', 'Otomotif', 'Tagihan & utilitas', 'Karir', 'Platform cloud', 'Cloud storage', 
    'Komunikasi', 'Langganan kreator', 'Dating', 'Desain', 'Tools developer', 'Edukasi', 
    'Hiburan', 'Keuangan', 'Kebugaran', 'Gym & Klub Olahraga', 'Makanan & Pengiriman', 'Game', 
    'Kebutuhan sehari-hari', 'Kesehatan', 'Kecantikan & Perawatan', 'Asuransi', 'Properti & Sewa', 
    'Donasi & Amal', 'Hosting & Domain', 'Meditasi', 'Musik', 'Berita & Membaca', 
    'Password manager', 'Hewan peliharaan', 'Podcast', 'Produktivitas', 'Membership retail', 'Keamanan & VPN', 
    'Belanja', 'Langganan', 'Travel', 'Transportasi Publik & E-Toll', 'Sosial Media Premium', 'Lainnya'
  ];

  static const List<String> categoriesEN = [
    'AI tools', 'Automotive', 'Bills & utilities', 'Career', 'Cloud platforms', 'Cloud storage', 
    'Communication', 'Creator memberships', 'Dating', 'Design', 'Developer tools', 'Education', 
    'Entertainment', 'Finance', 'Fitness', 'Gym & Sports Clubs', 'Food & Delivery', 'Gaming', 
    'Groceries', 'Health', 'Beauty & Grooming', 'Insurance', 'Housing & Rent', 
    'Charity & Donations', 'Hosting & Domains', 'Meditation', 'Music', 'News & Reading', 
    'Password manager', 'Pets', 'Podcasts', 'Productivity', 'Retail memberships', 'Security & VPN', 
    'Shopping', 'Subscriptions', 'Travel', 'Public Transport & E-Toll', 'Social Media Premium', 'Others'
  ];

  static List<CustomCategory> customCategories = [];

  static Future<void> loadCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('custom_categories');
      if (data != null) {
        customCategories = data.map((e) => CustomCategory.fromJson(jsonDecode(e))).toList();
      }
    } catch (_) {}
  }

  static Future<void> addCustomCategory(String name, Color color, IconData icon) async {
    final cat = CustomCategory(name: name, colorValue: color.value, iconCodePoint: icon.codePoint);
    customCategories.add(cat);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_categories', customCategories.map((e) => jsonEncode(e.toJson())).toList());
  }

  static List<String> getAllCategories(bool isID) {
    List<String> base = isID ? List.from(categoriesID) : List.from(categoriesEN);
    for (var cat in customCategories) {
      if (!base.contains(cat.name)) base.insert(base.length - 1, cat.name);
    }
    return base;
  }

  static Color getColor(String category) {
    for (var cat in customCategories) {
      if (cat.name == category) return Color(cat.colorValue);
    }

    switch (category) {
      case 'Tools AI': case 'AI tools': return const Color(0xFF0D9488);
      case 'Otomotif': case 'Automotive': return const Color(0xFFEF4444);
      case 'Tagihan & utilitas': case 'Bills & utilities': return const Color(0xFF8B5CF6);
      case 'Karir': case 'Career': return const Color(0xFF10B981);
      case 'Platform cloud': case 'Cloud platforms': return const Color(0xFF3B82F6);
      case 'Cloud storage': return const Color(0xFF06B6D4);
      case 'Komunikasi': case 'Communication': return const Color(0xFF2563EB);
      case 'Langganan kreator': case 'Creator memberships': return const Color(0xFFA855F7);
      case 'Dating': return const Color(0xFFF43F5E);
      case 'Desain': case 'Design': return const Color(0xFFEC4899);
      case 'Tools developer': case 'Developer tools': return const Color(0xFF64748B);
      case 'Edukasi': case 'Education': return const Color(0xFF8B5CF6);
      case 'Hiburan': case 'Entertainment': return const Color(0xFF8B5CF6);
      case 'Keuangan': case 'Finance': return const Color(0xFF10B981);
      case 'Kebugaran': case 'Fitness': return const Color(0xFF10B981);
      case 'Gym & Klub Olahraga': case 'Gym & Sports Clubs': return const Color(0xFF10B981);
      case 'Makanan & Pengiriman': case 'Food & Delivery': return const Color(0xFFEF4444);
      case 'Game': case 'Gaming': return const Color(0xFF8B5CF6);
      case 'Kebutuhan sehari-hari': case 'Groceries': return const Color(0xFFEF4444);
      case 'Kesehatan': case 'Health': return const Color(0xFF10B981);
      case 'Kecantikan & Perawatan': case 'Beauty & Grooming': return const Color(0xFFEC4899);
      case 'Asuransi': case 'Insurance': return const Color(0xFF3B82F6);
      case 'Properti & Sewa': case 'Housing & Rent': return const Color(0xFFF59E0B);
      case 'Donasi & Amal': case 'Charity & Donations': return const Color(0xFFF43F5E);
      case 'Hosting & Domain': case 'Hosting & Domains': return const Color(0xFF3B82F6);
      case 'Meditasi': case 'Meditation': return const Color(0xFF0D9488);
      case 'Musik': case 'Music': return const Color(0xFF10B981);
      case 'Berita & Membaca': case 'News & Reading': return const Color(0xFF64748B);
      case 'Password manager': return const Color(0xFF475569);
      case 'Hewan peliharaan': case 'Pets': return const Color(0xFFF59E0B);
      case 'Podcast': case 'Podcasts': return const Color(0xFF10B981);
      case 'Produktivitas': case 'Productivity': return const Color(0xFF8B5CF6);
      case 'Membership retail': case 'Retail memberships': return const Color(0xFFF97316);
      case 'Keamanan & VPN': case 'Security & VPN': return const Color(0xFF2563EB);
      case 'Belanja': case 'Shopping': return const Color(0xFFF97316);
      case 'Langganan': case 'Subscriptions': return const Color(0xFF4F46E5);
      case 'Travel': return const Color(0xFF0D9488);
      case 'Transportasi Publik & E-Toll': case 'Public Transport & E-Toll': return const Color(0xFF3B82F6);
      case 'Sosial Media Premium': case 'Social Media Premium': return const Color(0xFFEC4899);
      case 'Lainnya': case 'Others': return const Color(0xFF64748B);
      default: return const Color(0xFF0D9488);
    }
  }

  static IconData getIcon(String category) {
    for (var cat in customCategories) {
      if (cat.name == category) return IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');
    }

    switch (category) {
      case 'Tools AI': case 'AI tools': return Icons.smart_toy_rounded;
      case 'Otomotif': case 'Automotive': return Icons.directions_car_rounded;
      case 'Tagihan & utilitas': case 'Bills & utilities': return Icons.receipt_long_rounded;
      case 'Karir': case 'Career': return Icons.work_rounded;
      case 'Platform cloud': case 'Cloud platforms': return Icons.cloud_rounded;
      case 'Cloud storage': return Icons.cloud_queue_rounded;
      case 'Komunikasi': case 'Communication': return Icons.people_rounded;
      case 'Langganan kreator': case 'Creator memberships': return Icons.auto_awesome_rounded;
      case 'Dating': return Icons.favorite_rounded;
      case 'Desain': case 'Design': return Icons.brush_rounded;
      case 'Tools developer': case 'Developer tools': return Icons.code_rounded;
      case 'Edukasi': case 'Education': return Icons.school_rounded;
      case 'Hiburan': case 'Entertainment': return Icons.movie_creation_rounded;
      case 'Keuangan': case 'Finance': return Icons.account_balance_wallet_rounded;
      case 'Kebugaran': case 'Fitness': return Icons.fitness_center_rounded;
      case 'Gym & Klub Olahraga': case 'Gym & Sports Clubs': return Icons.sports_gymnastics_rounded;
      case 'Makanan & Pengiriman': case 'Food & Delivery': return Icons.restaurant_rounded;
      case 'Game': case 'Gaming': return Icons.videogame_asset_rounded;
      case 'Kebutuhan sehari-hari': case 'Groceries': return Icons.local_grocery_store_rounded;
      case 'Kesehatan': case 'Health': return Icons.health_and_safety_rounded;
      case 'Kecantikan & Perawatan': case 'Beauty & Grooming': return Icons.spa_rounded;
      case 'Asuransi': case 'Insurance': return Icons.shield_rounded;
      case 'Properti & Sewa': case 'Housing & Rent': return Icons.house_rounded;
      case 'Donasi & Amal': case 'Charity & Donations': return Icons.volunteer_activism_rounded;
      case 'Hosting & Domain': case 'Hosting & Domains': return Icons.dns_rounded;
      case 'Meditasi': case 'Meditation': return Icons.self_improvement_rounded;
      case 'Musik': case 'Music': return Icons.music_note_rounded;
      case 'Berita & Membaca': case 'News & Reading': return Icons.menu_book_rounded;
      case 'Password manager': return Icons.lock_rounded;
      case 'Hewan peliharaan': case 'Pets': return Icons.pets_rounded;
      case 'Podcast': case 'Podcasts': return Icons.podcasts_rounded;
      case 'Produktivitas': case 'Productivity': return Icons.adjust_rounded;
      case 'Membership retail': case 'Retail memberships': return Icons.shopping_bag_rounded;
      case 'Keamanan & VPN': case 'Security & VPN': return Icons.security_rounded;
      case 'Belanja': case 'Shopping': return Icons.shopping_cart_rounded;
      case 'Langganan': case 'Subscriptions': return Icons.subscriptions_rounded;
      case 'Travel': return Icons.flight_rounded;
      case 'Transportasi Publik & E-Toll': case 'Public Transport & E-Toll': return Icons.directions_transit_rounded;
      case 'Sosial Media Premium': case 'Social Media Premium': return Icons.verified_rounded;
      case 'Lainnya': case 'Others': return Icons.dashboard_customize_rounded;
      default: return Icons.category_rounded;
    }
  }
}
