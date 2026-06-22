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
  String _statBase = 'USD';
  String _statTarget = 'IDR';
  String _selectedRange = '1M';
  Map<String, double> _historicalData = {};
  bool _isLoadingChart = false;
  
  final List<String> _ranges = ['1D', '5D', '1M', '1Y', '5Y', 'Max'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _calculateConversion(true);
    _fetchChartData();
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
    if (value == 0) return '';
    int decimals = (currency == 'IDR' || currency == 'JPY') ? 0 : 4;
    return value.toStringAsFixed(decimals);
  }

  Future<void> _fetchChartData() async {
    setState(() => _isLoadingChart = true);
    final data = await CurrencyUtils.fetchHistoricalRates(_statBase, _statTarget, _selectedRange);
    setState(() {
      _historicalData = data;
      _isLoadingChart = false;
    });
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
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('Kalkulator Kurs', 'Exchange Rate'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: textColor.withOpacity(0.5),
          indicatorColor: const Color(0xFF2563EB),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '1 $_convBase = $rateFormatted\nData realtime dari Frankfurter API.',
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildCurrencyInputBox(
            label: tr('Dari', 'From'),
            currency: _convBase,
            controller: _baseCtrl,
            cardColor: cardColor,
            textColor: textColor,
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
                  boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
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
            onCurrencyChanged: (val) {
              setState(() => _convTarget = val!);
              _calculateConversion(false);
            },
            onChanged: (val) => _calculateConversion(false),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInputBox({
    required String label,
    required String currency,
    required TextEditingController controller,
    required Color cardColor,
    required Color textColor,
    required ValueChanged<String?> onCurrencyChanged,
    required ValueChanged<String> onChanged,
  }) {
    final currencyData = CurrencyUtils.data[currency];
    final flag = currencyData?['flag'] ?? '';
    final name = currencyData?['name'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
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
                            Text(CurrencyUtils.data[c]!['flag'], style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(c, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
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
    double currentRate = CurrencyUtils.convert(1, _statBase, _statTarget);
    String rateFormatted = CurrencyUtils.getFormat(_statTarget).format(currentRate);
    
    // Determine trend (green or red)
    bool isTrendUp = true;
    if (_historicalData.isNotEmpty) {
      final firstVal = _historicalData.values.first;
      final lastVal = _historicalData.values.last;
      isTrendUp = lastVal >= firstVal;
    }
    final chartColor = isTrendUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCurrencySelector(
                currency: _statBase, 
                cardColor: cardColor, 
                textColor: textColor,
                onChanged: (val) {
                  setState(() => _statBase = val!);
                  _fetchChartData();
                }
              ),
              Icon(Icons.swap_horiz_rounded, color: textColor.withOpacity(0.5)),
              _buildStatCurrencySelector(
                currency: _statTarget, 
                cardColor: cardColor, 
                textColor: textColor,
                onChanged: (val) {
                  setState(() => _statTarget = val!);
                  _fetchChartData();
                }
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Text('1 $_statBase =', style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rateFormatted, style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(_statTarget, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Range Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _ranges.map((range) {
                bool isSelected = _selectedRange == range;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedRange = range);
                    _fetchChartData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF2563EB) : textColor.withOpacity(0.1)),
                    ),
                    child: Text(
                      range, 
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2563EB) : textColor.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 40),

          // Chart Area
          SizedBox(
            height: 280,
            width: double.infinity,
            child: _isLoadingChart 
              ? const Center(child: CircularProgressIndicator())
              : _historicalData.isEmpty 
                ? Center(child: Text('Data tidak tersedia', style: TextStyle(color: textColor.withOpacity(0.5))))
                : _buildChart(chartColor, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCurrencySelector({required String currency, required Color cardColor, required Color textColor, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                  Text(CurrencyUtils.data[c]!['flag'], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(c, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChart(Color chartColor, bool isDark) {
    List<FlSpot> spots = [];
    double minX = 0;
    double maxX = (_historicalData.length - 1).toDouble();
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
    
    // Add padding to Y axis
    double yPadding = (maxY - minY) * 0.1;
    if (yPadding == 0) yPadding = minY * 0.01;
    minY -= yPadding;
    maxY += yPadding;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
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
