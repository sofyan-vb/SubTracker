import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';
import '../services/notification_service.dart';

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
  TimeOfDay _selectedTime = TimeOfDay.now(); 
  
  bool _isAutoRenew = true;
  String _selectedStatus = 'Aktif';
  
  
  int _reminderDays = 0; 

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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showGeneralDialog<TimeOfDay>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black87, 
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4FF00),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A1C), 
              onSurface: Colors.white, 
            ),
          ),
          child: TimePickerDialog(
            initialTime: _selectedTime, 
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack, 
            ),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, top: 16),
      child: Text(text, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B), 
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

                    _buildLabel('Waktu Pengingat (Tanggal & Jam)'),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: _buildFakeInput(DateFormat('dd MMM yyyy').format(_selectedDate), Icons.calendar_month),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _selectTime(context),
                            child: _buildFakeInput(_selectedTime.format(context), Icons.access_time_filled),
                          ),
                        ),
                      ],
                    ),

                   
                    _buildLabel('Ingatkan Saya Pada'),
                    _buildDropdown('H-$_reminderDays', ['H-0', 'H-1', 'H-3', 'H-7'], (val) {
                      setState(() => _reminderDays = int.parse(val!.replaceAll('H-', '')));
                    }),

                    const SizedBox(height: 20),
                    _buildSwitch('Perpanjangan Otomatis', _isAutoRenew, (val) => setState(() => _isAutoRenew = val)),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
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
                    
                 
                    DateTime exactDateTime = DateTime(
                      _selectedDate.year, 
                      _selectedDate.month, 
                      _selectedDate.day,
                      _selectedTime.hour, 
                      _selectedTime.minute,
                    );

                   
                    DateTime scheduledDateTime = exactDateTime.subtract(Duration(days: _reminderDays));

                    
                    if (scheduledDateTime.isBefore(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Jadwal pengingat (H-$_reminderDays) sudah terlewat! Atur ke waktu yang akan datang.', style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(20),
                        ),
                      );
                      return; 
                    }

                    final newSub = Subscription(
                      id: DateTime.now().millisecondsSinceEpoch.toString(), 
                      name: _nameCtrl.text,
                      price: double.parse(_priceCtrl.text),
                      dueDate: exactDateTime, 
                      category: _selectedCategory,
                    );
                    context.read<SubProvider>().addSub(newSub);

                    
                    try {
                      NotificationService.scheduleNotification(
                        newSub.id.hashCode, 
                        'Pengingat: Tagihan ${newSub.name} 💸',
                        'Pembayaran layanan sebesar Rp ${_priceCtrl.text} telah tiba waktunya.',
                        scheduledDateTime,
                      );
                    } catch (e) {
                      debugPrint('Gagal set notif: $e');
                    }

                    Navigator.pop(context); 
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

  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16)), 
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
        children: [
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), 
          Icon(icon, color: Colors.white30, size: 20)
        ],
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