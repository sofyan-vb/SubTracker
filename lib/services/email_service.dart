import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  static const String _serviceId = 'service_suoomnd';
  static const String _templateId = 'template_ggozda5';
  static const String _publicKey = '1VHiKzdmkRTCwTpiA';
  static const String _privateKey = '3Q9RO5S2u29MCfnqA-hGr';
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  static Future<String> sendNotificationEmail({
    required String toEmail,
    required String subject,
    required String message,
    String name = 'SubtrackIQ',
  }) async {
    try {
      debugPrint('=== EMAIL SERVICE ===');
      debugPrint('Sending to: $toEmail');
      debugPrint('Subject: $subject');
      
      final url = Uri.parse(_apiUrl);
      final body = json.encode({
        'service_id': _serviceId,
        'template_id': _templateId,
        'user_id': _publicKey,
        'accessToken': _privateKey,
        'template_params': {
          'to_email': toEmail,
          'subject': subject,
          'message': message,
          'name': name,
          'email': toEmail,
        }
      });
      
      debugPrint('Sending request...');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: body,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('=== EMAIL SENT SUCCESSFULLY! ===');
        return 'OK';
      } else {
        debugPrint('=== EMAIL FAILED: ${response.statusCode} ===');
        return 'EmailJS Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      debugPrint('=== EMAIL ERROR: $e ===');
      return 'Network Error: $e';
    }
  }
}
