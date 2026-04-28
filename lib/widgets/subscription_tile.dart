import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/subscription_provider.dart';

class SubTile extends StatelessWidget {
  final Subscription sub;
  const SubTile({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final daysLeft = sub.dueDate.difference(DateTime.now()).inDays;
    final isDueSoon = daysLeft <= 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(sub.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => context.read<SubProvider>().deleteSub(sub.id),
              backgroundColor: const Color(0xFFFF3366), // Solid Red
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Hapus',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121214), // Warna card solid
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)), // Border tegas
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.white70, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sub.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      isDueSoon ? 'Sisa $daysLeft hari' : DateFormat('dd MMM yyyy').format(sub.dueDate),
                      style: TextStyle(
                        fontSize: 13, 
                        color: isDueSoon ? const Color(0xFFFF3366) : Colors.grey[600],
                        fontWeight: isDueSoon ? FontWeight.bold : FontWeight.normal
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(sub.price),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}