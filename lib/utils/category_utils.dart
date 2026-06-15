import 'package:flutter/material.dart';

class CategoryUtils {
  static const List<String> categoriesID = ['Hiburan', 'Musik', 'Software', 'Utilitas', 'Belanja', 'Game', 'Edukasi', 'Cloud Storage', 'Lainnya'];
  static const List<String> categoriesEN = ['Entertainment', 'Music', 'Software', 'Utilities', 'Shopping', 'Game', 'Education', 'Cloud Storage', 'Others'];

  static Color getColor(String category) {
    switch (category) {
      case 'Hiburan':
      case 'Entertainment':
        return const Color(0xFF8B5CF6); // Purple
      case 'Musik':
      case 'Music':
        return const Color(0xFFEC4899); // Pink
      case 'Software':
        return const Color(0xFF3B82F6); // Blue
      case 'Utilitas':
      case 'Utilities':
        return const Color(0xFFF97316); // Orange
      case 'Belanja':
      case 'Shopping':
        return const Color(0xFFEAB308); // Yellow
      case 'Game':
        return const Color(0xFFEF4444); // Red
      case 'Edukasi':
      case 'Education':
        return const Color(0xFF84CC16); // Lime Green
      case 'Cloud Storage':
        return const Color(0xFF06B6D4); // Cyan
      case 'Lainnya':
      case 'Others':
        return const Color(0xFF64748B); // Slate Grey
      default:
        return const Color(0xFF0D9488); // Teal Default
    }
  }

  static IconData getIcon(String category) {
    switch (category) {
      case 'Hiburan':
      case 'Entertainment':
        return Icons.movie_creation_rounded;
      case 'Musik':
      case 'Music':
        return Icons.headphones_rounded;
      case 'Software':
        return Icons.computer_rounded;
      case 'Utilitas':
      case 'Utilities':
        return Icons.bolt_rounded;
      case 'Belanja':
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Game':
        return Icons.videogame_asset_rounded;
      case 'Edukasi':
      case 'Education':
        return Icons.school_rounded;
      case 'Cloud Storage':
        return Icons.cloud_rounded;
      case 'Lainnya':
      case 'Others':
        return Icons.dashboard_customize_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
