import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/currency_utils.dart';
import 'dashboard_screen.dart' show tr, languageNotifier, themeNotifier;

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Konverter State
  String _convBase = 'USD';
  String _convTarget = 'IDR';
  final TextEditingController _baseCtrl = TextEditingController(text: '1.00');
  final TextEditingController _targetCtrl = TextEditingController();

  // Statistik State
  bool _isEditingBase = true;
  String _statBase = 'USD';
  String _statTarget = 'IDR';
  String _selectedRange = '1M';
  bool _isLoadingChart = false;
  Map<String, double> _historicalData = {};

  final List<String> _ranges = ['1D', '5D', '1M', '3M', '6M', '1Y'];

  Future<void> _fetchChartData() async {
    setState(() => _isLoadingChart = true);
    
    // Coba ambil data riil dari internet
    Map<String, double> realData = {};
    if (_statBase != _statTarget) {
      realData = await CurrencyUtils.fetchHistoricalRates(_statBase, _statTarget, _selectedRange);
    }
    
    _historicalData.clear();
    double currentRate = CurrencyUtils.convert(1, _statBase, _statTarget);
    
    if (realData.isNotEmpty && realData.length > 2) {
      // Gunakan data riil
      _historicalData = realData;
    } else {
      // Fallback: Simulasi data historis yang fluktuatif jika API gagal / offline
      await Future.delayed(const Duration(milliseconds: 500));
      int dataPoints = 30;
      if (_selectedRange == '1D') dataPoints = 24;
      else if (_selectedRange == '5D') dataPoints = 5;
      else if (_selectedRange == '3M') dataPoints = 90;
      else if (_selectedRange == '6M') dataPoints = 180;
      else if (_selectedRange == '1Y') dataPoints = 365;

      DateTime now = DateTime.now();
      double lastRate = currentRate * 0.95; 

      for (int i = dataPoints; i >= 0; i--) {
        DateTime d = now.subtract(Duration(days: i));
        if (_selectedRange == '1D') d = now.subtract(Duration(hours: i));
        
        // Random walk simulation
        double change = (DateTime.now().millisecond % 100 - 50) / 1000; 
        lastRate = lastRate * (1 + change);
        
        _historicalData[d.toIso8601String()] = lastRate;
      }
    }
    
    // Ensure the last data point matches the exact live rate
    _historicalData[DateTime.now().toIso8601String()] = currentRate;

    if (mounted) {
      setState(() => _isLoadingChart = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateConversion(true);
    _initData();
  }

  Future<void> _initData() async {
    await CurrencyUtils.fetchRealTimeRates();
    if (mounted) _fetchChartData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _baseCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  void _calculateConversion(bool fromBase) {
    double baseVal = double.tryParse(_baseCtrl.text.replaceAll(',', '')) ?? 0.0;
    double targetVal = double.tryParse(_targetCtrl.text.replaceAll(',', '')) ?? 0.0;

    if (fromBase) {
      double result = CurrencyUtils.convert(baseVal, _convBase, _convTarget);
      _targetCtrl.text = _formatInput(result, _convTarget);
    } else {
      double result = CurrencyUtils.convert(targetVal, _convTarget, _convBase);
      _baseCtrl.text = _formatInput(result, _convBase);
    }
  }
  
  String _formatInput(double value, String currency) {
    if (value == 0) return '0';
    if (currency == 'IDR') {
      final format = NumberFormat.decimalPattern('id');
      return format.format(value);
    }
    int decimals = (currency == 'JPY') ? 0 : 2;
    final format = NumberFormat.decimalPattern('en');
    format.minimumFractionDigits = 0;
    format.maximumFractionDigits = decimals;
    return format.format(value);
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Kalkulator Kurs', 'Exchange Rate'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: [
            Tab(text: tr('Konversi', 'Convert')),
            Tab(text: tr('Statistik', 'Statistics')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConverterTab(cardColor, textColor, isDark),
          _buildStatisticsTab(cardColor, textColor, isDark),
        ],
      ),
    );
  }

  Widget _buildConverterTab(Color cardColor, Color textColor, bool isDark) {
    double currentRate = CurrencyUtils.convert(1, _convBase, _convTarget);
    String rateFormatted = CurrencyUtils.getFormat(_convTarget).format(currentRate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          
          _buildCurrencyInputBox(
            label: tr('Dari', 'From'),
            currency: _convBase,
            controller: _baseCtrl,
            cardColor: cardColor,
            textColor: textColor,
            isEditing: _isEditingBase,
            onTap: () => setState(() => _isEditingBase = true),
            onCurrencyChanged: (val) {
              setState(() => _convBase = val!);
              _calculateConversion(true);
            },
            onChanged: (val) => _calculateConversion(true),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: InkWell(
              onTap: () {
                setState(() {
                  String tempC = _convBase;
                  _convBase = _convTarget;
                  _convTarget = tempC;
                  
                  String tempV = _baseCtrl.text;
                  _baseCtrl.text = _targetCtrl.text;
                  _targetCtrl.text = tempV;
                });
                _calculateConversion(true);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 28),
              ),
            ),
          ),

          _buildCurrencyInputBox(
            label: tr('Ke', 'To'),
            currency: _convTarget,
            controller: _targetCtrl,
            cardColor: cardColor,
            textColor: textColor,
            isEditing: !_isEditingBase,
            onTap: () => setState(() => _isEditingBase = false),
            onCurrencyChanged: (val) {
              setState(() => _convTarget = val!);
              _calculateConversion(false);
            },
            onChanged: (val) => _calculateConversion(false),
          ),
          
          const SizedBox(height: 32),
          _buildNumpad(cardColor, textColor),
        ],
      ),
    );
  }

  void _onNumpadTap(String value) {
    TextEditingController ctrl = _isEditingBase ? _baseCtrl : _targetCtrl;
    
    String raw = ctrl.text.replaceAll(',', '');
    
    if (value == 'C') {
      raw = '0';
    } else if (value == '<') {
      if (raw.isNotEmpty) {
        raw = raw.substring(0, raw.length - 1);
      }
    } else {
      if (value == '.' && raw.contains('.')) return;
      if (raw == '0' && value != '.') raw = '';
      raw += value;
    }
    
    if (raw.isEmpty) raw = '0';
    
    List<String> parts = raw.split('.');
    String intPart = parts[0];
    if (intPart.isNotEmpty && intPart != '-') {
       intPart = NumberFormat.decimalPattern('en').format(int.parse(intPart));
    }
    ctrl.text = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    
    _calculateConversion(_isEditingBase);
  }

  Widget _buildNumpad(Color cardColor, Color textColor) {
    final List<String> buttons = [
      '7', '8', '9',
      '4', '5', '6',
      '1', '2', '3',
      '.', '0', '<',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: buttons.length,
        itemBuilder: (context, index) {
          String btn = buttons[index];
          bool isAction = btn == '<';
          return InkWell(
            onTap: () => _onNumpadTap(btn),
            onLongPress: isAction ? () => _onNumpadTap('C') : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isAction ? const Color(0xFFEF4444).withOpacity(0.1) : textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: btn == '<' 
                  ? Icon(Icons.backspace_rounded, color: isAction ? const Color(0xFFEF4444) : textColor)
                  : Text(btn, style: TextStyle(color: isAction ? const Color(0xFFEF4444) : textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyInputBox({
    required String label,
    required String currency,
    required TextEditingController controller,
    required Color cardColor,
    required Color textColor,
    required bool isEditing,
    required VoidCallback onTap,
    required ValueChanged<String?> onCurrencyChanged,
    required ValueChanged<String> onChanged,
  }) {
    final currencyData = CurrencyUtils.data[currency];
    final flag = currencyData?['flag'] ?? '';
    final name = currencyData?['name'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currency,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
                    dropdownColor: cardColor,
                    items: CurrencyUtils.data.keys.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Text(CurrencyUtils.data[c]!['flag'], style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(c, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: onCurrencyChanged,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  showCursor: isEditing,
                  onTap: onTap,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isEditing ? const Color(0xFF2563EB) : textColor, 
                    fontSize: 24, 
                    fontWeight: FontWeight.w900
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    prefixText: CurrencyUtils.getFormat(currency).currencySymbol + ' ',
                    prefixStyle: TextStyle(color: textColor.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }


  Widget _buildStatisticsTab(Color cardColor, Color textColor, bool isDark) {
    final chartColor = const Color(0xFF3B82F6);
    
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          tr('Statistik Kurs', 'Exchange Stats'),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tr('Pilih negara di bawah ini untuk melihat tren pergerakan nilai tukar mata uangnya dibandingkan USD.', 
             'Select a country below to see its exchange rate trend compared to USD.'),
          style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: CurrencyUtils.data.length,
            itemBuilder: (context, index) {
              String c = CurrencyUtils.data.keys.elementAt(index);
              if (c == _statBase) return const SizedBox.shrink();
              bool isSelected = c == _statTarget;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _statTarget = c;
                    _fetchChartData();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : textColor.withOpacity(0.1)),
                    boxShadow: [
                      if (isSelected) BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(CurrencyUtils.data[c]!['flag'], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        c, 
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _ranges.map((r) {
            bool isSelected = r == _selectedRange;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRange = r;
                  _fetchChartData();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? chartColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textColor.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        if (!_isLoadingChart && _historicalData.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('Nilai Saat Ini', 'Current Rate'),
                      style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 $_statBase = ${CurrencyUtils.getFormat(_statTarget).format(_historicalData.values.last)}',
                      style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
        SizedBox(
          height: 250,
          child: _isLoadingChart 
              ? const Center(child: CircularProgressIndicator())
              : _buildChart(chartColor, isDark),
        ),
        
        if (!_isLoadingChart && _historicalData.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 4),
                          Text(tr('Tertinggi', 'Highest'), style: TextStyle(color: const Color(0xFF10B981).withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(CurrencyUtils.getFormat(_statTarget).format(_historicalData.values.reduce((a, b) => a > b ? a : b)), style: const TextStyle(color: Color(0xFF10B981), fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trending_down_rounded, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 4),
                          Text(tr('Terendah', 'Lowest'), style: TextStyle(color: const Color(0xFFEF4444).withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(CurrencyUtils.getFormat(_statTarget).format(_historicalData.values.reduce((a, b) => a < b ? a : b)), style: const TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildChart(Color baseColor, bool isDark) {
    List<FlSpot> spots = [];
    double minX = 0;
    double maxX = (_historicalData.length - 1).toDouble();
    if (maxX < 0) maxX = 0;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    int i = 0;
    _historicalData.forEach((date, rate) {
      spots.add(FlSpot(i.toDouble(), rate));
      if (rate < minY) minY = rate;
      if (rate > maxY) maxY = rate;
      i++;
    });

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;
    
    // Determine color based on trend (up = green, down = red)
    Color chartColor = const Color(0xFF10B981); // Default green
    if (spots.isNotEmpty && spots.last.y < spots.first.y) {
      chartColor = const Color(0xFFEF4444); // Red if down
    }
    
    // Add padding to Y axis
    double yPadding = (maxY - minY) * 0.1;
    if (yPadding == 0) yPadding = minY * 0.01;
    minY -= yPadding;
    maxY += yPadding;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(4),
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: chartColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  chartColor.withOpacity(0.3),
                  chartColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 500),
    );
  }
}
