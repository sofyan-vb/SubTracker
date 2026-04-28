// lib/screens/add_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  String _selectedCategory = 'Hiburan';
  DateTime _selectedDate = DateTime.now();
  bool _isAutoRenew = true;
  String _selectedStatus = 'Aktif';
  int _reminderDays = 1;

  final List<String> _categories = ['Hiburan', 'Musik', 'Software', 'Utilitas', 'Lainnya'];
  final List<String> _statuses = ['Aktif', 'Non-Aktif'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4FF00),
              onPrimary: Colors.black,
              surface: Color(0xFF121214),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 16),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN SCAFFOLD AGAR MENJADI HALAMAN FULL SCREEN
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), // Latar belakang hitam pekat
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Langganan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Layanan'),
                    _buildTextField(_nameCtrl, 'Misal: Netflix'),
                    
                    _buildLabel('Harga (Rp)'),
                    _buildTextField(_priceCtrl, 'Misal: 150000', isNumber: true),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Kategori'),
                              _buildDropdown(_selectedCategory, _categories, (val) => setState(() => _selectedCategory = val!)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Status'),
                              _buildDropdown(_selectedStatus, _statuses, (val) => setState(() => _selectedStatus = val!)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    _buildLabel('Tanggal Jatuh Tempo'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: _buildFakeInput(DateFormat('dd MMMM yyyy').format(_selectedDate), Icons.calendar_month),
                    ),

                    _buildLabel('H- Berapa Hari Pengingat'),
                    _buildDropdown('H-$_reminderDays', ['H-1', 'H-3', 'H-7'], (val) {
                      setState(() => _reminderDays = int.parse(val!.replaceAll('H-', '')));
                    }),

                    const SizedBox(height: 20),
                    _buildSwitch('Perpanjangan Otomatis', _isAutoRenew, (val) => setState(() => _isAutoRenew = val)),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // TOMBOL SIMPAN DI BAGIAN PALING BAWAH LAYAR
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4FF00),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (_nameCtrl.text.isNotEmpty && _priceCtrl.text.isNotEmpty) {
                    final newSub = Subscription(
                      id: DateTime.now().toString(),
                      name: _nameCtrl.text,
                      price: double.parse(_priceCtrl.text),
                      dueDate: _selectedDate,
                      category: _selectedCategory,
                    );
                    context.read<SubProvider>().addSub(newSub);
                    Navigator.pop(context); // Kembali ke dashboard setelah simpan
                  }
                },
                child: const Text('TAMBAHKAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets (Sama seperti sebelumnya)
  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16)), // Warna form sedikit lebih terang dari background
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), border: InputBorder.none, contentPadding: const EdgeInsets.all(18)),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF121214),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFakeInput(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Icon(icon, color: Colors.white30)],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Switch(
          value: value, 
          onChanged: onChanged, 
          activeColor: Colors.black, 
          activeTrackColor: const Color(0xFFD4FF00),
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}