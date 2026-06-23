import 'package:home_widget/home_widget.dart';
import '../models/subscription.dart';

class WidgetService {
  static const String androidWidgetName = 'SubWidgetProvider';

  static Future<void> updateWidget(List<Subscription> subs) async {
    try {
      final activeSubs = subs.where((s) => !s.isFinished && !s.isPaused).toList();
      activeSubs.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      if (activeSubs.isNotEmpty) {
        final nearest = activeSubs.first;
        await HomeWidget.saveWidgetData<String>('title', 'Tagihan Terdekat');
        await HomeWidget.saveWidgetData<String>('sub_name', nearest.name);
        await HomeWidget.saveWidgetData<String>('sub_price', 'Rp ${nearest.price.toInt()}');
        final diff = nearest.dueDate.difference(DateTime.now()).inDays;
        await HomeWidget.saveWidgetData<String>('sub_due', diff < 0 ? 'Hari ini!' : 'H-$diff');
      } else {
        await HomeWidget.saveWidgetData<String>('title', 'Tidak ada tagihan');
        await HomeWidget.saveWidgetData<String>('sub_name', '-');
        await HomeWidget.saveWidgetData<String>('sub_price', '');
        await HomeWidget.saveWidgetData<String>('sub_due', '');
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
      );
    } catch (_) {}
  }
}
