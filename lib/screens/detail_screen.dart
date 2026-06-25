import 'dart:async';
import 'package:flutter/material.dart';
import 'package:subtrack_iq/utils/category_utils.dart';
import '../utils/toast_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; 
import '../models/subscription.dart';
import '../providers/subscription_provider.dart'; 
import 'dashboard_screen.dart';
import '../utils/currency_utils.dart';
import 'edit_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../widgets/logo_widget.dart';

class DetailScreen extends StatefulWidget {
  final Subscription sub;
  const DetailScreen({super.key, required this.sub});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Timer? _timer;
  late Subscription currentSub;
  final TextEditingController _monthCtrl = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    currentSub = widget.sub; 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _monthCtrl.dispose(); 
    _timer?.cancel();
    super.dispose();
  }

  String _getCountdownText(DateTime dueDate) {
    if (currentSub.isFinished) return tr('PEMBAYARAN SUDAH SELESAI', 'PAYMENT COMPLETED');
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return tr('SEKARANG WAKTUNYA BAYAR!', 'PAYMENT DUE NOW!');
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return tr('Tinggal $days Hari $hours Jam', '$days Days $hours Hours Left');
    if (hours > 0) return tr('Tinggal $hours Jam $minutes Menit', '$hours Hours $minutes Mins Left');
    return tr('Tinggal $minutes Menit $seconds Detik', '$minutes Mins $seconds Secs Left');
  }

  void _deleteSub() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Hapus Catatan?', 'Delete Record?'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Text(tr('Apakah kamu yakin? Catatan yang dihapus tidak bisa dikembalikan.', 'Are you sure? Deleted records cannot be recovered.'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)))),
          TextButton(
            onPressed: () {
              context.read<SubProvider>().deleteSub(currentSub.id);
              ToastUtils.show(context, tr('Catatan berhasil dihapus', 'Record deleted successfully'));
              Navigator.pop(ctx); 
              Navigator.pop(context); 
            }, 
            child: Text(tr('Hapus', 'Delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _showCheckOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.update, color: Color(0xFF2563EB)), title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _showRenewInput(); }),
          ListTile(leading: Icon(Icons.task_alt, color: isDark ? Colors.white : const Color(0xFF1E293B)), title: Text(tr('Tandai Sudah Selesai', 'Mark as Completed'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _markAsFinished(); }),
        ],
      ),
    );
  }

  void _markAsFinished() {
    final provider = context.read<SubProvider>();
    final newHistory = List<DateTime>.from(currentSub.paymentHistory);
    newHistory.add(DateTime.now());

    final updatedSub = currentSub.copyWith(isFinished: true, paymentHistory: newHistory);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Catatan ditandai selesai', 'Record marked as completed'));
  }

  void _showRenewInput() {
    _monthCtrl.clear(); 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Perpanjang Langganan', 'Renew Subscription'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Berapa bulan kamu ingin memperpanjang?', 'How many months to renew?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _monthCtrl, autofocus: true, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: '1', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26), suffixText: tr('Bulan', 'Month(s)'), suffixStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14), filled: true, fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
          TextButton(
            onPressed: () {
              final int? m = int.tryParse(_monthCtrl.text);
              if (m != null && m > 0) { Navigator.pop(ctx); _processRenewal(m); } 
              else { ToastUtils.show(context, tr('Masukkan angka valid', 'Enter valid number'), icon: Icons.error_outline, iconColor: Colors.redAccent); }
            }, 
            child: Text(tr('Simpan', 'Save'), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _processRenewal(int monthsToAdd) {
    final provider = context.read<SubProvider>();
    final newDate = DateTime(currentSub.dueDate.year, currentSub.dueDate.month + monthsToAdd, currentSub.dueDate.day, currentSub.dueDate.hour, currentSub.dueDate.minute);
    final newHistory = List<DateTime>.from(currentSub.paymentHistory);
    newHistory.add(DateTime.now());

    final updatedSub = currentSub.copyWith(dueDate: newDate, isFinished: false, paymentHistory: newHistory);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Diperpanjang $monthsToAdd Bulan', 'Renewed for $monthsToAdd Month(s)'));
  }

  void _useServiceToday() {
    final provider = context.read<SubProvider>();
    final updatedSub = currentSub.copyWith(usageCount: currentSub.usageCount + 1);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Berhasil dicatat', 'Recorded successfully'));
  }

  Future<void> _tagihTeman() async {
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    final amount = currencyFormat.format(CurrencyUtils.convert(currentSub.price, currentSub.currency, currencyNotifier.value) / currentSub.splitCount);
    final date = DateFormat('dd MMM yyyy').format(currentSub.dueDate);
    final text = 'Halo! Sekadar pengingat untuk patungan tagihan ${currentSub.name} sebesar $amount yang jatuh tempo pada $date.';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ToastUtils.show(context, tr('Gagal membuka WhatsApp', 'Failed to open WhatsApp'));
    }
  }

  void _addToCalendar() {
    final Event event = Event(
      title: 'Tagihan ${currentSub.name}',
      description: 'Jangan lupa bayar tagihan ${currentSub.name}',
      location: '',
      startDate: currentSub.dueDate,
      endDate: currentSub.dueDate.add(const Duration(hours: 1)),
      allDay: true,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyUtils.getFormat(currencyNotifier.value);
    final convertedPrice = CurrencyUtils.convert(currentSub.price, currentSub.currency, currencyNotifier.value);
    final dateFormat = DateFormat('yyyy-MM-dd'); 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor; 
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    final yearlyCost = currentSub.billingCycle == 'Bulanan' || currentSub.billingCycle == 'Monthly' ? convertedPrice * 12 : convertedPrice;
    final monthlyCost = currentSub.billingCycle == 'Tahunan' || currentSub.billingCycle == 'Yearly' ? convertedPrice / 12 : convertedPrice;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         IconButton(
                           icon: Icon(Icons.close_rounded, color: textColor),
                           onPressed: () => Navigator.pop(context),
                         )
                       ]
                    ),
                    LogoWidget(name: currentSub.name, category: currentSub.category, customLogoPath: currentSub.customLogoPath, size: 80, borderRadius: 24),
                    const SizedBox(height: 16),
                    Text(currentSub.name, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(currentSub.category, style: TextStyle(color: subTextColor, fontSize: 15)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildCard(
                      cardBg: cardBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.payments_outlined, color: const Color(0xFF4F46E5), size: 20),
                              const SizedBox(width: 8),
                              Text(tr('Rincian biaya', 'Cost breakdown'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Biaya bulanan', 'Monthly cost'), currencyFormat.format(monthlyCost), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Biaya tahunan', 'Yearly cost'), currencyFormat.format(yearlyCost), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Kategori', 'Category'), currentSub.category, subTextColor, textColor, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (currentSub.isTrial) ...[
                      _buildCard(
                        cardBg: cardBg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_month_rounded, color: const Color(0xFFB45309), size: 20),
                                const SizedBox(width: 8),
                                Text(tr('Uji coba', 'Trial'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: dividerColor, height: 1),
                            const SizedBox(height: 16),
                            _buildInfoRow(tr('Status uji coba', 'Trial status'), currentSub.trialEndDate != null && currentSub.trialEndDate!.isBefore(DateTime.now()) ? tr('Uji coba berakhir', 'Trial ended') : tr('Aktif', 'Active'), subTextColor, textColor, isBold: true),
                            const SizedBox(height: 16),
                            if (currentSub.trialEndDate != null) _buildInfoRow(tr('Akhir masa percobaan', 'Trial end date'), dateFormat.format(currentSub.trialEndDate!), subTextColor, textColor, isBold: true),
                            const SizedBox(height: 16),
                            _buildInfoRow(tr('Harga reguler', 'Regular price'), currencyFormat.format(convertedPrice), subTextColor, textColor, isBold: true),
                            if (currentSub.trialPrice != null) ...[
                              const SizedBox(height: 16),
                              _buildInfoRow(tr('Trial price', 'Trial price'), currencyFormat.format(currentSub.trialPrice!), subTextColor, textColor, isBold: true),
                            ],
                            const SizedBox(height: 16),
                            Text(tr('SubTrack only tracks this locally. Confirm cancellation or billing changes with the provider.', 'SubTrack only tracks this locally. Confirm cancellation or billing changes with the provider.'), style: TextStyle(color: subTextColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildCard(
                      cardBg: cardBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_repeat_rounded, color: const Color(0xFFB45309), size: 20),
                              const SizedBox(width: 8),
                              Text(tr('Pembaruan', 'Renewal'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Status', 'Status'), currentSub.isFinished ? tr('Finished', 'Finished') : _getCountdownText(currentSub.dueDate), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Next renewal', 'Next renewal'), dateFormat.format(currentSub.dueDate), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Siklus Tagihan', 'Billing cycle'), currentSub.billingCycle, subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Metode Pembayaran', 'Payment handling'), currentSub.isAutoRenew ? tr('Perpanjang otomatis', 'Auto-renewing') : tr('Pembayaran manual', 'Manual payment'), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          Text(tr('SubTrack does not manage or move money. This only tells us to show renewal reminders before your bank, card, or provider charges you.', 'SubTrack does not manage or move money. This only tells us to show renewal reminders before your bank, card, or provider charges you.'), style: TextStyle(color: subTextColor, fontSize: 12)),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Harga Berlangganan', 'Recurring price'), currencyFormat.format(convertedPrice), subTextColor, textColor, isBold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCard(
                      cardBg: cardBg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.link_rounded, color: const Color(0xFF4F46E5), size: 20),
                              const SizedBox(width: 8),
                              Text(tr(tr('Tindakan & Pembatalan', 'Actions & Cancellation'), tr('Tindakan & Pembatalan', 'Actions & Cancellation')), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          if (currentSub.cancellationLink != null && currentSub.cancellationLink!.isNotEmpty) ...[
                            Text(tr('Cancel link', 'Cancel link'), style: TextStyle(color: subTextColor, fontSize: 12)),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                final url = Uri.parse(currentSub.cancellationLink!);
                                if (await canLaunchUrl(url)) await launchUrl(url);
                              },
                              child: Text(currentSub.cancellationLink!, style: const TextStyle(color: Color(0xFF2563EB), fontSize: 14, decoration: TextDecoration.underline)),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: dividerColor)),
                              icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF4F46E5)),
                              label: Text(tr(tr('Tambah ke Kalender', 'Add to Calendar'), tr('Tambah ke Kalender', 'Add to Calendar')), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              onPressed: _addToCalendar,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (currentSub.splitCount > 1) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: dividerColor)),
                                icon: const Icon(Icons.chat_rounded, size: 18, color: Color(0xFF10B981)),
                                label: Text(tr(tr('Bagi Tagihan via WhatsApp', 'Split Bill via WhatsApp'), tr('Bagi Tagihan via WhatsApp', 'Split Bill via WhatsApp')), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                onPressed: _tagihTeman,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: dividerColor)),
                              icon: const Icon(Icons.edit_document, size: 18, color: Color(0xFF4F46E5)),
                              label: Text(tr(tr('Edit Langganan', 'Edit Subscription'), tr('Edit Langganan', 'Edit Subscription')), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => EditScreen(sub: currentSub))).then((_) {
                                  final provider = context.read<SubProvider>();
                                  final updated = provider.subs.firstWhere((s) => s.id == currentSub.id, orElse: () => currentSub);
                                  if (mounted) setState(() => currentSub = updated);
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: dividerColor)),
                              icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.redAccent),
                              label: Text(tr('Batalkan langganan', 'Cancel subscription'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              onPressed: _deleteSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Color cardBg, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, Color subTextColor, Color textColor, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: subTextColor, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textColor, fontSize: 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}