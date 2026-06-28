import 'package:flutter/material.dart';
import '../utils/currency_utils.dart';
import '../screens/dashboard_screen.dart' show tr;

class CurrencyConverterSheet extends StatefulWidget {
  final Color bgColor;
  final Color textColor;
  
  const CurrencyConverterSheet({super.key, required this.bgColor, required this.textColor});

  @override
  State<CurrencyConverterSheet> createState() => _CurrencyConverterSheetState();
}

class _CurrencyConverterSheetState extends State<CurrencyConverterSheet> {
  String _selectedBaseCurrency = 'USD';
  final TextEditingController _amountController = TextEditingController(text: '100');
  double _baseAmount = 100.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {
        _baseAmount = double.tryParse(_amountController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.currency_exchange_rounded, color: Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(tr('Kalkulator Kurs', 'Exchange Calculator', 'Calculadora de cambio'), style: TextStyle(color: widget.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBaseCurrency,
                      dropdownColor: widget.bgColor,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.textColor),
                      items: CurrencyUtils.data.keys.map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text('$code', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBaseCurrency = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: widget.textColor, fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(tr('Hasil Konversi', 'Conversion Result', 'Resultado de la conversión'), style: TextStyle(color: widget.textColor.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 250,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: CurrencyUtils.data.keys.length,
              itemBuilder: (context, index) {
                final targetCurrency = CurrencyUtils.data.keys.elementAt(index);
                if (targetCurrency == _selectedBaseCurrency) return const SizedBox.shrink();
                
                final convertedAmount = CurrencyUtils.convert(_baseAmount, _selectedBaseCurrency, targetCurrency);
                final format = CurrencyUtils.getFormat(targetCurrency);
                final name = CurrencyUtils.data[targetCurrency]!['name'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Text(targetCurrency, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Text(name, style: TextStyle(color: widget.textColor.withOpacity(0.7), fontSize: 14)),
                        ],
                      ),
                      Text(format.format(convertedAmount), style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
