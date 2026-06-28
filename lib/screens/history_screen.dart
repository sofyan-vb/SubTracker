import 'package:flutter/material.dart';
import '../models/subscription.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/category_filter_menu.dart';
import '../widgets/subscription_tile.dart';
import 'dashboard_screen.dart';
import '../utils/category_utils.dart';
import '../services/export_service.dart';
import '../utils/toast_utils.dart';
import '../main.dart';

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
    final provider = context.watch<SubProvider>();
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
              tr('Riwayat Tagihan', 'Billing History', 'Historial de facturación'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
            );
          }
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onSelected: (value) async {
              final subs = provider.subs;
              final userName = userNameNotifier.value;
              if (value == 'csv') {
                await ExportService.exportToCSV(subs, userName);
              } else if (value == 'pdf') {
                await ExportService.exportToPDF(subs, userName);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_rounded, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(tr('Ekspor CSV', 'Export CSV', 'Exportar CSV')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(tr('Ekspor PDF', 'Export PDF', 'Exportar PDF')),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                CategoryFilterMenu.show(context, provider, cardBg, textColor, languageNotifier.value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.categoryFilter == 'Semua Layanan' ? Icons.apps_rounded : CategoryUtils.getIcon(provider.categoryFilter), 
                      color: Colors.white, 
                      size: 16
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 14),
                    if (provider.categoryFilter != 'Semua Layanan') ...[
                      const SizedBox(width: 6),
                      Text(
                        provider.categoryFilter,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
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
                        tr('Belum ada riwayat tagihan.', 'No billing history yet.', 'Aún no hay historial de facturación.'),
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
