import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrencyUtils {
  // Flags added for UI
  static Map<String, Map<String, dynamic>> data = {
    'IDR': {'symbol': 'Rp', 'locale': 'id_ID', 'name': 'Indonesia Rupiah', 'rate': 15500.0, 'flag': '🇮🇩'},
    'USD': {'symbol': '\$', 'locale': 'en_US', 'name': 'US Dollar', 'rate': 1.0, 'flag': '🇺🇸'},
    'EUR': {'symbol': '€', 'locale': 'de_DE', 'name': 'Euro', 'rate': 0.92, 'flag': '🇪🇺'},
    'GBP': {'symbol': '£', 'locale': 'en_GB', 'name': 'British Pound', 'rate': 0.79, 'flag': '🇬🇧'},
    'JPY': {'symbol': '¥', 'locale': 'ja_JP', 'name': 'Japanese Yen', 'rate': 150.0, 'flag': '🇯🇵'},
    'SGD': {'symbol': 'S\$', 'locale': 'en_SG', 'name': 'Singapore Dollar', 'rate': 1.35, 'flag': '🇸🇬'},
    'AUD': {'symbol': 'A\$', 'locale': 'en_AU', 'name': 'Australian Dollar', 'rate': 1.53, 'flag': '🇦🇺'},
    'MYR': {'symbol': 'RM', 'locale': 'ms_MY', 'name': 'Malaysian Ringgit', 'rate': 4.75, 'flag': '🇲🇾'},
  };

  static Future<void> fetchRealTimeRates() async {
    try {
      final response = await http.get(Uri.parse('https://api.frankfurter.dev/v1/latest?base=USD'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final rates = body['rates'] as Map<String, dynamic>;
        
        data.forEach((key, value) {
          if (rates.containsKey(key)) {
            data[key]!['rate'] = (rates[key] as num).toDouble();
          } else if (key == 'USD') {
            data[key]!['rate'] = 1.0;
          }
        });
      }
    } catch (e) {
      // Silently fall back to default rates
    }
  }

  // Fetch Historical Rates for Charts
  static Future<Map<String, double>> fetchHistoricalRates(String base, String target, String range) async {
    DateTime now = DateTime.now();
    DateTime start;

    switch (range) {
      case '1D':
        start = now.subtract(const Duration(days: 2)); // Use a couple of days to ensure we get data points
        break;
      case '5D':
        start = now.subtract(const Duration(days: 5));
        break;
      case '1M':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case '1Y':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      case '5Y':
        start = DateTime(now.year - 5, now.month, now.day);
        break;
      case 'Max':
        start = DateTime(2000, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month - 1, now.day);
    }

    String startStr = DateFormat('yyyy-MM-dd').format(start);
    String endStr = DateFormat('yyyy-MM-dd').format(now);
    
    // Frankfurter API: If start and end are the same, use 'latest' endpoint logic, or just let API handle it.
    String url = 'https://api.frankfurter.dev/v1/$startStr..$endStr?base=$base&symbols=$target';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final rates = body['rates'] as Map<String, dynamic>;
        
        Map<String, double> historicalData = {};
        rates.forEach((dateStr, rateMap) {
          historicalData[dateStr] = (rateMap[target] as num).toDouble();
        });
        
        return historicalData;
      }
    } catch (e) {
      // Fallback empty if fail
    }
    return {};
  }

  static NumberFormat getFormat(String currencyCode) {
    final currency = data[currencyCode] ?? data['IDR']!;
    return NumberFormat.currency(
      locale: currency['locale'],
      symbol: currency['symbol'] + ' ',
      decimalDigits: (currencyCode == 'IDR' || currencyCode == 'JPY') ? 0 : 4,
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
