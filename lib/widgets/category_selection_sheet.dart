import 'package:flutter/material.dart';
import '../utils/category_utils.dart';

class CategorySelectionSheet extends StatefulWidget {
  final String currentCategory;
  final Function(String) onCategorySelected;
  final bool isID;

  const CategorySelectionSheet({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
    required this.isID,
  });

  @override
  State<CategorySelectionSheet> createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends State<CategorySelectionSheet> {
  String _searchQuery = '';
  final _newCategoryCtrl = TextEditingController();

  @override
  void dispose() {
    _newCategoryCtrl.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final name = _newCategoryCtrl.text.trim();
    if (name.isNotEmpty) {
      // Create with a default color and icon if they want to add quickly
      await CategoryUtils.addCustomCategory(
        name,
        const Color(0xFF0D9488), // default teal
        Icons.category_rounded,
      );
      widget.onCategorySelected(name);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color sheetBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    Color cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    Color hintColor = isDark ? Colors.white38 : Colors.black38;

    List<String> allCategories = CategoryUtils.getAllCategories(widget.isID);
    // Sort categories alphabetically
    allCategories.sort((a, b) => a.compareTo(b));

    List<String> filteredCategories = allCategories.where((cat) => cat.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isID ? 'Pilih kategori' : 'Choose category',
                        style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isID ? 'Ketuk kategori untuk memilih, atau buat yang baru.' : 'Tap a category to assign it, or create a new one.',
                        style: TextStyle(color: hintColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textColor),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: hintColor),
                  hintText: widget.isID ? 'Cari kategori' : 'Search categories',
                  hintStyle: TextStyle(color: hintColor),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final category = filteredCategories[index];
                final color = CategoryUtils.getColor(category);
                final icon = CategoryUtils.getIcon(category);
                final isCustom = CategoryUtils.customCategories.any((c) => c.name == category);

                return GestureDetector(
                  onTap: () {
                    widget.onCategorySelected(category);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      title: Text(
                        category,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isCustom 
                          ? (widget.isID ? 'Kategori kustom' : 'Custom category')
                          : (widget.isID ? 'Kategori bawaan' : 'Built-in category'),
                        style: TextStyle(color: hintColor, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
