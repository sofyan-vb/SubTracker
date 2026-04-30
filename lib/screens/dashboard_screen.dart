// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_tile.dart';
import 'add_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Consumer<SubProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Urutkan Berdasarkan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSortTile(context, provider, 'Terdekat', Icons.calendar_today),
                  _buildSortTile(context, provider, 'Termahal', Icons.arrow_upward),
                  _buildSortTile(context, provider, 'Termurah', Icons.arrow_downward),
                  _buildSortTile(context, provider, 'A-Z', Icons.sort_by_alpha),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildSortTile(BuildContext context, SubProvider provider, String title, IconData icon) {
    final isActive = provider.sortBy == title;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isActive ? const Color(0xFFD4FF00) : Colors.white54),
      title: Text(title, style: TextStyle(color: isActive ? const Color(0xFFD4FF00) : Colors.white, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      trailing: isActive ? const Icon(Icons.check_circle, color: Color(0xFFD4FF00)) : null,
      onTap: () {
        provider.setSortBy(title);
        Navigator.pop(context); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: 'Cari langganan...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  context.read<SubProvider>().setSearchQuery(val); 
                },
              )
            : const Text(
                'SubTracker',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchCtrl.clear();
                  context.read<SubProvider>().setSearchQuery(''); 
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () => _showFilterSheet(context),
            ),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeView(),
          _StatsView(), 
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          elevation: 0, 
          hoverElevation: 0,
          highlightElevation: 0,
          backgroundColor: const Color(0xFFD4FF00), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.add, size: 32, color: Colors.black), 
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScreen()));
          },
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF121214), 
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
            const SizedBox(width: 50), 
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
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: const Color(0xFFD4FF00), borderRadius: BorderRadius.circular(24)),
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
            child: provider.subs.isEmpty
                // EMOJI SUDAH DIHAPUS DI SINI
                ? const Center(
                    child: Text(
                      'Tidak ada catatan', 
                      style: TextStyle(color: Colors.white30, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
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

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalMonthly = provider.totalMonthly;
    final breakdown = provider.categoryBreakdown;
    final activeSubs = provider.subs;

    final double averagePrice = activeSubs.isEmpty ? 0 : (totalMonthly / activeSubs.length);

    String mostExpensiveText = '-';
    if (activeSubs.isNotEmpty) {
      final mostExpensive = activeSubs.reduce((curr, next) => curr.price > next.price ? curr : next);
      mostExpensiveText = mostExpensive.name;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ringkasan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Tahunan', currencyFormat.format(provider.totalYearly), Icons.all_inclusive, Colors.purpleAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Layanan', '${activeSubs.length} Aktif', Icons.subscriptions_rounded, Colors.cyanAccent)),
              ],
            ),
            const SizedBox(height: 16), 

            Row(
              children: [
                Expanded(child: _buildSummaryCard('Rata-rata /Bulan', currencyFormat.format(averagePrice), Icons.analytics_outlined, Colors.orangeAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Termahal', mostExpensiveText, Icons.diamond_outlined, Colors.pinkAccent)),
              ],
            ),
            
            const SizedBox(height: 40),
            const Text('Analisis Kategori', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            if (breakdown.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Text('Belum ada data pengeluaran.', style: TextStyle(color: Colors.white54))),
              ),

            ...breakdown.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percentage = totalMonthly > 0 ? (amount / totalMonthly) : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(currencyFormat.format(amount), style: const TextStyle(color: Color(0xFFD4FF00), fontWeight: FontWeight.w900, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: const Color(0xFFD4FF00),
                        minHeight: 12, 
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('${(percentage * 100).toStringAsFixed(1)}% dari total', style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF121214), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}