import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

class ExportService {
  static Future<void> exportToCSV(List<Subscription> subs, String userName) async {
    List<List<dynamic>> rows = [];
    
    rows.add(["Laporan Pengeluaran SubTracker", "Pengguna: $userName"]);
    rows.add([]);
    
    // Headers
    rows.add(["ID", "Nama Layanan", "Harga", "Tanggal Jatuh Tempo", "Kategori", "Status", "Patungan (Orang)"]);
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    for (var sub in subs) {
      rows.add([
        sub.id,
        sub.name,
        formatter.format(sub.price),
        DateFormat('dd MMM yyyy').format(sub.dueDate),
        sub.category,
        sub.isPaused ? 'Di-pause' : (sub.isFinished ? 'Selesai' : 'Aktif'),
        sub.splitCount,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    final directory = await getTemporaryDirectory();
    final safeName = userName.isEmpty ? 'SubTracker' : userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final path = "${directory.path}/Laporan_${safeName}_${DateTime.now().millisecondsSinceEpoch}.csv";
    final File file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Laporan Pengeluaran $userName (CSV)');
  }

  static Future<void> exportToPDF(List<Subscription> subs, String userName) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Laporan Pengeluaran SubTracker", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Pengguna: $userName", style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["Nama Layanan", "Harga", "Kategori", "Jatuh Tempo"],
                data: subs.map((sub) {
                  return [
                    sub.name,
                    formatter.format(sub.price),
                    sub.category,
                    DateFormat('dd MMM yyyy').format(sub.dueDate),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final safeName = userName.isEmpty ? 'SubTracker' : userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final path = "${directory.path}/Laporan_${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'Laporan Pengeluaran $userName (PDF)');
  }
}
