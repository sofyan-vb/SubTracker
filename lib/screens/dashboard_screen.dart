import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import '../widgets/add_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        title: const Text(
          'SubTracker', // Judul diubah sesuai permintaan
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          const _HomeView(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: 80, color: const Color(0xFFD4FF00).withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Halaman Statistik\n(Segera Hadir)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      
      // Tombol Tambah di tengah (Tanpa bayangan)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          elevation: 0, // 100% Hilangkan bayangan
          hoverElevation: 0,
          highlightElevation: 0,
          backgroundColor: const Color(0xFFD4FF00), // Warna Neon Lime yang berani
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, size: 32, color: Colors.black), // Ikon hitam agar kontras
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddSubBottomSheet(),
            );
          },
        ),
      ),

      // Bottom Navigation yang elegan
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF121214), // Sedikit lebih terang dari background
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MaterialButton(
              minWidth: 50,
              onPressed: () => setState(() => _currentIndex = 0),
              child: Icon(Icons.dashboard_rounded, color: _currentIndex == 0 ? const Color(0xFFD4FF00) : Colors.grey[700], size: 28),
            ),
            const SizedBox(width: 50), // Ruang untuk FAB
            MaterialButton(
              minWidth: 50,
              onPressed: () => setState(() => _currentIndex = 1),
              child: Icon(Icons.insert_chart_rounded, color: _currentIndex == 1 ? const Color(0xFFD4FF00) : Colors.grey[700], size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen Halaman Beranda
class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HERO CARD (High Contrast - Flat Design Tanpa Bayangan)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFD4FF00), // Solid Neon Lime (Sangat kontras dan modern)
              borderRadius: BorderRadius.circular(24),
              // BOX SHADOW DIHAPUS TOTAL
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Total Tagihan Bulanan', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  currencyFormat.format(provider.totalMonthly),
                  style: const TextStyle(color: Colors.black, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Layanan Aktif', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(20)),
                  child: Text('${provider.subs.length} Total', style: const TextStyle(color: Color(0xFFD4FF00), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80), 
              physics: const BouncingScrollPhysics(),
              itemCount: provider.subs.length,
              itemBuilder: (context, index) {
                return SubTile(sub: provider.subs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}