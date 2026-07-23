// ==========================================
// main.dart
// ==========================================
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'config.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadSavedData();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins',
      visualDensity: VisualDensity.compact,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    ),
    home: const VolumeEstimator(),
  ));
}

class VolumeEstimator extends StatefulWidget {
  const VolumeEstimator({super.key});
  @override
  State<VolumeEstimator> createState() => _VolumeEstimatorState();
}

class _VolumeEstimatorState extends State<VolumeEstimator> {
  final _formKey = GlobalKey<FormState>();
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _hgtCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  Map<String, double>? _results;
  final _currencyFormat = NumberFormat("#,##0.00", "en_US");
  bool _isButtonPressed = false;
  
  bool _isMetric = true;

  @override
  void dispose() {
    _lenCtrl.dispose();
    _widCtrl.dispose();
    _hgtCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard!"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareQuote() {
    if (_results == null) return;

    final unitLabel = _isMetric ? 'mm' : 'in';
    final reportText = """
=== Castculator Manufacturing Quote ===
Total Production Cost: \$${_currencyFormat.format(_results!['grandTotal']!)}
Dimensions: ${_results!['len']} x ${_results!['wid']} x ${_results!['hgt']} $unitLabel
Quantity Ordered: ${_results!['qty']?.toInt()} units
Total Molds Needed: ${_results!['molds']?.toInt()}

[Silicone Details]
Material Cost: \$${_currencyFormat.format(_results!['sMat']!)}
Labor Cost: \$${_currencyFormat.format(_results!['sLab']!)}
Subtotal: \$${_currencyFormat.format(_results!['sTot']!)}

[Urethane Details]
Material Cost: \$${_currencyFormat.format(_results!['uMat']!)}
Labor Cost: \$${_currencyFormat.format(_results!['uLab']!)}
Subtotal: \$${_currencyFormat.format(_results!['uTot']!)}
""";

    Share.share(reportText, subject: 'Castculator Production Quote');
  }

  void _showHistory() {
    final isDark = AppConfig.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF070B14) : Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Calculation History", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16)),
              if (AppConfig.historyList.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await AppConfig.clearHistory();
                    setDialogState(() {});
                    setState(() {});
                  },
                  child: const Text("CLEAR", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: AppConfig.historyList.isEmpty
                ? Center(
                    child: Text("No history recorded yet.", style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
                  )
                : ListView.builder(
                    itemCount: AppConfig.historyList.length,
                    itemBuilder: (context, index) {
                      final item = AppConfig.historyList[index];
                      final unit = item.isMetric ? 'mm' : 'in';
                      final priceStr = "\$${_currencyFormat.format(item.totalCost)}";
                      return Card(
                        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          dense: true,
                          title: Text("${item.length} x ${item.width} x ${item.height} $unit | Qty: ${item.quantity}",
                              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold)),
                          subtitle: Text(item.timestamp, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 10)),
                          trailing: Text(priceStr, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          onTap: () => _copyToClipboard(priceStr, "Price"),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE", style: TextStyle(color: Colors.blueAccent)),
            )
          ],
        ),
      ),
    );
  }

  void _showAbout() {
    final isDark = AppConfig.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF070B14) : Colors.white,
          title: Text("About Us", style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/cat.gif',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "This Cost Estimator was developed by our TST interns as part of their internship project.\n\n"
                  "Creators:\nRJ Martinez & Anjun Parco\n\n"
                  "CvSU - Main Campus, 3rd Yr. BS-ECE Students",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE", style: TextStyle(color: Colors.blueAccent)),
            )
          ],
        ),
      ),
    );
  }

  void _convertValues(bool toMetric) {
    for (var ctrl in [_lenCtrl, _widCtrl, _hgtCtrl]) {
      if (ctrl.text.isNotEmpty) {
        double? val = double.tryParse(ctrl.text);
        if (val != null) {
          if (toMetric) {
            double converted = val * 25.4;
            if ((converted - AppConfig.maxDimensionMm).abs() < 0.5) {
              ctrl.text = AppConfig.maxDimensionMm.toInt().toString();
            } else {
              ctrl.text = converted == converted.roundToDouble() 
                  ? converted.toInt().toString() 
                  : converted.toStringAsFixed(2);
            }
          } else {
            double converted = val / 25.4;
            if ((val - AppConfig.maxDimensionMm).abs() < 0.5) {
              ctrl.text = AppConfig.maxDimensionIn.toStringAsFixed(3);
            } else {
              ctrl.text = converted.toStringAsFixed(2);
            }
          }
        }
      }
    }
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isButtonPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isButtonPressed = false);
    });

    double rawL = double.parse(_lenCtrl.text);
    double rawW = double.parse(_widCtrl.text);
    double rawH = double.parse(_hgtCtrl.text);

    final l = _isMetric ? rawL : rawL * 25.4;
    final w = _isMetric ? rawW : rawW * 25.4;
    final h = _isMetric ? rawH : rawH * 25.4;
    final qty = int.parse(_qtyCtrl.text);

    double productVolume = l * w * h;
    double moldVolume = (l + 2 * AppConfig.allowance) * (w + 2 * AppConfig.allowance) * (h + 2 * AppConfig.allowance);
    double siliconeVolumePerMold = moldVolume - productVolume;
    int moldsNeeded = (qty / AppConfig.shotsPerMold).ceil();

    // Pull from active preset
    final activePreset = AppConfig.materialPresets[AppConfig.selectedPresetIndex];

    double sMatUsd = (siliconeVolumePerMold * moldsNeeded / activePreset.siliconeMm3PerKg) * activePreset.siliconeCostKg;
    double sLabUsd = (moldsNeeded * AppConfig.siliconeTime) * (AppConfig.siliconeLaborRate / 60.0);
    double sTime = (moldsNeeded * AppConfig.siliconeTime).toDouble();

    double uMatUsd = (productVolume * qty / activePreset.urethaneMm3PerKg) * activePreset.urethaneCostKg;
    double uLabUsd = (qty * AppConfig.urethaneTime) * (AppConfig.urethaneLaborRate / 60.0);
    double uTime = (qty * AppConfig.urethaneTime).toDouble();

    final grandTotal = sMatUsd + sLabUsd + uMatUsd + uLabUsd;

    setState(() {
      _results = {
        "len": rawL, "wid": rawW, "hgt": rawH, "qty": qty.toDouble(), "molds": moldsNeeded.toDouble(),
        "sMat": sMatUsd, "sLab": sLabUsd, "sTot": sMatUsd + sLabUsd, "sTime": sTime,
        "uMat": uMatUsd, "uLab": uLabUsd, "uTot": uMatUsd + uLabUsd, "uTime": uTime,
        "grandTotal": grandTotal,
        "grandTotalTime": sTime + uTime,
      };
    });

    final nowStr = DateFormat("MMM dd, yyyy HH:mm").format(DateTime.now());
    AppConfig.addHistoryItem(HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: nowStr,
      length: rawL,
      width: rawW,
      height: rawH,
      quantity: qty,
      isMetric: _isMetric,
      totalCost: grandTotal,
    ));
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isQuantity = false}) {
    final isDark = AppConfig.isDarkMode;
    
    double effectiveMin;
    double effectiveMax;

    if (isQuantity) {
      effectiveMin = 1.0;
      effectiveMax = AppConfig.maxQuantity.toDouble();
    } else if (_isMetric) {
      effectiveMin = AppConfig.minDimensionMm;
      effectiveMax = AppConfig.maxDimensionMm;
    } else {
      effectiveMin = AppConfig.minDimensionIn;
      effectiveMax = AppConfig.maxDimensionIn;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 11),
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.4),
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2)),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 9),
            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10)),
        validator: (value) {
          final val = double.tryParse(value ?? '');
          if (val == null) return 'Enter a value';

          if (isQuantity) {
            if (val < 1 || val > AppConfig.maxQuantity) {
              return 'Range: 1-${AppConfig.maxQuantity}';
            }
            return null;
          }

          if (val < (effectiveMin - 0.01) || val > (effectiveMax + 0.01)) {
            return _isMetric 
                ? 'Range: ${AppConfig.minDimensionMm.toInt()}-${AppConfig.maxDimensionMm.toInt()} mm' 
                : 'Range: ${AppConfig.minDimensionIn.toStringAsFixed(2)}-${AppConfig.maxDimensionIn.toStringAsFixed(2)} in';
          }
          return null;
        },
      ),
    );
  }

  Widget _resultRow(String title, double value) {
    final isDark = AppConfig.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
        Text("\$${_currencyFormat.format(value)}", style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }

  Widget _resultTimeRow(String title, double totalMinutes) {
    final isDark = AppConfig.isDarkMode;
    int totalMins = totalMinutes.round();
    int days = totalMins ~/ (24 * 60);
    int remainingMinsAfterDays = totalMins % (24 * 60);
    int hours = remainingMinsAfterDays ~/ 60;
    int minutes = remainingMinsAfterDays % 60;

    List<String> parts = [];
    if (days > 0) parts.add("$days d");
    if (hours > 0 || days > 0) parts.add("$hours hr");
    parts.add("$minutes min");

    String formattedTime = parts.join(" ");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
        Text(formattedTime, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isDark = AppConfig.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final topGradientColor = isDark ? const Color(0xFF04060A) : const Color(0xFFEAF3F9);
    final unitLabel = _isMetric ? 'mm' : 'in';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: topGradientColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: textColor, size: 20),
            onPressed: _showHistory,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: textColor, size: 20),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (updated == true) {
                setState(() {
                  if (_results != null) _calculate();
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: textColor, size: 20),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF04060A), Color(0xFF0B101D), Color(0xFF141C2E)],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFEAF3F9), Color(0xFFD6E8F3), Color(0xFFBCE0EE)],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget inputSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Volume Price Calculator", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    
                    Container(
                      height: 30,
                      width: 86,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: _isMetric ? Alignment.centerLeft : Alignment.centerRight,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              width: 43,
                              height: 26,
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : Colors.blueAccent,
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!_isMetric) {
                                      setState(() {
                                        _isMetric = true;
                                        _convertValues(true);
                                      });
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _formKey.currentState?.validate();
                                        if (_results != null) _calculate();
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _isMetric
                                            ? (isDark ? const Color(0xFF04060A) : Colors.white)
                                            : textColor.withOpacity(0.6),
                                      ),
                                      child: const Text("mm"),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (_isMetric) {
                                      setState(() {
                                        _isMetric = false;
                                        _convertValues(false);
                                      });
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _formKey.currentState?.validate();
                                        if (_results != null) _calculate();
                                      });
                                    }
                                  },
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: !_isMetric
                                            ? (isDark ? const Color(0xFF04060A) : Colors.white)
                                            : textColor.withOpacity(0.6),
                                      ),
                                      child: const Text("in"),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // --- Preset Profile Dropdown Selector ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: AppConfig.selectedPresetIndex,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF0B101D) : Colors.white,
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                      items: AppConfig.materialPresets.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value.name),
                        );
                      }).toList(),
                      onChanged: (index) {
                        if (index != null) {
                          setState(() {
                            AppConfig.selectedPresetIndex = index;
                            if (_results != null) _calculate();
                          });
                        }
                      },
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    _buildTextField(_lenCtrl, 'Length ($unitLabel)', Icons.straighten),
                    _buildTextField(_widCtrl, 'Width ($unitLabel)', Icons.width_full),
                    _buildTextField(_hgtCtrl, 'Height ($unitLabel)', Icons.height),
                    _buildTextField(_qtyCtrl, 'Quantity (pcs)', Icons.numbers, isQuantity: true),
                    const SizedBox(height: 5),
                    AnimatedScale(
                      scale: _isButtonPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.blueAccent,
                                foregroundColor: isDark ? const Color(0xFF04060A) : Colors.white,
                              ),
                              onPressed: _calculate,
                              child: const Text("CALCULATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                    ),
                  ]),
                ),
              ],
            );

            Widget resultsSection = AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _results == null
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Tap to Copy Grand Total Card ---
                        InkWell(
                          onTap: () {
                            final priceStr = "\$${_currencyFormat.format(_results!['grandTotal']!)}";
                            _copyToClipboard(priceStr, "Grand Total");
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Row(
                                children: [
                                  Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.copy, size: 12, color: textColor.withOpacity(0.6)),
                                ],
                              ),
                              Text("\$${_currencyFormat.format(_results!['grandTotal']!)}", style: TextStyle(fontSize: 14, color: textColor, fontWeight: FontWeight.bold))
                            ]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent, visualDensity: VisualDensity.compact),
                            child: ExpansionTile(
                                textColor: textColor,
                                collapsedTextColor: textColor,
                                iconColor: textColor,
                                collapsedIconColor: textColor,
                                tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                                title: const Text("VIEW DETAILS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text("Dimensions : ${_results!['len']} x ${_results!['wid']} x ${_results!['hgt']} $unitLabel", style: TextStyle(color: textColor, fontSize: 11)),
                                        Text("Quantity : ${_results!['qty']?.toInt()} | Molds : ${_results!['molds']?.toInt()}", style: TextStyle(color: textColor, fontSize: 11)),
                                        Divider(color: isDark ? Colors.white24 : Colors.black26, height: 10),
                                        const Text("--- SILICONE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                        _resultRow("Material", _results!['sMat']!),
                                        _resultRow("Labor", _results!['sLab']!),
                                        _resultTimeRow("Production Time", _results!['sTime']!),
                                        const SizedBox(height: 4),
                                        const Text("--- URETHANE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                        _resultRow("Material", _results!['uMat']!),
                                        _resultRow("Labor", _results!['uLab']!),
                                        _resultTimeRow("Production Time", _results!['uTime']!),
                                        Divider(color: isDark ? Colors.white24 : Colors.black26, height: 10),
                                        _resultTimeRow("Total Production Time", _results!['grandTotalTime']!),
                                        const SizedBox(height: 8),
                                        
                                        // --- Export / Share Quote Action Button ---
                                        SizedBox(
                                          width: double.infinity,
                                          height: 32,
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: isDark ? Colors.white70 : Colors.blueAccent),
                                            ),
                                            icon: Icon(Icons.share, size: 14, color: textColor),
                                            label: Text("SHARE QUOTE", style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
                                            onPressed: _shareQuote,
                                          ),
                                        ),
                                      ])),
                                ]),
                          ),
                        ),
                      ],
                    ),
            );

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 1100 : 700,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                    child: Form(
                      key: _formKey,
                      child: isLandscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: inputSection),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _results == null
                                      ? resultsSection
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [resultsSection],
                                        ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                inputSection,
                                const SizedBox(height: 12),
                                resultsSection,
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}