import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../screens/detail_screen.dart';
import '../screens/dashboard_screen.dart'; 
import '../utils/category_utils.dart';
import '../utils/currency_utils.dart';
import '../widgets/logo_widget.dart';

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
    if (diff.isNegative) return tr('Waktunya Pembayaran!', 'Payment Due!', '¡Pago vencido!');
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return tr('Tinggal $days Hari $hours Jam $minutes Menit $seconds Detik', '$days Days $hours Hrs $minutes Mins $seconds Secs Left', '$days Días $hours Horas $minutes Minutos $seconds Segundos restantes');
    if (hours > 0) return tr('Tinggal $hours Jam $minutes Menit $seconds Detik', '$hours Hrs $minutes Mins $seconds Secs Left', '$hours Horas $minutes Minutos $seconds Segundos restantes');
    return tr('Tinggal $minutes Menit $seconds Detik', '$minutes Mins $seconds Secs Left', '$minutes Minutos $seconds Segundos restantes');
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    final convertedPrice = CurrencyUtils.convert(widget.sub.price, widget.sub.currency, currencyNotifier.value);
    final bool isDue = widget.sub.dueDate.isBefore(DateTime.now());
    final bool isFinished = widget.sub.isFinished; 
    final bool isDeleted = widget.sub.isDeleted;
    final String countdownText = _getCountdownText(widget.sub.dueDate);
    final catColor = CategoryUtils.getColor(widget.sub.category);
    final catIcon = CategoryUtils.getIcon(widget.sub.category);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              if (isFinished || isDeleted) ...[
                SlidableAction(
                  onPressed: (context) {
                    final provider = context.read<SubProvider>();
                    final updated = widget.sub.copyWith(
                      dueDate: isFinished ? DateTime(widget.sub.dueDate.year, widget.sub.dueDate.month + 1, widget.sub.dueDate.day) : widget.sub.dueDate,
                      isFinished: false,
                      isDeleted: false
                    );
                    provider.updateSub(updated);
                    if (isFinished) provider.addHistory(widget.sub.name, widget.sub.price, DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(tr('Langganan dipulihkan', 'Subscription restored', 'Suscripción restaurada'), style: TextStyle(color: textColor)),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  icon: Icons.restore,
                  label: tr('Pulihkan', 'Restore', 'Restaurar'),
                ),
                SlidableAction(
                  onPressed: (context) {
                    final provider = context.read<SubProvider>();
                    provider.removeSub(widget.sub.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(tr('Dihapus permanen', 'Permanently deleted', 'Eliminado permanentemente'), style: TextStyle(color: textColor)),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                  label: tr('Hapus', 'Delete', 'Borrar'),
                ),
              ] else ...[
                SlidableAction(
                  onPressed: (context) {
                    final provider = context.read<SubProvider>();
                    provider.markAsPaid(widget.sub);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(tr('Langganan ditandai selesai', 'Subscription marked as paid', 'Suscripción marcada como pagada'), style: TextStyle(color: textColor)),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  icon: Icons.check_circle_outline,
                  label: tr('Selesai', 'Done', 'Hecho'),
                ),
                SlidableAction(
                  onPressed: (context) {
                    final provider = context.read<SubProvider>();
                    provider.togglePause(widget.sub.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(widget.sub.isPaused ? 'Langganan dilanjutkan' : 'Langganan di-pause', style: TextStyle(color: textColor)),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  icon: widget.sub.isPaused ? Icons.play_arrow : Icons.pause,
                  label: widget.sub.isPaused ? 'Resume' : 'Pause',
                ),
                SlidableAction(
                  onPressed: (context) {
                    final provider = context.read<SubProvider>();
                    provider.deleteSub(widget.sub.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(tr('Langganan dihapus', 'Subscription deleted', 'Suscripción eliminada'), style: TextStyle(color: textColor)),
                      backgroundColor: cardBg,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ));
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: tr('Hapus', 'Delete', 'Borrar'),
                ),
              ],
            ],
          ),
          child: Material(
            color: Colors.transparent, 
            child: InkWell(
              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(sub: widget.sub))); },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    LogoWidget(name: widget.sub.name, category: widget.sub.category, customLogoPath: widget.sub.customLogoPath, size: 48, borderRadius: 12),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(widget.sub.name, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                              if (widget.sub.isTrial)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.pinkAccent.withOpacity(0.5))),
                                  child: const Text('TRIAL', style: TextStyle(color: Colors.pinkAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              if (widget.sub.splitCount > 1)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.teal.withOpacity(0.5))),
                                  child: Text('1/${widget.sub.splitCount}', style: const TextStyle(color: Colors.teal, fontSize: 8, fontWeight: FontWeight.bold)),
                                )
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(catIcon, color: catColor, size: 12),
                              const SizedBox(width: 4),
                              Text(widget.sub.category, style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          widget.sub.isPaused 
                              ? const Text('Sedang di-pause', style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w600))
                              : isDeleted
                                  ? MarqueeText(text: tr('Langganan telah dihapus.', 'Subscription has been deleted.', 'La suscripción ha sido eliminada.'), style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600))
                                  : isFinished
                                      ? MarqueeText(text: tr('Pembayaran sudah selesai.', 'Payment completed.', 'Pago completado.'), style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600))
                                      : isDue 
                                          ? MarqueeText(text: countdownText, style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600))
                                          : Text(countdownText, style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(currencyFormat.format(convertedPrice / widget.sub.splitCount), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        if (isDeleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('DELETED', style: TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                        else if (isFinished)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Text('PAID', style: TextStyle(color: Color(0xFF10B981), fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                        else
                           Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(DateFormat('MMM dd').format(widget.sub.dueDate), style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                          )
                      ],
                    )
                  ],
                ),
              ),
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