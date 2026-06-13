import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/icon.png');
  if (!file.existsSync()) {
    print('Logo not found!');
    return;
  }
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  Map<int, int> colorCounts = {};
  
  for (var p in image) {
    int r = p.r.toInt();
    int g = p.g.toInt();
    int b = p.b.toInt();
    
    // Ignore near white or near black to find the true accent color
    if ((r > 30 || g > 30 || b > 30) && (r < 240 || g < 240 || b < 240)) {
        // Group colors slightly to reduce noise (by shifting bits)
        int rG = (r ~/ 10) * 10;
        int gG = (g ~/ 10) * 10;
        int bG = (b ~/ 10) * 10;
        int rgb = (rG << 16) | (gG << 8) | bG;
        colorCounts[rgb] = (colorCounts[rgb] ?? 0) + 1;
    }
  }
  
  var sortedColors = colorCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    
  print('Top Dominant Accent Colors (Approx):');
  for (int i = 0; i < 10 && i < sortedColors.length; i++) {
    int color = sortedColors[i].key;
    int r = (color >> 16) & 0xFF;
    int g = (color >> 8) & 0xFF;
    int b = color & 0xFF;
    print("#\${r.toRadixString(16).padLeft(2, '0').toUpperCase()}\${g.toRadixString(16).padLeft(2, '0').toUpperCase()}\${b.toRadixString(16).padLeft(2, '0').toUpperCase()} - pixels: \${sortedColors[i].value}");
  }
}
