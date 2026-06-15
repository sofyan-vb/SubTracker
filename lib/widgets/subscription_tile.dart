import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../screens/detail_screen.dart';
import '../screens/dashboard_screen.dart'; 
import '../utils/category_utils.dart';
import '../utils/currency_utils.dart';

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
    if (diff.isNegative) return tr('Waktunya Pembayaran!', 'Payment Due!');
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return tr('Tinggal $days Hari $hours Jam', '$days Days $hours Hours Left');
    if (hours > 0) return tr('Tinggal $hours Jam $minutes Menit', '$hours Hours $minutes Mins Left');
    return tr('Tinggal $minutes Menit $seconds Detik', '$minutes Mins $seconds Secs Left');
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    final bool isDue = widget.sub.dueDate.isBefore(DateTime.now());
    final bool isFinished = widget.sub.isFinished; 
    final String countdownText = _getCountdownText(widget.sub.dueDate);
    final catColor = CategoryUtils.getColor(widget.sub.category);
    final catIcon = CategoryUtils.getIcon(widget.sub.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0B101E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(sub: widget.sub))); },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle), child: Icon(catIcon, color: Colors.white, size: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.sub.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      isFinished
                          ? MarqueeText(text: tr('Pembayaran sudah selesai.', 'Payment completed.'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600))
                          : isDue 
                              ? MarqueeText(text: countdownText, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w600))
                              : Text(countdownText, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(currencyFormat.format(widget.sub.price), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MarqueeText extends StatefulWidget {
  final String text; final TextStyle style;
  const MarqueeText({super.key, required this.text, required this.style});
  @override State<MarqueeText> createState() => _MarqueeTextState();
}
class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState() { super.initState(); _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000))..repeat(); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return SizedBox(height: 18, width: double.infinity, child: ClipRect(child: ShaderMask(shaderCallback: (rect) { return const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent], stops: [0.0, 0.1, 0.9, 1.0]).createShader(rect); }, blendMode: BlendMode.dstIn, child: LayoutBuilder(builder: (context, constraints) { final width = constraints.hasBoundedWidth ? constraints.maxWidth : 200.0; return Stack(children: [AnimatedBuilder(animation: _controller, builder: (context, child) { final dx = width - (_controller.value * (width + 150)); return Positioned(left: dx, top: 0, bottom: 0, child: Align(alignment: Alignment.centerLeft, child: Text(widget.text, style: widget.style, maxLines: 1, softWrap: false))); })]); })))); }
}