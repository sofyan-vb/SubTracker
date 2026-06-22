import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../firebase_options.dart';

class CloudSyncService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      'email',
    ],
  );

  static Future<String> syncWithGoogleDrive(List<Subscription> subs) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Sinkronisasi dibatalkan oleh pengguna.";
      }

      var httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        return "Gagal mendapatkan otentikasi klien Google Drive.";
      }

      var driveApi = drive.DriveApi(httpClient);

      final String jsonData = jsonEncode(subs.map((s) => s.toJson()).toList());
      final stream = Stream.value(utf8.encode(jsonData));
      
      var driveFile = drive.File();
      driveFile.name = "SubtrackIQ_Backup.json";

      await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(stream, jsonData.length),
      );

      return "Berhasil diunggah ke Google Drive (${googleUser.email}).";
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<String> syncWithFirebase(List<Subscription> subs) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Sinkronisasi dibatalkan oleh pengguna.";
      }

      final String userId = googleUser.email;
      
      final db = FirebaseFirestore.instance;
      final batch = db.batch();
      
      final userDocRef = db.collection('users').doc(userId);
      batch.set(userDocRef, {'lastSync': FieldValue.serverTimestamp()});

      for (var sub in subs) {
        final docRef = userDocRef.collection('subscriptions').doc(sub.id);
        batch.set(docRef, sub.toJson());
      }
      
      await batch.commit();

      return "Berhasil tersinkronisasi ke Firebase Firestore untuk akun $userId.";
    } catch (e) {
      return "Firebase Error: Anda belum menjalankan 'flutterfire configure' atau memasukkan google-services.json ke dalam proyek ini.";
    }
  }
}
