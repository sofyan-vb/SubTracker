// lib/widgets/subscription_tile.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../screens/detail_screen.dart';

class SubTile extends StatefulWidget {
  final Subscription sub;
  const SubTile({super.key, required this.sub});

  @override
  State<SubTile> createState() => _SubTileState();
}

class _SubTileState extends State<SubTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {}); 
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return 'Waktunya Pembayaran!';
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return 'Tinggal $days Hari $hours Jam';
    if (hours > 0) return 'Tinggal $hours Jam $minutes Menit';
    return 'Tinggal $minutes Menit $seconds Detik';
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Mengecek apakah sudah masuk waktu pembayaran
    final bool isDue = widget.sub.dueDate.isBefore(DateTime.now());
    final String countdownText = _getCountdownText(widget.sub.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: const Color(0xFF121214), 
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(sub: widget.sub)));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFD4FF00).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.edit_document, color: Color(0xFFD4FF00)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.sub.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      // JIKA JATUH TEMPO: Tampilkan teks animasi berjalan. JIKA TIDAK: Tampilkan teks biasa.
                      isDue 
                          ? SizedBox(
                              width: double.infinity,
                              child: MarqueeText(
                                text: countdownText, 
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            )
                          : Text(
                              countdownText, 
                              style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(widget.sub.price),
                  style: const TextStyle(color: Color(0xFFD4FF00), fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// WIDGET TAMBAHAN: Animasi Teks Berjalan (Muncul Tenggelam)
// =========================================================
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({super.key, required this.text, required this.style});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Kecepatan teks berjalan
    )..repeat(); // Mengulang animasi terus-menerus
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: ShaderMask(
        // Menambahkan efek gradasi agar teks terlihat "tenggelam" (memudar) di ujung kiri dan kanan
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, 0.1, 0.9, 1.0], 
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Menggerakkan posisi teks dari kanan ke kiri layar
            return Align(
              alignment: Alignment(2.0 - (_controller.value * 4.0), 0.0), 
              child: child,
            );
          },
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            softWrap: false, // Menahan teks agar tidak turun ke baris bawah
          ),
        ),
      ),
    );
  }
}