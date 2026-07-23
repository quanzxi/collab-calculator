// ==========================================
// config.dart
// ==========================================
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialPreset {
  final String id;
  String name;
  double siliconeCostKg;
  double siliconeMm3PerKg;
  double urethaneCostKg;
  double urethaneMm3PerKg;

  MaterialPreset({
    required this.id,
    required this.name,
    required this.siliconeCostKg,
    required this.siliconeMm3PerKg,
    required this.urethaneCostKg,
    required this.urethaneMm3PerKg,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'siliconeCostKg': siliconeCostKg,
        'siliconeMm3PerKg': siliconeMm3PerKg,
        'urethaneCostKg': urethaneCostKg,
        'urethaneMm3PerKg': urethaneMm3PerKg,
      };

  factory MaterialPreset.fromJson(Map<String, dynamic> json) => MaterialPreset(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Custom Material',
        siliconeCostKg: (json['siliconeCostKg'] as num?)?.toDouble() ?? 21.84,
        siliconeMm3PerKg: (json['siliconeMm3PerKg'] as num?)?.toDouble() ?? 909090.0,
        urethaneCostKg: (json['urethaneCostKg'] as num?)?.toDouble() ?? 30.0,
        urethaneMm3PerKg: (json['urethaneMm3PerKg'] as num?)?.toDouble() ?? 869565.0,
      );
}

class HistoryItem {
  final String id;
  final String timestamp;
  final double length;
  final double width;
  final double height;
  final int quantity;
  final bool isMetric;
  final double totalCost;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.length,
    required this.width,
    required this.height,
    required this.quantity,
    required this.isMetric,
    required this.totalCost,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp,
        'length': length,
        'width': width,
        'height': height,
        'quantity': quantity,
        'isMetric': isMetric,
        'totalCost': totalCost,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] ?? '',
        timestamp: json['timestamp'] ?? '',
        length: (json['length'] as num?)?.toDouble() ?? 0.0,
        width: (json['width'] as num?)?.toDouble() ?? 0.0,
        height: (json['height'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        isMetric: json['isMetric'] ?? true,
        totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      );
}

class AppConfig {
  static bool isDarkMode = true;
  static double minDimensionMm = 1.0;
  static double minDimensionIn = 0.04;
  
  static double maxDimensionMm = 500.0;
  static double maxDimensionIn = 19.685; 
  
  static int minQuantity = 1;
  static int maxQuantity = 10000;
  
  static double allowance = 40.0;
  static double shotsPerMold = 20.0;
  
  static double siliconeMm3PerKg = 909090.0;
  static double siliconeCostKg = 21.84;
  static double siliconeTime = 60.0;
  static double siliconeLaborRate = 20.0;
  
  static double urethaneMm3PerKg = 869565.0;
  static double urethaneCostKg = 30.0;
  static double urethaneTime = 20.0;
  static double urethaneLaborRate = 15.0;

  // --- Material Presets System ---
  static List<MaterialPreset> materialPresets = [
    MaterialPreset(
      id: 'default_preset',
      name: 'Standard Silicone / Urethane',
      siliconeCostKg: 21.84,
      siliconeMm3PerKg: 909090.0,
      urethaneCostKg: 30.0,
      urethaneMm3PerKg: 869565.0,
    ),
  ];
  static int selectedPresetIndex = 0;

  // --- Calculation History System ---
  static List<HistoryItem> historyList = [];

  static Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String? presetsJson = prefs.getString('material_presets_backup');
    if (presetsJson != null && presetsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(presetsJson);
        materialPresets = decoded.map((e) => MaterialPreset.fromJson(e)).toList();
      } catch (_) {}
    }

    final String? historyJson = prefs.getString('calculation_history');
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        historyList = decoded.map((e) => HistoryItem.fromJson(e)).toList();
      } catch (_) {}
    }
  }

  static Future<void> savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(materialPresets.map((e) => e.toJson()).toList());
    await prefs.setString('material_presets_backup', encoded);
  }

  static Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(historyList.map((e) => e.toJson()).toList());
    await prefs.setString('calculation_history', encoded);
  }

  static Future<void> addHistoryItem(HistoryItem item) async {
    historyList.insert(0, item);
    if (historyList.length > 50) {
      historyList = historyList.sublist(0, 50);
    }
    await saveHistory();
  }

  static Future<void> clearHistory() async {
    historyList.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('calculation_history');
  }

  static String exportPresetsBackupString() {
    return jsonEncode(materialPresets.map((e) => e.toJson()).toList());
  }

  static bool importPresetsBackupString(String jsonStr) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      final imported = decoded.map((e) => MaterialPreset.fromJson(e)).toList();
      if (imported.isNotEmpty) {
        materialPresets = imported;
        selectedPresetIndex = 0;
        savePresets();
        return true;
      }
    } catch (_) {}
    return false;
  }
}