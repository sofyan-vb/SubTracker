import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import '../widgets/add_bottom_sheet.dart';

// 1. UBAH MENJADI STATEFUL WIDGET UNTUK BOTTOM NAVIGATION
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // State untuk melacak tab aktif

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. APPBAR MENGIKUTI VIDEO (Ada Search & Filter)
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: const Text(
          'Langgananku', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70),
            onPressed: () {
              // TODO: Implementasi fitur pencarian
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Pencarian')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white70),
            onPressed: () {
              // TODO: Implementasi fitur urutkan/filter
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Filter & Urutkan')));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // 3. BODY MENGGUNAKAN INDEXED STACK (Agar bisa ganti halaman)
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Index 0: Halaman Daftar Langganan (Home)
          const _HomeView(),
          
          // Index 1: Halaman Statistik (Chart)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart, size: 80, color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Halaman Statistik\n(Segera Hadir)', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
      
      // 4. FLOATING ACTION BUTTON DI TENGAH (Sesuai gaya modern)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30), // Mengangkat tombol sedikit
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: const Color(0xFF10B981),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
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

      // 5. BOTTOM NAVIGATION BAR CUSTOM
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF151A26),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Tombol Home
            MaterialButton(
              minWidth: 40,
              onPressed: () => setState(() => _currentIndex = 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_filled, color: _currentIndex == 0 ? const Color(0xFF8B5CF6) : Colors.grey),
                  Text('Beranda', style: TextStyle(color: _currentIndex == 0 ? const Color(0xFF8B5CF6) : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(width: 48), // Ruang kosong untuk FAB di tengah
            
            // Tombol Statistik
            MaterialButton(
              minWidth: 40,
              onPressed: () => setState(() => _currentIndex = 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart_rounded, color: _currentIndex == 1 ? const Color(0xFF8B5CF6) : Colors.grey),
                  Text('Statistik', style: TextStyle(color: _currentIndex == 1 ? const Color(0xFF8B5CF6) : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// WIDGET KHUSUS UNTUK HALAMAN BERANDA (Merapikan kode)
// =========================================================
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
          // HERO CARD (Total Pengeluaran)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFFD946EF)], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD946EF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Total Tagihan Bulan Ini', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  currencyFormat.format(provider.totalMonthly),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          // JUDUL DAFTAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Aktivitas Berlangganan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${provider.subs.length} Layanan', style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // DAFTAR LANGGANAN
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 80), // Padding bawah agar tidak tertutup BottomNav
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