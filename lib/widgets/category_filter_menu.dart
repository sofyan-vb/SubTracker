import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/subscription_provider.dart';
import '../utils/category_utils.dart';

class CategoryFilterMenu {
  static void show(BuildContext context, SubProvider provider, Color cardBg, Color textColor, String language) {
    List<String> currentCategories = language == 'ID' ? CategoryUtils.categoriesID : CategoryUtils.categoriesEN;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                  decoration: BoxDecoration(
                    color: cardBg.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Text(language == 'ID' ? 'Pilih Kategori' : 'Select Category', style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ),
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                      Flexible(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 8),
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildGlassTile(context, provider, 'Semua Layanan', Icons.apps_rounded, textColor, language),
                            ...currentCategories.map((cat) {
                              return _buildGlassTile(context, provider, cat, CategoryUtils.getIcon(cat), textColor, language);
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  static Widget _buildGlassTile(BuildContext context, SubProvider provider, String catName, IconData icon, Color textColor, String language) {
    bool isSelected = provider.categoryFilter == catName;
    Color iconColor = catName == 'Semua Layanan' ? (isSelected ? const Color(0xFF0D9488) : textColor.withValues(alpha: 0.7)) : CategoryUtils.getColor(catName);
    String displayTitle = catName == 'Semua Layanan' ? (language == 'ID' ? 'Semua Layanan' : 'All Services') : catName;
    
    return InkWell(
      onTap: () {
        provider.setCategoryFilter(catName);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected ? const Color(0xFF0D9488).withValues(alpha: 0.15) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(displayTitle, style: TextStyle(color: isSelected ? textColor : textColor.withValues(alpha: 0.8), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF0D9488), size: 18),
          ],
        ),
      ),
    );
  }
}
