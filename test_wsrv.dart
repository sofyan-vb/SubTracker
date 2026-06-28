import 'dart:io';

void main() async {
  final url = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/IndiHome_logo.svg/250px-IndiHome_logo.svg.png';
  try {
    final req = await HttpClient().headUrl(Uri.parse(url));
    // Default Flutter Image.network doesn't send User-Agent (or sends Dart)
    req.headers.set('User-Agent', 'SubTracker/1.0 (Mobile App)');
    final res = await req.close();
    print('Status: ${res.statusCode}');
  } catch (e) {
    print('Error - $e');
  }
}
