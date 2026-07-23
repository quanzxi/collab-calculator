// ==========================================
// main.dart
// ==========================================
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
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
    home: const VolumeCalculatorApp(),
  ));
}

class VolumeCalculatorApp extends StatefulWidget {
  const VolumeCalculatorApp({super.key});
  @override
  State<VolumeCalculatorApp> createState() => _VolumeCalculatorAppState();
}

class _VolumeCalculatorAppState extends State<VolumeCalculatorApp> {
  final _formKey = GlobalKey<FormState>();
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _hgtCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  Map<String, double>? _results;
  final _currencyFormat = NumberFormat("#,##0.00", "en_US");
  bool _isButtonPressed = false;
  
  bool _isMetric = true;
  bool _needsPainting = false;

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
Price Per Piece: \$${_currencyFormat.format(_results?['pricePerPiece'] ?? 0.0)}
Total Production Cost: \$${_currencyFormat.format(_results?['grandTotal'] ?? 0.0)}
Dimensions: ${_results?['len']} x ${_results?['wid']} x ${_results?['hgt']} $unitLabel
Quantity Ordered: ${_results?['qty']?.toInt()} units
Painting Required: ${_needsPainting ? 'Yes' : 'No'}
Total Molds Needed: ${_results?['molds']?.toInt()}

[Silicone Details]
Material Cost: \$${_currencyFormat.format(_results?['sMat'] ?? 0.0)}
Labor Cost: \$${_currencyFormat.format(_results?['sLab'] ?? 0.0)}
Subtotal: \$${_currencyFormat.format(_results?['sTot'] ?? 0.0)}

[Urethane Details]
Material Cost: \$${_currencyFormat.format(_results?['uMat'] ?? 0.0)}
Labor Cost: \$${_currencyFormat.format(_results?['uLab'] ?? 0.0)}
Subtotal: \$${_currencyFormat.format(_results?['uTot'] ?? 0.0)}

[Finishing & Post-Processing]
Paint Cost: \$${_currencyFormat.format(_results?['paintTot'] ?? 0.0)}
""";

    Share.share(reportText, subject: 'Castculator Production Quote');
  }

  Future<void> _exportToExcel() async {
    if (AppConfig.historyList.isEmpty) return;

    var excel = excel_lib.Excel.createExcel();
    excel_lib.Sheet sheetObject = excel['History Log'];
    excel.delete('Sheet1'); // Remove default sheet

    // Add Headers
    sheetObject.appendRow([
      excel_lib.TextCellValue('Timestamp'),
      excel_lib.TextCellValue('Length'),
      excel_lib.TextCellValue('Width'),
      excel_lib.TextCellValue('Height'),
      excel_lib.TextCellValue('Unit'),
      excel_lib.TextCellValue('Quantity'),
      excel_lib.TextCellValue('Total Cost (\$)'),
    ]);

    // Add History Rows
    for (var item in AppConfig.historyList) {
      sheetObject.appendRow([
        excel_lib.TextCellValue(item.timestamp),
        excel_lib.DoubleCellValue(item.length),
        excel_lib.DoubleCellValue(item.width),
        excel_lib.DoubleCellValue(item.height),
        excel_lib.TextCellValue(item.isMetric ? 'mm' : 'in'),
        excel_lib.IntCellValue(item.quantity),
        excel_lib.DoubleCellValue(double.parse(item.totalCost.toStringAsFixed(2))),
      ]);
    }

    // Save and Share File
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/Castculator_History.xlsx";
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Castculator Calculation History Tracking Log',
      );
    }
  }

  void _showHistory() {
    final isDark = AppConfig.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: isDark ? const Color(0xFF070B14) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) => Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxHeight: 450, maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Calculation History",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (AppConfig.historyList.isNotEmpty)
                          Row(
                            children: [
                              IconButton(
                                tooltip: "Export to Excel",
                                icon: const Icon(Icons.table_view_outlined, color: Colors.greenAccent, size: 20),
                                onPressed: () async {
                                  await _exportToExcel();
                                },
                              ),
                              TextButton(
                                onPressed: () async {
                                  await AppConfig.clearHistory();
                                  setDialogState(() {});
                                  setState(() {});
                                },
                                child: const Text("CLEAR", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Scrollable History Content
                    Expanded(
                      child: AppConfig.historyList.isEmpty
                          ? Center(
                              child: Text(
                                "No history recorded yet.",
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: AppConfig.historyList.length,
                              itemBuilder: (context, index) {
                                final item = AppConfig.historyList[index];
                                final unit = item.isMetric ? 'mm' : 'in';
                                final priceStr = "\$${_currencyFormat.format(item.totalCost)}";
                                return Card(
                                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(
                                      "${item.length} x ${item.width} x ${item.height} $unit | Qty: ${item.quantity}",
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(item.timestamp, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 10)),
                                    trailing: Text(priceStr, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                                    onTap: () => _copyToClipboard(priceStr, "Price"),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),

                    // Close Button Area
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                  "Castculator was developed by our TST interns as part of their internship project.\n\n"
                  "Creators:\nRJ Martinez & Anjun Parco\n\n"
                  "CvSU - Main Campus | 3rd Yr. BS-ECE Students",
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

    final activeIndex = AppConfig.selectedPresetIndex < AppConfig.materialPresets.length 
        ? AppConfig.selectedPresetIndex 
        : 0;
    final activePreset = AppConfig.materialPresets[activeIndex];

    double sMatUsd = (siliconeVolumePerMold * moldsNeeded / activePreset.siliconeMm3PerKg) * activePreset.siliconeCostKg;
    double sLabUsd = (moldsNeeded * AppConfig.siliconeTime) * (AppConfig.siliconeLaborRate / 60.0);
    double sTime = (moldsNeeded * AppConfig.siliconeTime).toDouble();

    double uMatUsd = (productVolume * qty / activePreset.urethaneMm3PerKg) * activePreset.urethaneCostKg;
    double uLabUsd = (qty * AppConfig.urethaneTime) * (AppConfig.urethaneLaborRate / 60.0);
    double uTime = (qty * AppConfig.urethaneTime).toDouble();

    double paintCostPerPiece = _needsPainting ? 5.00 : 0.0; 
    double paintTotUsd = paintCostPerPiece * qty;

    final grandTotal = sMatUsd + sLabUsd + uMatUsd + uLabUsd + paintTotUsd;
    final pricePerPiece = qty > 0 ? grandTotal / qty : 0.0;

    setState(() {
      _results = {
        "len": rawL, "wid": rawW, "hgt": rawH, "qty": qty.toDouble(), "molds": moldsNeeded.toDouble(),
        "sMat": sMatUsd, "sLab": sLabUsd, "sTot": sMatUsd + sLabUsd, "sTime": sTime,
        "uMat": uMatUsd, "uLab": uLabUsd, "uTot": uMatUsd + uLabUsd, "uTime": uTime,
        "paintTot": paintTotUsd,
        "pricePerPiece": pricePerPiece,
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
    
    // 8-hour workday logic (480 mins / day)
    const int minsPerWorkDay = 8 * 60;

    int workDays = totalMins ~/ minsPerWorkDay;
    int remainingMinsAfterDays = totalMins % minsPerWorkDay;
    int hours = remainingMinsAfterDays ~/ 60;
    int minutes = remainingMinsAfterDays % 60;

    List<String> parts = [];
    if (workDays > 0) parts.add("$workDays ${workDays == 1 ? 'day' : 'days'}");
    if (hours > 0) parts.add("$hours hr");
    if (minutes > 0 || (workDays == 0 && hours == 0)) parts.add("$minutes min");

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
                    Text("Castculator", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    
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

                // Updated Preset Dropdown Selector
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LayoutBuilder(
                    builder: (context, menuConstraints) {
                      return DropdownMenu<int>(
                        width: menuConstraints.maxWidth,
                        initialSelection: AppConfig.selectedPresetIndex < AppConfig.materialPresets.length
                            ? AppConfig.selectedPresetIndex
                            : 0,
                        textStyle: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        menuStyle: MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(isDark ? const Color(0xFF0B101D) : Colors.white),
                        ),
                        dropdownMenuEntries: AppConfig.materialPresets.asMap().entries.map((entry) {
                          return DropdownMenuEntry<int>(
                            value: entry.key,
                            label: entry.value.name,
                            style: MenuItemButton.styleFrom(
                              foregroundColor: textColor,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        onSelected: (index) {
                          if (index != null) {
                            setState(() {
                              AppConfig.selectedPresetIndex = index;
                              if (_results != null) _calculate();
                            });
                          }
                        },
                      );
                    },
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
                    
                    Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: textColor.withOpacity(0.6),
                      ),
                      child: CheckboxListTile(
                        value: _needsPainting,
                        dense: true,
                        activeColor: Colors.blueAccent,
                        contentPadding: EdgeInsets.zero,
                        title: Text("Requires Painting / Finishing", style: TextStyle(color: textColor, fontSize: 12)),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? value) {
                          setState(() {
                            _needsPainting = value ?? false;
                            if (_results != null) _calculate();
                          });
                        },
                      ),
                    ),

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
                        InkWell(
                          onTap: () {
                            final priceStr = "\$${_currencyFormat.format(_results?['grandTotal'] ?? 0.0)}";
                            _copyToClipboard(priceStr, "Grand Total");
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("PRICE PER PIECE", style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                                    Text(
                                      "\$${_currencyFormat.format(_results?['pricePerPiece'] ?? 0.0)}", 
                                      style: const TextStyle(fontSize: 15, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.copy, size: 12, color: textColor.withOpacity(0.6)),
                                      ],
                                    ),
                                    Text(
                                      "\$${_currencyFormat.format(_results?['grandTotal'] ?? 0.0)}", 
                                      style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                        Text("Dimensions : ${_results?['len']} x ${_results?['wid']} x ${_results?['hgt']} $unitLabel", style: TextStyle(color: textColor, fontSize: 11)),
                                        Text("Quantity : ${_results?['qty']?.toInt()} | Molds : ${_results?['molds']?.toInt()}", style: TextStyle(color: textColor, fontSize: 11)),
                                        Text("Painting Included : ${_needsPainting ? 'Yes' : 'No'}", style: TextStyle(color: textColor, fontSize: 11)),
                                        Divider(color: isDark ? Colors.white24 : Colors.black26, height: 10),
                                        const Text("--- SILICONE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                        _resultRow("Material", _results?['sMat'] ?? 0.0),
                                        _resultRow("Labor", _results?['sLab'] ?? 0.0),
                                        _resultTimeRow("Production Time", _results?['sTime'] ?? 0.0),
                                        const SizedBox(height: 4),
                                        const Text("--- URETHANE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                        _resultRow("Material", _results?['uMat'] ?? 0.0),
                                        _resultRow("Labor", _results?['uLab'] ?? 0.0),
                                        _resultTimeRow("Production Time", _results?['uTime'] ?? 0.0),
                                        if (_needsPainting) ...[
                                          const SizedBox(height: 4),
                                          const Text("--- FINISHING ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                          _resultRow("Painting Total", _results?['paintTot'] ?? 0.0),
                                        ],
                                        Divider(color: isDark ? Colors.white24 : Colors.black26, height: 10),
                                        _resultRow("Price Per Piece", _results?['pricePerPiece'] ?? 0.0),
                                        _resultTimeRow("Total Production Time", _results?['grandTotalTime'] ?? 0.0),
                                        const SizedBox(height: 8),
                                        
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