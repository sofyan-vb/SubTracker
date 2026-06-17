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
  bool _isManualLogin = false;
  final Map<String, String?> _userPhotos = {};

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
      _isManualLogin = prefs.getBool('login_mode_manual') ?? false;
      
      for (var user in _savedUsers) {
        _userPhotos[user] = prefs.getString('user_photo_$user');
      }
      
      // Pastikan user saat ini ada di list
      if (_nameCtrl.text.isNotEmpty && !_savedUsers.contains(_nameCtrl.text)) {
        _savedUsers.insert(0, _nameCtrl.text);
        prefs.setStringList('saved_users', _savedUsers);
      }
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text);
    await prefs.setString('user_email', _emailCtrl.text.trim());
    await prefs.setBool('login_mode_manual', _isManualLogin);
    userNameNotifier.value = _nameCtrl.text;
    
    if (_base64Image != null) {
      await prefs.setString('profile_image', _base64Image!);
      await prefs.setString('user_photo_${_nameCtrl.text}', _base64Image!);
      userPhotoNotifier.value = _base64Image;
    }
    
    // Update active user in saved list if it changed
    if (!_savedUsers.contains(_nameCtrl.text) && _nameCtrl.text.isNotEmpty) {
      _savedUsers.insert(0, _nameCtrl.text);
      await prefs.setStringList('saved_users', _savedUsers);
    }

    if (mounted) {
      Provider.of<SubProvider>(context, listen: false).loadData();
      ToastUtils.show(context, 'Profil berhasil disimpan');
      Navigator.pop(context);
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
      _newUserCtrl.clear();
    });
    await prefs.setStringList('saved_users', _savedUsers);
    if (mounted) ToastUtils.show(context, 'Pengguna baru ditambahkan', icon: Icons.check_circle, iconColor: Colors.green);
  }

  Future<void> _removeSavedUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUsers.remove(name);
    });
    await prefs.setStringList('saved_users', _savedUsers);
  }

  Future<void> _testSendEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      if (mounted) {
        ToastUtils.show(context, 'Masukkan email terlebih dahulu!', icon: Icons.warning, iconColor: Colors.orange);
      }
      return;
    }

    // Save email first
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);

    setState(() => _isSendingTest = true);

    final result = await EmailService.sendNotificationEmail(
      toEmail: email,
      subject: 'Tes Notifikasi SubTracker',
      message: 'Selamat! Email notifikasi SubTracker Anda berhasil terhubung. Mulai sekarang, setiap kali Anda menambahkan langganan baru, notifikasinya akan dikirim ke email ini.',
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
              Container(width: 40, height: 4, decoration: BoxDecoration(color: widget.textColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
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
                    setState(() {
                      _base64Image = null;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('profile_image');
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
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch(e) {
      // Ignore
    }
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
    } catch(e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Gradient biru ke biru terang/putih
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
            Opacity(
              opacity: _isManualLogin ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !_isManualLogin,
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
                            child: _base64Image == null ? Icon(Icons.account_circle, size: 80, color: widget.textColor.withValues(alpha: 0.5)) : null,
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
                    Text('Ketuk foto untuk mengubah', style: TextStyle(color: widget.textColor.withValues(alpha: 0.5), fontSize: 13)),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _nameCtrl,
                      enabled: _isManualLogin,
                      style: TextStyle(color: widget.textColor),
                      decoration: InputDecoration(
                        labelText: 'Nama Pengguna',
                        labelStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: widget.cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E293B))),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailCtrl,
                      enabled: _isManualLogin,
                      style: TextStyle(color: widget.textColor),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.6)),
                        prefixIcon: Icon(Icons.email_outlined, color: widget.textColor.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: widget.cardBg,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
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
                          side: BorderSide(color: widget.textColor.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSendingTest ? null : _testSendEmail,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Pengaturan Mode Login
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.textColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode Login & Data', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mode Ketik Manual', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              _isManualLogin 
                                ? 'Aktif: Semua nama menggunakan database global yang sama.' 
                                : 'Nonaktif: Tiap nama memiliki database layanannya masing-masing.', 
                              style: TextStyle(color: widget.textColor.withValues(alpha: 0.6), fontSize: 12, height: 1.4)
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isManualLogin,
                        onChanged: (val) {
                          setState(() {
                            _isManualLogin = val;
                          });
                        },
                        activeColor: const Color(0xFF2563EB),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Petunjuk: Jika diaktifkan, Anda akan mengetik nama saat masuk dan data layanan akan menyatu (satu server). Jika dimatikan, Anda memilih nama dari daftar dan data layanan dipisah per nama otomatis.',
                            style: TextStyle(color: widget.textColor.withValues(alpha: 0.8), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // UI Manajemen Daftar Pengguna Lain
            Opacity(
              opacity: _isManualLogin ? 0.4 : 1.0,
              child: IgnorePointer(
                ignoring: _isManualLogin,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: widget.textColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daftar Pengguna', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Kelola nama-nama pengguna yang muncul saat memilih profil di layar Selamat Datang.', style: TextStyle(color: widget.textColor.withValues(alpha: 0.6), fontSize: 12)),
                      const SizedBox(height: 16),
                      
                      // List of saved users
                      if (_savedUsers.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedUsers.length,
                      itemBuilder: (context, index) {
                        final name = _savedUsers[index];
                        final isActive = name == _nameCtrl.text;
                        final photoBase64 = _userPhotos[name];
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
                            leading: GestureDetector(
                              onTap: () => _pickImageForUser(name),
                              child: CircleAvatar(
                                backgroundColor: isActive ? const Color(0xFF2563EB) : widget.textColor.withValues(alpha: 0.1),
                                backgroundImage: photoBase64 != null ? MemoryImage(base64Decode(photoBase64)) : null,
                                child: photoBase64 == null ? Icon(Icons.add_a_photo_rounded, color: isActive ? Colors.white : widget.textColor.withValues(alpha: 0.6), size: 16) : null,
                              ),
                            ),
                            title: Text(name, style: TextStyle(color: widget.textColor, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                            trailing: isActive 
                                ? const Text('Aktif', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12))
                                : const Icon(Icons.swipe_left_rounded, color: Colors.redAccent, size: 16),
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 12),
                                        if (_savedUsers.isEmpty)
                        Text('Belum ada profil pengguna tersimpan.', style: TextStyle(color: widget.textColor.withValues(alpha: 0.6), fontSize: 13, fontStyle: FontStyle.italic)),
                      
                      const SizedBox(height: 16),
                      // Add new user section
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newUserCtrl,
                              enabled: !_isManualLogin,
                              style: TextStyle(color: widget.textColor, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tambah nama baru',
                                hintStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.4)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.2))),
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
                            child: const Text('Tambah'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                onPressed: _saveProfile,
                child: const Text('Simpan Profil', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
                child: const Text('Reset Data Pengguna Ini', style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
