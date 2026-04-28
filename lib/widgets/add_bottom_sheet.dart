import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class AddSubBottomSheet extends StatefulWidget {
  const AddSubBottomSheet({super.key});

  @override
  State<AddSubBottomSheet> createState() => _AddSubBottomSheetState();
}

class _AddSubBottomSheetState extends State<AddSubBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(28, 28, 28, bottomInset + 28),
      decoration: BoxDecoration(
        color: const Color(0xFF121214), // Solid Background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 32),
          const Text('Langganan Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          
          // TextField Flat Design
          Container(
            decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Nama Layanan',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Harga per Bulan (Rp)',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Tombol Tanpa Bayangan
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4FF00), // Solid Neon Lime
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0, // 100% Hilangkan bayangan
                shadowColor: Colors.transparent, // Pastikan tidak ada bayangan
              ),
              onPressed: () {
                if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                  final newSub = Subscription(
                    id: DateTime.now().toString(),
                    name: _nameCtrl.text,
                    price: double.parse(_priceCtrl.text),
                    dueDate: DateTime.now().add(const Duration(days: 30)),
                    category: 'Lainnya',
                  );
                  context.read<SubProvider>().addSub(newSub);
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambahkan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}