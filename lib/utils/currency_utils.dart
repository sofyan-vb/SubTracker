import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrencyUtils {
  static Map<String, Map<String, dynamic>> data = {
    'IDR': {'symbol': 'Rp', 'locale': 'id_ID', 'name': 'Indonesia Rupiah', 'rate': 15500.0},
    'USD': {'symbol': '\$', 'locale': 'en_US', 'name': 'US Dollar', 'rate': 1.0},
    'EUR': {'symbol': '€', 'locale': 'de_DE', 'name': 'Euro', 'rate': 0.92},
    'GBP': {'symbol': '£', 'locale': 'en_GB', 'name': 'British Pound', 'rate': 0.79},
    'JPY': {'symbol': '¥', 'locale': 'ja_JP', 'name': 'Japanese Yen', 'rate': 150.0},
    'SGD': {'symbol': 'S\$', 'locale': 'en_SG', 'name': 'Singapore Dollar', 'rate': 1.35},
    'AUD': {'symbol': 'A\$', 'locale': 'en_AU', 'name': 'Australian Dollar', 'rate': 1.53},
    'MYR': {'symbol': 'RM', 'locale': 'ms_MY', 'name': 'Malaysian Ringgit', 'rate': 4.75},
  };

  static Future<void> fetchRealTimeRates() async {
    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final rates = body['rates'] as Map<String, dynamic>;
        
        data.forEach((key, value) {
          if (rates.containsKey(key)) {
            data[key]!['rate'] = (rates[key] as num).toDouble();
          }
        });
      }
    } catch (e) {
      // Silently fall back to default rates
    }
  }

  static NumberFormat getFormat(String currencyCode) {
    final currency = data[currencyCode] ?? data['IDR']!;
    return NumberFormat.currency(
      locale: currency['locale'],
      symbol: currency['symbol'] + ' ',
      decimalDigits: (currencyCode == 'IDR' || currencyCode == 'JPY') ? 0 : 2,
    );
  }

  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    double amountInUsd = amount;
    if (fromCurrency != 'USD') {
      final fromRate = data[fromCurrency]?['rate'] ?? 1.0;
      amountInUsd = amount / fromRate;
    }
    
    if (toCurrency == 'USD') return amountInUsd;
    
    final toRate = data[toCurrency]?['rate'] ?? 1.0;
    return amountInUsd * toRate;
  }
}
