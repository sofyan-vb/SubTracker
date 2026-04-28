import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class SubTile extends StatelessWidget {
  final Subscription sub;
  const SubTile({super.key, required this.sub});

  Map<String, dynamic> _getCategoryStyle(String name) {
    if (name.toLowerCase().contains('netflix') || name.toLowerCase().contains('youtube')) {
      return {'icon': Icons.play_circle_fill, 'color': const Color(0xFFEF4444)}; 
    } else if (name.toLowerCase().contains('spotify')) {
      return {'icon': Icons.music_note, 'color': const Color(0xFF10B981)}; 
    } else if (name.toLowerCase().contains('adobe')) {
      return {'icon': Icons.brush, 'color': const Color(0xFF3B82F6)}; 
    }
    return {'icon': Icons.receipt, 'color': const Color(0xFF8B5CF6)}; 
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final daysLeft = sub.dueDate.difference(DateTime.now()).inDays;
    final isDueSoon = daysLeft <= 3;
    final style = _getCategoryStyle(sub.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Slidable(
        key: ValueKey(sub.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context.read<SubProvider>().deleteSub(sub.id),
              backgroundColor: Colors.transparent,
              foregroundColor: const Color(0xFFEF4444),
              icon: Icons.delete_outline,
              label: 'Hapus',
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF151A26),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: style['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(style['icon'], color: style['color'], size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      isDueSoon ? 'Sisa $daysLeft hari' : DateFormat('dd MMM yyyy').format(sub.dueDate),
                      style: TextStyle(
                        fontSize: 13, 
                        color: isDueSoon ? const Color(0xFFEF4444) : Colors.grey[500],
                        fontWeight: isDueSoon ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(sub.price),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}