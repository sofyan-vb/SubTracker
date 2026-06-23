import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subtrack_iq/utils/category_utils.dart';
import '../utils/toast_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart'; 
import 'dashboard_screen.dart';
import '../utils/currency_utils.dart';
import 'edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final Subscription sub;
  const DetailScreen({super.key, required this.sub});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer? _timer;
  late Subscription currentSub;
  final TextEditingController _monthCtrl = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    currentSub = widget.sub; 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _monthCtrl.dispose(); 
    _timer?.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime dueDate) {
    if (currentSub.isFinished) return tr('PEMBAYARAN SUDAH SELESAI', 'PAYMENT COMPLETED');
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return tr('SEKARANG WAKTUNYA BAYAR!', 'PAYMENT DUE NOW!');
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return tr('Tinggal $days Hari $hours Jam', '$days Days $hours Hours Left');
    if (hours > 0) return tr('Tinggal $hours Jam $minutes Menit', '$hours Hours $minutes Mins Left');
    return tr('Tinggal $minutes Menit $seconds Detik', '$minutes Mins $seconds Secs Left');
  }

  void _deleteSub() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Hapus Catatan?', 'Delete Record?'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Text(tr('Apakah kamu yakin? Catatan yang dihapus tidak bisa dikembalikan.', 'Are you sure? Deleted records cannot be recovered.'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)))),
          TextButton(
            onPressed: () {
              context.read<SubProvider>().deleteSub(currentSub.id);
              ToastUtils.show(context, tr('Catatan berhasil dihapus', 'Record deleted successfully'));
              Navigator.pop(ctx); 
              Navigator.pop(context); 
            }, 
            child: Text(tr('Hapus', 'Delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _showCheckOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.update, color: Color(0xFF2563EB)), title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _showRenewInput(); }),
          ListTile(leading: Icon(Icons.task_alt, color: isDark ? Colors.white : const Color(0xFF1E293B)), title: Text(tr('Tandai Sudah Selesai', 'Mark as Completed'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _markAsFinished(); }),
        ],
      ),
    );
  }

  void _markAsFinished() {
    final provider = context.read<SubProvider>();
    final updatedSub = Subscription(id: currentSub.id, name: currentSub.name, price: currentSub.price, dueDate: currentSub.dueDate, category: currentSub.category, isFinished: true);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Catatan ditandai selesai', 'Record marked as completed'));
  }

  void _showRenewInput() {
    _monthCtrl.clear(); 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Berapa bulan kamu ingin memperpanjang?', 'How many months to renew?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _monthCtrl, autofocus: true, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: '1', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26), suffixText: tr('Bulan', 'Month(s)'), suffixStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14), filled: true, fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
          TextButton(
            onPressed: () {
              final int? m = int.tryParse(_monthCtrl.text);
              if (m != null && m > 0) { Navigator.pop(ctx); _processRenewal(m); } 
              else { ToastUtils.show(context, tr('Masukkan angka valid', 'Enter valid number'), icon: Icons.error_outline, iconColor: Colors.redAccent); }
            }, 
            child: Text(tr('Simpan', 'Save'), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _processRenewal(int monthsToAdd) {
    final provider = context.read<SubProvider>();
    final newDate = DateTime(currentSub.dueDate.year, currentSub.dueDate.month + monthsToAdd, currentSub.dueDate.day, currentSub.dueDate.hour, currentSub.dueDate.minute);
    final updatedSub = Subscription(id: currentSub.id, name: currentSub.name, price: currentSub.price, dueDate: newDate, category: currentSub.category, isFinished: false);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Diperpanjang $monthsToAdd Bulan', 'Renewed for $monthsToAdd Month(s)'));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    final dateFormat = DateFormat('MMMM dd, yyyy'); 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final innerCardBg = isDark ? const Color(0xFF0F172A) : Colors.grey[50];
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final appBarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Detail Langganan', 'Subscription Detail'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  padding: const EdgeInsets.all(24), 
                  decoration: BoxDecoration(
                    color: innerCardBg, 
                    borderRadius: BorderRadius.circular(20),
                  ), 
                  child: Icon(CategoryUtils.getIcon(currentSub.category), size: 48, color: const Color(0xFF2563EB))
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(currentSub.name, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(sub: currentSub))).then((_) {
                          final provider = context.read<SubProvider>();
                          final updated = provider.subs.firstWhere((s) => s.id == currentSub.id, orElse: () => currentSub);
                          if (mounted) setState(() => currentSub = updated);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentSub.isTrial) ...[
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('TRIAL', style: TextStyle(color: Colors.pinkAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                    ],
                    if (currentSub.splitCount > 1) ...[
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text('Patungan ${currentSub.splitCount} Org', style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 8),
                    ],
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: currentSub.isPaused ? Colors.orangeAccent : const Color(0xFF2563EB), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(currentSub.isPaused ? 'DI-PAUSE' : tr('LANGGANAN AKTIF', 'ACTIVE SUBSCRIPTION'), style: TextStyle(color: currentSub.isPaused ? Colors.orangeAccent : const Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Current Plan Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: innerCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('PAKET SAAT INI', 'CURRENT PLAN'), style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(currentSub.category, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('${currencyFormat.format(currentSub.price / currentSub.splitCount)}/mo', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 16, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, color: subTextColor, size: 16),
                          const SizedBox(width: 8),
                          Text(dateFormat.format(currentSub.dueDate), style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Payment History
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(tr('Riwayat Pembayaran', 'Payment History'), style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: innerCardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      _buildHistoryRow(currentSub.name, dateFormat.format(currentSub.dueDate.subtract(const Duration(days: 30))), currencyFormat.format(currentSub.price), textColor, subTextColor),
                      const Divider(height: 1),
                      _buildHistoryRow(currentSub.name, dateFormat.format(currentSub.dueDate.subtract(const Duration(days: 60))), currencyFormat.format(currentSub.price), textColor, subTextColor),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB), 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
                      elevation: 0
                    ),
                    onPressed: _showCheckOptions,
                    child: Text(tr('Perpanjang Langganan', 'Renew Plan'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _deleteSub,
                  child: Text(tr('Hapus Langganan', 'Cancel Membership'), style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryRow(String title, String date, String price, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(color: subTextColor, fontSize: 10)),
              ],
            ),
          ),
          Text(price, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}