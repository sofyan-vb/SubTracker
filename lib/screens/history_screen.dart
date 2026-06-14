import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import 'dashboard_screen.dart'; // untuk mengambil languageNotifier dan fungsi tr()

class HistoryScreen extends StatelessWidget {
  final Color bgColor;
  final Color textColor;
  final Color cardBg;

  const HistoryScreen({
    super.key,
    required this.bgColor,
    required this.textColor,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder<String>(
          valueListenable: languageNotifier,
          builder: (context, lang, child) {
            return Text(
              tr('Riwayat Tagihan', 'Billing History'),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            );
          }
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SubProvider>(
        builder: (context, provider, child) {
          final historySubs = provider.historySubs;

          if (historySubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off_rounded, size: 80, color: textColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: languageNotifier,
                    builder: (context, lang, child) {
                      return Text(
                        tr('Belum ada riwayat tagihan.', 'No billing history yet.'),
                        style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.bold),
                      );
                    }
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: historySubs.length,
            itemBuilder: (context, index) {
              return SubTile(sub: historySubs[index]);
            },
          );
        },
      ),
    );
  }
}
