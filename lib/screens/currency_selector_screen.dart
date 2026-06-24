import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/currency_utils.dart';
import 'dashboard_screen.dart' show currencyNotifier, tr;
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';

class CurrencySelectorScreen extends StatefulWidget {
  const CurrencySelectorScreen({super.key});

  @override
  State<CurrencySelectorScreen> createState() => _CurrencySelectorScreenState();
}

class _CurrencySelectorScreenState extends State<CurrencySelectorScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Pilih Mata Uang', 'Select Currency'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: currencyNotifier,
        builder: (context, currentCurrency, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: CurrencyUtils.data.length,
            itemBuilder: (context, index) {
              final code = CurrencyUtils.data.keys.elementAt(index);
              final data = CurrencyUtils.data[code]!;
              final isSelected = currentCurrency == code;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.transparent),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Text(data['flag'], style: const TextStyle(fontSize: 24)),
                  title: Text('${data['name']} ($code)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB)) : null,
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('app_currency', code);
                    currencyNotifier.value = code;
                    context.read<SubProvider>().setTargetCurrency(code);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              );
            },
          );
        }
      ),
    );
  }
}
