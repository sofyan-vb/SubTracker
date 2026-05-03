// lib/screens/detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart'; 

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
    // TAMBAHAN: Ubah teks jika sudah ditandai selesai
    if (currentSub.isFinished) return 'PEMBAYARAN SUDAH SELESAI';

    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return 'SEKARANG WAKTUNYA BAYAR!';
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return 'Tinggal $days Hari $hours Jam';
    if (hours > 0) return 'Tinggal $hours Jam $minutes Menit';
    return 'Tinggal $minutes Menit $seconds Detik';
  }

  void _deleteSub() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Catatan?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Apakah kamu yakin? Catatan yang dihapus tidak bisa dikembalikan.', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Batal', style: TextStyle(color: Colors.white))
          ),
          TextButton(
            onPressed: () {
              context.read<SubProvider>().removeSub(currentSub.id);
              Navigator.pop(ctx); 
              Navigator.pop(context); 
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan berhasil dihapus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                )
              );
            }, 
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  // TAMBAHAN: Menu pilihan saat centang diklik
  void _showCheckOptions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF121214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Opsi Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.update, color: Color(0xFFD4FF00)),
              title: const Text('Perpanjang Langganan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _showRenewInput();
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.cyanAccent),
              title: const Text('Tandai Sudah Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _markAsFinished();
              },
            ),
          ],
        ),
      )
    );
  }

  // TAMBAHAN: Fungsi untuk mengubah status selesai
  void _markAsFinished() {
    final provider = context.read<SubProvider>();
    final updatedSub = Subscription(
      id: currentSub.id,
      name: currentSub.name,
      price: currentSub.price,
      dueDate: currentSub.dueDate,
      category: currentSub.category,
      isFinished: true, // Ubah status jadi selesai
    );

    provider.removeSub(currentSub.id);
    provider.addSub(updatedSub);

    setState(() {
      currentSub = updatedSub; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan ditandai selesai!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.cyanAccent,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  void _showRenewInput() {
    _monthCtrl.clear(); 
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, 
        backgroundColor: const Color(0xFF121214),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Perpanjang Langganan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Berapa bulan kamu ingin memperpanjang?', style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _monthCtrl,
              autofocus: true, 
              keyboardType: TextInputType.number, 
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Contoh: 1',
                hintStyle: const TextStyle(color: Colors.white30),
                suffixText: 'Bulan',
                suffixStyle: const TextStyle(color: Color(0xFFD4FF00), fontWeight: FontWeight.bold, fontSize: 16),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Batal', style: TextStyle(color: Colors.white54))
          ),
          TextButton(
            onPressed: () {
              final int? monthsToAdd = int.tryParse(_monthCtrl.text);
              
              if (monthsToAdd != null && monthsToAdd > 0) {
                Navigator.pop(ctx); 
                _processRenewal(monthsToAdd); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Masukkan angka yang valid!'), backgroundColor: Colors.redAccent)
                );
              }
            }, 
            child: const Text('Simpan', style: TextStyle(color: Color(0xFFD4FF00), fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _processRenewal(int monthsToAdd) {
    final provider = context.read<SubProvider>();
    
    final newDate = DateTime(
      currentSub.dueDate.year, 
      currentSub.dueDate.month + monthsToAdd, 
      currentSub.dueDate.day, 
      currentSub.dueDate.hour, 
      currentSub.dueDate.minute
    );
    
    final updatedSub = Subscription(
      id: currentSub.id,
      name: currentSub.name,
      price: currentSub.price,
      dueDate: newDate,
      category: currentSub.category,
      isFinished: false, // Reset status selesai saat diperpanjang
    );

    provider.removeSub(currentSub.id);
    provider.addSub(updatedSub);

    setState(() {
      currentSub = updatedSub; 
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sip! Langganan diperpanjang $monthsToAdd Bulan.', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFFD4FF00),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm'); 

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Langganan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Opsi Catatan',
            icon: const Icon(Icons.check_circle, color: Color(0xFFD4FF00), size: 28), 
            onPressed: _showCheckOptions, // TAMBAHAN: Mengubah fungsi tombol centang
          ),
          IconButton(
            tooltip: 'Hapus Catatan',
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 30), 
            onPressed: _deleteSub,
          ),
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
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: const Color(0xFFD4FF00).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.edit_document, size: 60, color: Color(0xFFD4FF00)),
              ),
              const SizedBox(height: 24),
              Text(currentSub.name, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(currencyFormat.format(currentSub.price), style: const TextStyle(color: Color(0xFFD4FF00), fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text('Status Pembayaran:', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      _getCountdownText(currentSub.dueDate),
                      style: TextStyle(
                        // TAMBAHAN: Warna menyesuaikan status
                        color: currentSub.isFinished 
                            ? Colors.cyanAccent 
                            : (currentSub.dueDate.isBefore(DateTime.now()) ? Colors.redAccent : Colors.white), 
                        fontSize: 22, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 30),
                    const Text('Jadwal Berikutnya:', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      dateFormat.format(currentSub.dueDate),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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