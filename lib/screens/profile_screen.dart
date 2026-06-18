import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'dashboard_screen.dart';
import '../utils/toast_utils.dart';
import '../services/email_service.dart';
import '../services/export_service.dart';
import '../services/cloud_sync_service.dart';
import '../main.dart'; // Untuk themeModeNotifier

class ProfileScreen extends StatefulWidget {
  final Color bgColor;
  final Color textColor;
  final Color cardBg;

  const ProfileScreen({super.key, required this.bgColor, required this.textColor, required this.cardBg});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _newUserCtrl = TextEditingController();
  
  String? _base64Image;
  bool _isSendingTest = false;
  List<String> _savedUsers = [];
  
  final Map<String, String?> _userPhotos = {};
  final Map<String, String> _userEmails = {}; // Map baru untuk menyimpan email masing-masing profil

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('user_name') ?? '';
      _emailCtrl.text = prefs.getString('user_email') ?? '';
      _base64Image = prefs.getString('profile_image');
      _savedUsers = prefs.getStringList('saved_users') ?? [];
      
      for (var user in _savedUsers) {
        _userPhotos[user] = prefs.getString('user_photo_$user');
        _userEmails[user] = prefs.getString('user_email_$user') ?? '';
      }
      
      // Pastikan user saat ini ada di list
      if (_nameCtrl.text.isNotEmpty && !_savedUsers.contains(_nameCtrl.text)) {
        _savedUsers.insert(0, _nameCtrl.text);
        prefs.setStringList('saved_users', _savedUsers);
      }
      
      // Migrasi: Jika email spesifik profil kosong tapi email global ada, simpan ke profil ini
      if (_nameCtrl.text.isNotEmpty && (_userEmails[_nameCtrl.text] == null || _userEmails[_nameCtrl.text]!.isEmpty)) {
        _userEmails[_nameCtrl.text] = _emailCtrl.text;
        prefs.setString('user_email_${_nameCtrl.text}', _emailCtrl.text);
      }
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final currentName = _nameCtrl.text.trim();
    final currentEmail = _emailCtrl.text.trim();
    
    await prefs.setString('user_name', currentName);
    await prefs.setString('user_email', currentEmail);
    await prefs.setString('user_email_$currentName', currentEmail); // Simpan email khusus profil ini
    
    userNameNotifier.value = currentName;
    
    if (_base64Image != null) {
      await prefs.setString('profile_image', _base64Image!);
      await prefs.setString('user_photo_$currentName', _base64Image!);
      userPhotoNotifier.value = _base64Image;
    } else {
      await prefs.remove('profile_image');
      await prefs.remove('user_photo_$currentName');
      userPhotoNotifier.value = null;
    }
    
    // Update profil di daftar
    if (!_savedUsers.contains(currentName) && currentName.isNotEmpty) {
      _savedUsers.insert(0, currentName);
      await prefs.setStringList('saved_users', _savedUsers);
    }
    
    setState(() {
      _userEmails[currentName] = currentEmail;
      _userPhotos[currentName] = _base64Image;
    });

    if (mounted) {
      Provider.of<SubProvider>(context, listen: false).loadData();
      ToastUtils.show(context, 'Pengaturan Profil berhasil disimpan', icon: Icons.check_circle, iconColor: Colors.green);
      Navigator.pop(context);
    }
  }

  // FUNGSI BARU: Beralih profil langsung saat daftar diklik
  Future<void> _switchActiveUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    
    String newEmail = prefs.getString('user_email_$name') ?? '';
    String? newPhoto = prefs.getString('user_photo_$name');
    
    setState(() {
      _nameCtrl.text = name;
      _emailCtrl.text = newEmail;
      _base64Image = newPhoto;
    });
    
    // Jadikan profil ini sebagai profil global yang sedang aktif
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', newEmail);
    if (newPhoto != null) {
      await prefs.setString('profile_image', newPhoto);
    } else {
      await prefs.remove('profile_image');
    }
    
    userNameNotifier.value = name;
    userPhotoNotifier.value = newPhoto;
    
    if (mounted) {
      Provider.of<SubProvider>(context, listen: false).loadData();
      ToastUtils.show(context, 'Beralih ke profil: $name', icon: Icons.person_pin_rounded, iconColor: const Color(0xFF2563EB));
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Data Pengguna'),
        content: const Text('Apakah Anda yakin ingin mereset seluruh data layanan untuk pengguna ini? Aksi ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await Provider.of<SubProvider>(context, listen: false).resetData();
      ToastUtils.show(context, 'Data layanan berhasil direset', icon: Icons.check_circle, iconColor: Colors.green);
    }
  }

  Future<void> _addSavedUser() async {
    final newName = _newUserCtrl.text.trim();
    if (newName.isEmpty) return;
    if (_savedUsers.contains(newName)) {
      ToastUtils.show(context, 'Nama pengguna sudah ada');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsers.add(newName);
      _userEmails[newName] = ''; // Inisialisasi email kosong untuk profil baru
      _newUserCtrl.clear();
    });
    await prefs.setStringList('saved_users', _savedUsers);
    if (mounted) ToastUtils.show(context, 'Berhasil. Klik nama tersebut untuk mengatur profilnya!', icon: Icons.check_circle, iconColor: Colors.green);
  }

  Future<void> _removeSavedUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
    
      _savedUsers.remove(name);
      _userEmails.remove(name);
      _userPhotos.remove(name);
    
      if (name == _nameCtrl.text) {
      
        _nameCtrl.clear();
        _emailCtrl.clear();
        _base64Image = null;
      
        prefs.remove('user_name');
        prefs.remove('user_email');
        prefs.remove('profile_image');
        
        userNameNotifier.value = '';
        userPhotoNotifier.value = null;
      }
    });
    
    await prefs.setStringList('saved_users', _savedUsers);
    await prefs.remove('user_email_$name');
    await prefs.remove('user_photo_$name');
    
    if (mounted) {
      ToastUtils.show(context, 'Profil $name berhasil dihapus', icon: Icons.delete_outline, iconColor: Colors.redAccent);
    }
  }

  Future<void> _testSendEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        ToastUtils.show(context, 'Masukkan alamat email terlebih dahulu!', icon: Icons.warning, iconColor: Colors.orange);
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setString('user_email_${_nameCtrl.text.trim()}', email);

    setState(() => _isSendingTest = true);

    final result = await EmailService.sendNotificationEmail(
      toEmail: email,
      subject: 'Tes Notifikasi SubTracker',
      message: 'Selamat! Email notifikasi SubTracker Anda berhasil terhubung. Mulai sekarang, setiap kali Anda menambahkan langganan baru di profil ini, notifikasinya akan dikirim ke email ini.',
      name: _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'SubTracker',
    );

    if (mounted) {
      setState(() => _isSendingTest = false);
      final success = result == 'OK';
      
      ToastUtils.show(
        context, 
        success ? 'Email tes berhasil dikirim ke $email! Cek inbox.' : 'Gagal: $result',
        icon: success ? Icons.check_circle : Icons.error,
        iconColor: success ? const Color(0xFF2563EB) : Colors.redAccent,
        duration: const Duration(seconds: 8),
      );
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.cardBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: widget.textColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF2563EB)),
                title: Text('Pilih dari Galeri', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage();
                },
              ),
              if (_base64Image != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Hapus Foto Profil', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    setState(() { _base64Image = null; });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('profile_image');
                    await prefs.remove('user_photo_${_nameCtrl.text.trim()}');
                    userPhotoNotifier.value = null;
                    if (mounted) Navigator.pop(ctx);
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        Uint8List bytes = await file.readAsBytes();
        setState(() { _base64Image = base64Encode(bytes); });
      }
    } catch(e) {}
  }

  Future<void> _pickImageForUser(String name) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        Uint8List bytes = await file.readAsBytes();
        String base64Str = base64Encode(bytes);
        
        setState(() {
          _userPhotos[name] = base64Str;
          if (name == _nameCtrl.text) {
             _base64Image = base64Str;
             userPhotoNotifier.value = base64Str;
          }
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo_$name', base64Str);
        if (name == _nameCtrl.text) {
           await prefs.setString('profile_image', base64Str);
        }
      }
    } catch(e) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentBgColor = isDark ? const Color(0xFF0F172A) : widget.bgColor;
    final currentCardBg = isDark ? const Color(0xFF1E293B) : widget.cardBg;
    final currentTextColor = isDark ? Colors.white : widget.textColor;

    return Scaffold(
      backgroundColor: currentBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Profil & Akun', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showImageOptions,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: widget.cardBg,
                    backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
                    child: _base64Image == null ? Icon(Icons.account_circle, size: 80, color: widget.textColor.withOpacity(0.5)) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF1E293B), size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Ketuk foto untuk mengubah', style: TextStyle(color: widget.textColor.withOpacity(0.5), fontSize: 13)),
            
            const SizedBox(height: 40),
            
            // --- BAGIAN 1: PROFIL AKTIF SAAT INI ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Profil Aktif Saat Ini', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Ini adalah profil yang sedang Anda gunakan sekarang. Anda bisa mengatur nama atau alamat email notifikasinya di bawah ini.', style: TextStyle(color: widget.textColor.withOpacity(0.6), fontSize: 12, height: 1.4)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                labelText: 'Ubah Nama Profil',
                labelStyle: TextStyle(color: widget.textColor.withOpacity(0.6)),
                filled: true, fillColor: widget.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              style: TextStyle(color: widget.textColor),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: widget.textColor.withOpacity(0.6)),
                prefixIcon: Icon(Icons.email_outlined, color: widget.textColor.withOpacity(0.5)),
                filled: true, fillColor: widget.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B))),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isSendingTest 
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: widget.textColor))
                    : Icon(Icons.send_rounded, size: 18, color: widget.textColor),
                label: Text(
                  _isSendingTest ? 'Mengirim...' : 'Tes Kirim Email',
                  style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.textColor.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSendingTest ? null : _testSendEmail,
              ),
            ),
            const SizedBox(height: 36),

            // --- BAGIAN 2: MANAJEMEN PROFIL LAIN ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.textColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daftar Profil Tersimpan', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ketuk salah satu nama di bawah ini untuk beralih profil dan mengatur email/catatannya secara terpisah.', style: TextStyle(color: widget.textColor.withOpacity(0.6), fontSize: 12, height: 1.4)),
                  const SizedBox(height: 16),
                  
                  if (_savedUsers.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedUsers.length,
                      itemBuilder: (context, index) {
                        final name = _savedUsers[index];
                        final isActive = name == _nameCtrl.text;
                        final photoBase64 = _userPhotos[name];
                        final userEmail = _userEmails[name];
                        
                        return Dismissible(
                          key: Key(name),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _removeSavedUser(name),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete_sweep, color: Colors.white),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              if (!isActive) _switchActiveUser(name);
                            },
                            leading: GestureDetector(
                              onTap: () => _pickImageForUser(name),
                              child: CircleAvatar(
                                backgroundColor: isActive ? const Color(0xFF2563EB) : widget.textColor.withOpacity(0.1),
                                backgroundImage: photoBase64 != null ? MemoryImage(base64Decode(photoBase64)) : null,
                                child: photoBase64 == null ? Icon(Icons.add_a_photo_rounded, color: isActive ? Colors.white : widget.textColor.withOpacity(0.6), size: 16) : null,
                              ),
                            ),
                            title: Text(name, style: TextStyle(color: widget.textColor, fontWeight: isActive ? FontWeight.bold : FontWeight.w600)),
                            subtitle: Text(
                              (userEmail != null && userEmail.isNotEmpty) ? userEmail : 'Email belum diatur', 
                              style: TextStyle(
                                color: widget.textColor.withOpacity(0.5), 
                                fontSize: 11, 
                                fontStyle: (userEmail != null && userEmail.isNotEmpty) ? FontStyle.normal : FontStyle.italic
                              )
                            ),
                            trailing: isActive 
                                ? const Text('Sedang Dipakai', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11))
                                : const Icon(Icons.touch_app_rounded, color: Colors.black26, size: 20),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newUserCtrl,
                          style: TextStyle(color: widget.textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Ketik nama profil baru...',
                            hintStyle: TextStyle(color: widget.textColor.withOpacity(0.4)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withOpacity(0.2))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addSavedUser,
                        child: const Text('Buat'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- BAGIAN 3: PENGATURAN TAMBAHAN (TEMA & EKSPOR) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: currentTextColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengaturan Lanjutan', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  // Dark Mode Switch
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeModeNotifier,
                    builder: (context, currentMode, _) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(currentMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF2563EB)),
                        title: Text('Mode Gelap (Dark Mode)', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.w600)),
                        trailing: Switch(
                          value: currentMode == ThemeMode.dark,
                          onChanged: (val) async {
                            final newMode = val ? ThemeMode.dark : ThemeMode.light;
                            themeModeNotifier.value = newMode;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('app_theme_mode', val ? 'Dark' : 'Light');
                          },
                          activeColor: const Color(0xFF2563EB),
                        ),
                      );
                    }
                  ),
                  const Divider(),
                  
                  // Export CSV
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.table_chart, color: Colors.green),
                    title: Text('Ekspor Laporan CSV', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final subs = Provider.of<SubProvider>(context, listen: false).subs;
                      await ExportService.exportToCSV(subs);
                    },
                  ),
                  
                  // Export PDF
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                    title: Text('Ekspor Laporan PDF', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final subs = Provider.of<SubProvider>(context, listen: false).subs;
                      await ExportService.exportToPDF(subs);
                    },
                  ),
                  const Divider(),
                  
                  // Cloud Sync
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cloud_sync, color: Color(0xFF2563EB)),
                    title: Text('Sinkronisasi Google Drive', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final subs = Provider.of<SubProvider>(context, listen: false).subs;
                      final result = await CloudSyncService.syncWithGoogleDrive(subs);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                    title: Text('Sinkronisasi Firebase', style: TextStyle(color: currentTextColor, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final subs = Provider.of<SubProvider>(context, listen: false).subs;
                      final result = await CloudSyncService.syncWithFirebase(subs);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                onPressed: _saveProfile,
                child: const Text('Simpan Pengaturan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _resetData,
                child: const Text('Reset Data Profil Pengguna Ini', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}