import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'dashboard_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, lang, child) {
            return Text(
              tr('Bahasa Aplikasi', 'App Language'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
            );
          }
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text('English', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                value: 'EN',
                groupValue: languageNotifier.value, 
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) async {
                  languageNotifier.value = val!; 
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_lang', val); 
                  setState((){});
                },
              ),
              Divider(color: isDark ? Colors.white12 : Colors.grey.shade200, height: 1),
              RadioListTile<String>(
                title: Text('Bahasa Indonesia', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                value: 'ID',
                groupValue: languageNotifier.value, 
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) async {
                  languageNotifier.value = val!; 
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_lang', val); 
                  setState((){});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
