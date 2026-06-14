import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sub_tracker/utils/category_utils.dart';
import '../utils/toast_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart'; 
import 'dashboard_screen.dart';
import '../utils/currency_utils.dart';

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Hapus Catatan?', 'Delete Record?'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(tr('Apakah kamu yakin? Catatan yang dihapus tidak bisa dikembalikan.', 'Are you sure? Deleted records cannot be recovered.'), style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: const TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              context.read<SubProvider>().removeSub(currentSub.id);
              Navigator.pop(ctx); Navigator.pop(context); 
              ToastUtils.show(context, tr('Catatan berhasil dihapus', 'Record deleted successfully'));
            }, 
            child: Text(tr('Hapus', 'Delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _showCheckOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151B2B), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.update, color: Color(0xFF0D9488)), title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _showRenewInput(); }),
          ListTile(leading: const Icon(Icons.task_alt, color: Colors.white), title: Text(tr('Tandai Sudah Selesai', 'Mark as Completed'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _markAsFinished(); }),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, backgroundColor: const Color(0xFF151B2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Berapa bulan kamu ingin memperpanjang?', 'How many months to renew?'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _monthCtrl, autofocus: true, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: '1', suffixText: tr('Bulan', 'Month(s)'), suffixStyle: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold, fontSize: 16), filled: true, fillColor: const Color(0xFF0B101E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: const TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              final int? m = int.tryParse(_monthCtrl.text);
              if (m != null && m > 0) { Navigator.pop(ctx); _processRenewal(m); } 
              else { ToastUtils.show(context, tr('Masukkan angka valid', 'Enter valid number'), icon: Icons.error_outline, iconColor: Colors.redAccent); }
            }, 
            child: Text(tr('Simpan', 'Save'), style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.bold))
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
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm'); 

    return Scaffold(
      backgroundColor: const Color(0xFF0B101E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101E), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(tr('Detail Langganan', 'Subscription Detail'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF0D9488), size: 28), onPressed: _showCheckOptions),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 28), onPressed: _deleteSub),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: const Color(0xFF0D9488).withOpacity(0.1), shape: BoxShape.circle), child: Icon(CategoryUtils.getIcon(currentSub.category), size: 60, color: const Color(0xFF0D9488))),
              const SizedBox(height: 24),
              Text(currentSub.name, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(currencyFormat.format(currentSub.price), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF151B2B), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text(tr('Status Pembayaran:', 'Payment Status:'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(_getCountdownText(currentSub.dueDate), style: TextStyle(color: currentSub.isFinished ? Colors.white : (currentSub.dueDate.isBefore(DateTime.now()) ? Colors.redAccent : Colors.white), fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white12, height: 30),
                    Text(tr('Jadwal Berikutnya:', 'Next Schedule:'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(dateFormat.format(currentSub.dueDate), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}