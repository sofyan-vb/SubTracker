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
                      Text(
                        _getCountdownText(widget.sub.dueDate), 
                        style: TextStyle(
                          color: widget.sub.dueDate.isBefore(DateTime.now()) ? Colors.redAccent : Colors.white54, 
                          fontSize: 13, 
                          fontWeight: FontWeight.w600
                        ),
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