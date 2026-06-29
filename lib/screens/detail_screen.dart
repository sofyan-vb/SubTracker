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
    if (currentSub.isFinished) return tr('PEMBAYARAN SUDAH SELESAI', 'PAYMENT COMPLETED', 'PAGO COMPLETADO');
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return tr('SEKARANG WAKTUNYA BAYAR!', 'PAYMENT DUE NOW!', '¡PAGO AHORA!');
    
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return tr('Tinggal $days Hari $hours Jam $minutes Menit $seconds Detik', '$days Days $hours Hrs $minutes Mins $seconds Secs Left', '$days Días $hours Horas $minutes Minutos $seconds Segundos restantes');
    if (hours > 0) return tr('Tinggal $hours Jam $minutes Menit $seconds Detik', '$hours Hrs $minutes Mins $seconds Secs Left', '$hours Horas $minutes Minutos $seconds Segundos restantes');
    return tr('Tinggal $minutes Menit $seconds Detik', '$minutes Mins $seconds Secs Left', '$minutes Minutos $seconds Segundos restantes');
  }

  void _deleteSub() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Hapus Catatan?', 'Delete Record?', '¿Eliminar registro?'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Text(tr('Apakah kamu yakin? Catatan yang dihapus tidak bisa dikembalikan.', 'Are you sure? Deleted records cannot be recovered.', '¿Está seguro? Los registros eliminados no se pueden recuperar.'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel', 'Cancelar'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)))),
          TextButton(
            onPressed: () {
              context.read<SubProvider>().deleteSub(currentSub.id);
              ToastUtils.show(context, tr('Layanan berhasil dihapus dari daftar', 'Service deleted from the list', 'Servicio eliminado de la lista'));
              Navigator.pop(ctx); 
              Navigator.pop(context); 
            }, 
            child: Text(tr('Hapus', 'Delete', 'Borrar'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
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
          ListTile(leading: const Icon(Icons.update, color: Color(0xFF2563EB)), title: Text(tr('Perpanjang Langganan', 'Renew Subscription', 'Renovar suscripción'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _showRenewInput(); }),
          ListTile(leading: Icon(Icons.task_alt, color: isDark ? Colors.white : const Color(0xFF1E293B)), title: Text(tr('Tandai Sudah Selesai', 'Mark as Completed', 'Marcar como completado'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)), onTap: () { Navigator.pop(ctx); _markAsFinished(); }),
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
    ToastUtils.show(context, tr('Layanan ditandai selesai dan dipindahkan ke Riwayat', 'Service marked as finished and moved to History', 'Servicio marcado como finalizado y movido al Historial'));
  }

  void _showRenewInput() {
    _monthCtrl.clear(); 
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true, backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(tr('Perpanjang Langganan', 'Renew Subscription', 'Renovar suscripción'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('Berapa bulan kamu ingin memperpanjang?', 'How many months to renew?', '¿Cuántos meses para renovar?'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
            const SizedBox(height: 16),
            TextField(
              controller: _monthCtrl, autofocus: true, keyboardType: TextInputType.number, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: '1', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26), suffixText: tr('Bulan', 'Month(s)', 'Meses)'), suffixStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14), filled: true, fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Batal', 'Cancel', 'Cancelar'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54))),
          TextButton(
            onPressed: () {
              final int? m = int.tryParse(_monthCtrl.text);
              if (m != null && m > 0) { Navigator.pop(ctx); _processAutoRenewal(); } 
              else { ToastUtils.show(context, tr('Masukkan angka valid', 'Enter valid number', 'Introduce un número válido'), icon: Icons.error_outline, iconColor: Colors.redAccent); }
            }, 
            child: Text(tr('Simpan', 'Save', 'Ahorrar'), style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  void _processAutoRenewal() {
    final provider = context.read<SubProvider>();
    DateTime newDate;
    String cycle = currentSub.billingCycle;
    
    if (cycle == 'Tahunan' || cycle == 'Yearly') {
      newDate = DateTime(currentSub.dueDate.year + 1, currentSub.dueDate.month, currentSub.dueDate.day, currentSub.dueDate.hour, currentSub.dueDate.minute);
    } else if (cycle == 'Mingguan' || cycle == 'Weekly') {
      newDate = currentSub.dueDate.add(const Duration(days: 7));
    } else if (cycle == 'Harian' || cycle == 'Daily') {
      newDate = currentSub.dueDate.add(const Duration(days: 1));
    } else {
      newDate = DateTime(currentSub.dueDate.year, currentSub.dueDate.month + 1, currentSub.dueDate.day, currentSub.dueDate.hour, currentSub.dueDate.minute);
    }
    
    final newHistory = List<DateTime>.from(currentSub.paymentHistory);
    newHistory.add(DateTime.now());

    final updatedSub = currentSub.copyWith(dueDate: newDate, isFinished: false, paymentHistory: newHistory);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Layanan berhasil diperpanjang', 'Service successfully renewed', 'Servicio renovado exitosamente'));
  }

  void _cancelSubscription() {
    final provider = context.read<SubProvider>();
    final updatedSub = currentSub.copyWith(isFinished: true);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Layanan ditandai selesai dan dipindahkan ke Riwayat', 'Service marked as finished and moved to History', 'Servicio marcado como finalizado y movido al Historial'));
    Navigator.pop(context); 
  }

  void _useServiceToday() {
    final provider = context.read<SubProvider>();
    final updatedSub = currentSub.copyWith(usageCount: currentSub.usageCount + 1);
    provider.removeSub(currentSub.id); provider.addSub(updatedSub);
    setState(() { currentSub = updatedSub; });
    ToastUtils.show(context, tr('Berhasil dicatat', 'Recorded successfully', 'Grabado con éxito'));
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
      ToastUtils.show(context, tr('Gagal membuka WhatsApp', 'Failed to open WhatsApp', 'No se pudo abrir WhatsApp'));
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
                    LogoWidget(name: currentSub.name, category: currentSub.category, customLogoPath: currentSub.customLogoPath, size: 80, borderRadius: 0, showBackground: false),
                    const SizedBox(height: 16),
                    Text(currentSub.name, style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CategoryUtils.getIcon(currentSub.category), size: 15, color: subTextColor),
                        const SizedBox(width: 6),
                        Text(currentSub.category, style: TextStyle(color: subTextColor, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Builder(
                builder: (context) {
                  if (currentSub.isFinished) return const SizedBox.shrink();
                  
                  final now = DateTime.now();
                  final notifDate = currentSub.dueDate.subtract(const Duration(days: 3));
                  final isNotifArrived = now.isAfter(notifDate) || now.isAtSameMomentAs(notifDate);
                  
                  if (isNotifArrived) {
                    return const SizedBox.shrink();
                  } else {
                    final diffToNotif = notifDate.difference(now);
                    final d = diffToNotif.inDays;
                    final h = diffToNotif.inHours % 24;
                    final m = diffToNotif.inMinutes % 60;
                    final s = diffToNotif.inSeconds % 60;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                      child: Text(
                        tr('Notifikasi tagihan akan muncul dalam:\n$d Hari $h Jam $m Menit $s Detik', 'Billing notification will appear in:\n$d Days $h Hrs $m Mins $s Secs', 'La notificación de facturación aparecerá en:\n$d Días $h Horas $m Minutos $s Segundos'),
                        style: TextStyle(color: subTextColor, fontWeight: FontWeight.w600, fontSize: 13, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                }
              ),
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
                              Text(tr('Rincian biaya', 'Cost breakdown', 'Desglose de costos'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Biaya bulanan', 'Monthly cost', 'Costo mensual'), currencyFormat.format(monthlyCost), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Biaya tahunan', 'Yearly cost', 'Costo anual'), currencyFormat.format(yearlyCost), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Kategori', 'Category', 'Categoría'), currentSub.category, subTextColor, textColor, isBold: true),
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
                                Text(tr('Uji coba', 'Trial', 'Ensayo'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: dividerColor, height: 1),
                            const SizedBox(height: 16),
                            _buildInfoRow(tr('Status uji coba', 'Trial status', 'Estado del juicio'), currentSub.trialEndDate != null && currentSub.trialEndDate!.isBefore(DateTime.now()) ? tr('Uji coba berakhir', 'Trial ended', 'Prueba finalizada') : tr('Aktif', 'Active', 'Activo'), subTextColor, textColor, isBold: true),
                            const SizedBox(height: 16),
                            if (currentSub.trialEndDate != null) _buildInfoRow(tr('Akhir masa percobaan', 'Trial end date', 'Fecha de finalización del juicio'), dateFormat.format(currentSub.trialEndDate!), subTextColor, textColor, isBold: true),
                            const SizedBox(height: 16),
                            _buildInfoRow(tr('Harga reguler', 'Regular price', 'Precio habitual'), currencyFormat.format(convertedPrice), subTextColor, textColor, isBold: true),
                            if (currentSub.trialPrice != null) ...[
                              const SizedBox(height: 16),
                              _buildInfoRow(tr('Harga uji coba', 'Trial price', 'Precio de prueba'), currencyFormat.format(currentSub.trialPrice!), subTextColor, textColor, isBold: true),
                            ],
                            const SizedBox(height: 16),
                            Text(tr('SubTrack hanya melacak secara lokal. Konfirmasikan pembatalan atau perubahan tagihan dengan penyedia.', 'SubTrack only tracks this locally. Confirm cancellation or billing changes with the provider.', 'SubTrack solo rastrea esto localmente. Confirmar cancelación o cambios de facturación con el proveedor.'), style: TextStyle(color: subTextColor, fontSize: 12)),
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
                              Text(tr('Pembaruan', 'Renewal', 'Renovación'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Status', 'Status', 'Estado'), currentSub.isFinished ? tr('Selesai', 'Finished', 'Finalizado') : _getCountdownText(currentSub.dueDate), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Perpanjangan berikutnya', 'Next renewal', 'Próxima renovación'), dateFormat.format(currentSub.dueDate), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Siklus Tagihan', 'Billing cycle', 'ciclo de facturación'), currentSub.billingCycle, subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Metode Pembayaran', 'Payment handling', 'Manejo de pagos'), currentSub.isAutoRenew ? tr('Perpanjang otomatis', 'Auto-renewing', 'Renovación automática') : tr('Pembayaran manual', 'Manual payment', 'Pago manual'), subTextColor, textColor, isBold: true),
                          const SizedBox(height: 16),
                          Text(tr('Aplikasi tidak mengelola uang Anda. Ini hanya pengingat perpanjangan agar Anda bisa mengecek tagihan dari bank/penyedia Anda.', 'SubTrack does not manage or move money. This only tells us to show renewal reminders before your bank, card, or provider charges you.', 'SubTrack no administra ni mueve dinero. Esto solo nos indica que mostremos recordatorios de renovación antes de que su banco, tarjeta o proveedor le cobre.'), style: TextStyle(color: subTextColor, fontSize: 12)),
                          const SizedBox(height: 16),
                          _buildInfoRow(tr('Harga Berlangganan', 'Recurring price', 'Precio recurrente'), currencyFormat.format(convertedPrice), subTextColor, textColor, isBold: true),
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
                              Text(tr('Tindakan & Pembatalan', 'Actions & Cancellation', 'Acciones y Cancelación'), style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: dividerColor, height: 1),
                          const SizedBox(height: 16),
                          if (currentSub.cancellationLink != null && currentSub.cancellationLink!.isNotEmpty) ...[
                            Text(tr('Tautan pembatalan', 'Cancel link', 'Cancelar enlace'), style: TextStyle(color: subTextColor, fontSize: 12)),
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
                              icon: const Icon(Icons.edit_document, size: 18, color: Color(0xFF4F46E5)),
                              label: Text(tr('Edit Langganan', 'Edit Subscription', 'Editar suscripción'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                          Builder(
                            builder: (context) {
                              final now = DateTime.now();
                              final notifDate = currentSub.dueDate.subtract(const Duration(days: 3));
                              final isNotifArrived = now.isAfter(notifDate) || now.isAtSameMomentAs(notifDate);
                              final showActionButtons = isNotifArrived && !currentSub.isFinished;
                              
                              if (showActionButtons) {
                                // Saat notifikasi udah muncul: tampilkan 2 tombol (Tandai Selesai, Perpanjang)
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          backgroundColor: const Color(0xFF10B981),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        icon: const Icon(Icons.task_alt_rounded, size: 18),
                                        label: Text(tr('Tandai Selesai', 'Mark as Finished', 'Marcar como terminado'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: _cancelSubscription,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          backgroundColor: const Color(0xFF2563EB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                        icon: const Icon(Icons.autorenew_rounded, size: 18),
                                        label: Text(tr('Perpanjang Layanan', 'Renew Service', 'Renovar Servicio'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        onPressed: _processAutoRenewal,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                // Waktu mundur belum sampai / notifikasi belum muncul: tombol hapus biasa
                                return SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: BorderSide(color: dividerColor)),
                                    icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.redAccent),
                                    label: Text(tr('Hapus Langganan', 'Delete Subscription', 'Eliminar suscripción'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                    onPressed: _deleteSub,
                                  ),
                                );
                              }
                            },
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