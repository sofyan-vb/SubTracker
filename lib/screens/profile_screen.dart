import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dashboard_screen.dart';
import '../utils/toast_utils.dart';

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
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('user_name') ?? '';
      _base64Image = prefs.getString('profile_image');
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text);
    userNameNotifier.value = _nameCtrl.text;
    
    if (_base64Image != null) {
      await prefs.setString('profile_image', _base64Image!);
      userPhotoNotifier.value = _base64Image;
    }

    if (mounted) {
      ToastUtils.show(context, 'Profil berhasil disimpan');
      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.bgColor,
      appBar: AppBar(
        backgroundColor: widget.bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.textColor),
        title: Text('Profil Saya', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
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
                    decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Ketuk foto untuk mengubah', style: TextStyle(color: widget.textColor.withValues(alpha: 0.5), fontSize: 13)),
            const SizedBox(height: 40),
            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                labelText: 'Nama Pengguna',
                labelStyle: TextStyle(color: widget.textColor.withValues(alpha: 0.6)),
                filled: true,
                fillColor: widget.cardBg,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: widget.textColor.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0D9488))),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                onPressed: _saveProfile,
                child: const Text('Simpan Profil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
