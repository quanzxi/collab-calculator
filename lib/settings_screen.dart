// ==========================================
// settings_screen.dart
// ==========================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _minDimMmCtrl;
  late TextEditingController _maxDimMmCtrl;
  late TextEditingController _minDimInCtrl;
  late TextEditingController _maxDimInCtrl;
  late TextEditingController _maxQtyCtrl;

  late TextEditingController _allowanceCtrl;
  late TextEditingController _shotsCtrl;

  late TextEditingController _sCostCtrl;
  late TextEditingController _sKgCtrl;
  late TextEditingController _sTimeCtrl;
  late TextEditingController _sLaborCtrl;

  late TextEditingController _uCostCtrl;
  late TextEditingController _uKgCtrl;
  late TextEditingController _uTimeCtrl;
  late TextEditingController _uLaborCtrl;

  // Preset & Backup Controllers
  final _presetNameCtrl = TextEditingController(text: "New Material Preset");
  late TextEditingController _exportBackupCtrl;
  final _importBackupCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minDimMmCtrl = TextEditingController(text: AppConfig.minDimensionMm.toString());
    _maxDimMmCtrl = TextEditingController(text: AppConfig.maxDimensionMm.toString());
    _minDimInCtrl = TextEditingController(text: AppConfig.minDimensionIn.toString());
    _maxDimInCtrl = TextEditingController(text: AppConfig.maxDimensionIn.toString());
    _maxQtyCtrl = TextEditingController(text: AppConfig.maxQuantity.toString());

    _allowanceCtrl = TextEditingController(text: AppConfig.allowance.toString());
    _shotsCtrl = TextEditingController(text: AppConfig.shotsPerMold.toString());

    _sCostCtrl = TextEditingController(text: AppConfig.siliconeCostKg.toString());
    _sKgCtrl = TextEditingController(text: AppConfig.siliconeMm3PerKg.toString());
    _sTimeCtrl = TextEditingController(text: AppConfig.siliconeTime.toString());
    _sLaborCtrl = TextEditingController(text: AppConfig.siliconeLaborRate.toString());

    _uCostCtrl = TextEditingController(text: AppConfig.urethaneCostKg.toString());
    _uKgCtrl = TextEditingController(text: AppConfig.urethaneMm3PerKg.toString());
    _uTimeCtrl = TextEditingController(text: AppConfig.urethaneTime.toString());
    _uLaborCtrl = TextEditingController(text: AppConfig.urethaneLaborRate.toString());

    _exportBackupCtrl = TextEditingController(text: AppConfig.exportPresetsBackupString());
  }

  @override
  void dispose() {
    _minDimMmCtrl.dispose();
    _maxDimMmCtrl.dispose();
    _minDimInCtrl.dispose();
    _maxDimInCtrl.dispose();
    _maxQtyCtrl.dispose();
    _allowanceCtrl.dispose();
    _shotsCtrl.dispose();
    _sCostCtrl.dispose();
    _sKgCtrl.dispose();
    _sTimeCtrl.dispose();
    _sLaborCtrl.dispose();
    _uCostCtrl.dispose();
    _uKgCtrl.dispose();
    _uTimeCtrl.dispose();
    _uLaborCtrl.dispose();
    _presetNameCtrl.dispose();
    _exportBackupCtrl.dispose();
    _importBackupCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    AppConfig.minDimensionMm = double.parse(_minDimMmCtrl.text);
    AppConfig.maxDimensionMm = double.parse(_maxDimMmCtrl.text);
    AppConfig.minDimensionIn = double.parse(_minDimInCtrl.text);
    AppConfig.maxDimensionIn = double.parse(_maxDimInCtrl.text);
    AppConfig.maxQuantity = int.parse(_maxQtyCtrl.text);

    AppConfig.allowance = double.parse(_allowanceCtrl.text);
    AppConfig.shotsPerMold = double.parse(_shotsCtrl.text);

    AppConfig.siliconeCostKg = double.parse(_sCostCtrl.text);
    AppConfig.siliconeMm3PerKg = double.parse(_sKgCtrl.text);
    AppConfig.siliconeTime = double.parse(_sTimeCtrl.text);
    AppConfig.siliconeLaborRate = double.parse(_sLaborCtrl.text);

    AppConfig.urethaneCostKg = double.parse(_uCostCtrl.text);
    AppConfig.urethaneMm3PerKg = double.parse(_uKgCtrl.text);
    AppConfig.urethaneTime = double.parse(_uTimeCtrl.text);
    AppConfig.urethaneLaborRate = double.parse(_uLaborCtrl.text);

    await AppConfig.savePresets();

    if (mounted) Navigator.pop(context, true);
  }

  void _resetDefaults() {
    setState(() {
      AppConfig.minDimensionMm = 1.0;
      AppConfig.maxDimensionMm = 500.0;
      AppConfig.minDimensionIn = 0.04;
      AppConfig.maxDimensionIn = 19.685;
      AppConfig.maxQuantity = 10000;

      AppConfig.allowance = 40.0;
      AppConfig.shotsPerMold = 20.0;

      AppConfig.siliconeCostKg = 21.84;
      AppConfig.siliconeMm3PerKg = 909090.0;
      AppConfig.siliconeTime = 60.0;
      AppConfig.siliconeLaborRate = 20.0;

      AppConfig.urethaneCostKg = 30.0;
      AppConfig.urethaneMm3PerKg = 869565.0;
      AppConfig.urethaneTime = 20.0;
      AppConfig.urethaneLaborRate = 15.0;

      _minDimMmCtrl.text = AppConfig.minDimensionMm.toString();
      _maxDimMmCtrl.text = AppConfig.maxDimensionMm.toString();
      _minDimInCtrl.text = AppConfig.minDimensionIn.toString();
      _maxDimInCtrl.text = AppConfig.maxDimensionIn.toString();
      _maxQtyCtrl.text = AppConfig.maxQuantity.toString();

      _allowanceCtrl.text = AppConfig.allowance.toString();
      _shotsCtrl.text = AppConfig.shotsPerMold.toString();

      _sCostCtrl.text = AppConfig.siliconeCostKg.toString();
      _sKgCtrl.text = AppConfig.siliconeMm3PerKg.toString();
      _sTimeCtrl.text = AppConfig.siliconeTime.toString();
      _sLaborCtrl.text = AppConfig.siliconeLaborRate.toString();

      _uCostCtrl.text = AppConfig.urethaneCostKg.toString();
      _uKgCtrl.text = AppConfig.urethaneMm3PerKg.toString();
      _uTimeCtrl.text = AppConfig.urethaneTime.toString();
      _uLaborCtrl.text = AppConfig.urethaneLaborRate.toString();
      
      _exportBackupCtrl.text = AppConfig.exportPresetsBackupString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reset to default settings"), duration: Duration(seconds: 1)),
    );
  }

  void _addMaterialPreset() {
    if (_presetNameCtrl.text.trim().isEmpty) return;

    final newPreset = MaterialPreset(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _presetNameCtrl.text.trim(),
      siliconeCostKg: double.tryParse(_sCostCtrl.text) ?? 21.84,
      siliconeMm3PerKg: double.tryParse(_sKgCtrl.text) ?? 909090.0,
      urethaneCostKg: double.tryParse(_uCostCtrl.text) ?? 30.0,
      urethaneMm3PerKg: double.tryParse(_uKgCtrl.text) ?? 869565.0,
    );

    setState(() {
      AppConfig.materialPresets.add(newPreset);
      AppConfig.selectedPresetIndex = AppConfig.materialPresets.length - 1;
      _exportBackupCtrl.text = AppConfig.exportPresetsBackupString();
    });

    AppConfig.savePresets();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("New material preset added!"), duration: Duration(seconds: 1)),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {required bool isTablet}) {
    final isDark = AppConfig.isDarkMode;
    final double fontSize = isTablet ? 15.0 : 13.0;
    final double labelFontSize = isTablet ? 13.0 : 11.0;
    final double iconSize = isTablet ? 18.0 : 14.0;
    final EdgeInsets contentPadding = isTablet 
        ? const EdgeInsets.symmetric(vertical: 10, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 4, horizontal: 10);

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: TextStyle(fontSize: fontSize, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: labelFontSize),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.4),
          prefixIcon: Icon(icon, color: Colors.blueAccent, size: iconSize),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2)),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: isTablet ? 11 : 9),
          contentPadding: contentPadding,
        ),
        validator: (val) => (val == null || double.tryParse(val) == null) ? 'Required' : null,
      ),
    );
  }

  Widget _buildThemeToggleTile(bool isTablet) {
    final isDark = AppConfig.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final double fontSize = isTablet ? 15.0 : 13.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 12 : 10, vertical: isTablet ? 6 : 2),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.blueAccent,
                  size: isTablet ? 20.0 : 16.0,
                ),
                const SizedBox(width: 8),
                Text(
                  "App Theme (${isDark ? 'Dark' : 'Light'})",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: textColor,
                  ),
                ),
              ],
            ),
            Switch(
              value: AppConfig.isDarkMode,
              activeColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  AppConfig.isDarkMode = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsManagerContainer({required bool isTablet}) {
    final isDark = AppConfig.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final double titleFontSize = isTablet ? 16.0 : 13.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Material Presets & Backups", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: titleFontSize)),
          const SizedBox(height: 8),

          // Preset List
          Column(
            children: AppConfig.materialPresets.asMap().entries.map((entry) {
              final idx = entry.key;
              final preset = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(preset.name, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    if (preset.id != 'default_preset')
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                        onPressed: () {
                          setState(() {
                            AppConfig.materialPresets.removeAt(idx);
                            AppConfig.selectedPresetIndex = 0;
                            _exportBackupCtrl.text = AppConfig.exportPresetsBackupString();
                          });
                          AppConfig.savePresets();
                        },
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Add New Preset Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _presetNameCtrl,
                  style: TextStyle(fontSize: 12, color: textColor),
                  decoration: InputDecoration(
                    hintText: "New Material Name",
                    hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: _addMaterialPreset,
                child: const Text("ADD PRESET", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Export Backup Code Field
          TextField(
            controller: _exportBackupCtrl,
            readOnly: true,
            style: TextStyle(fontSize: 10, color: textColor),
            decoration: InputDecoration(
              labelText: "Export Backup Data String",
              labelStyle: const TextStyle(fontSize: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _exportBackupCtrl.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Backup code string copied!"), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Import Backup Code Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _importBackupCtrl,
                  style: TextStyle(fontSize: 10, color: textColor),
                  decoration: InputDecoration(
                    labelText: "Paste Backup String Here",
                    labelStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isDark ? Colors.white24 : Colors.black12),
                onPressed: () {
                  if (_importBackupCtrl.text.trim().isNotEmpty) {
                    final success = AppConfig.importPresetsBackupString(_importBackupCtrl.text.trim());
                    if (success) {
                      setState(() {
                        _exportBackupCtrl.text = AppConfig.exportPresetsBackupString();
                        _importBackupCtrl.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Backup imported successfully!"), duration: Duration(seconds: 1)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invalid backup data format!"), duration: Duration(seconds: 1)),
                      );
                    }
                  }
                },
                child: Text("IMPORT", style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(String title, List<Widget> children, {required bool isTablet}) {
    final isDark = AppConfig.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final double titleFontSize = isTablet ? 16.0 : 13.0;
    final double padding = isTablet ? 16.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(padding),
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: titleFontSize)),
          SizedBox(height: isTablet ? 12 : 8),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    final isTablet = mediaQuery.size.shortestSide >= 600;

    final isDark = AppConfig.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final topGradientColor = isDark ? const Color(0xFF04060A) : const Color(0xFFEAF3F9);

    final double buttonHeight = isTablet ? 48.0 : 38.0;
    final double buttonFontSize = isTablet ? 13.0 : 11.0;

    Widget leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionContainer(
          "UI & Input Limits",
          [
            _buildThemeToggleTile(isTablet),
            _buildField(_minDimMmCtrl, "Min Dimension (mm)", Icons.straighten, isTablet: isTablet),
            _buildField(_maxDimMmCtrl, "Max Dimension (mm)", Icons.straighten, isTablet: isTablet),
            _buildField(_minDimInCtrl, "Min Dimension (in)", Icons.straighten, isTablet: isTablet),
            _buildField(_maxDimInCtrl, "Max Dimension (in)", Icons.straighten, isTablet: isTablet),
            _buildField(_maxQtyCtrl, "Max Quantity (pcs)", Icons.numbers, isTablet: isTablet),
          ],
          isTablet: isTablet,
        ),
        _buildSectionContainer(
          "Mold & Allowance Parameters",
          [
            _buildField(_allowanceCtrl, "Mold Allowance (mm)", Icons.aspect_ratio, isTablet: isTablet),
            _buildField(_shotsCtrl, "Shots Per Mold", Icons.repeat, isTablet: isTablet),
          ],
          isTablet: isTablet,
        ),
      ],
    );

    Widget rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPresetsManagerContainer(isTablet: isTablet),
        _buildSectionContainer(
          "Silicone Parameters",
          [
            _buildField(_sCostCtrl, "Silicone Cost (\$ / kg)", Icons.attach_money, isTablet: isTablet),
            _buildField(_sKgCtrl, "Silicone Volume Density (mm³/kg)", Icons.science, isTablet: isTablet),
            _buildField(_sTimeCtrl, "Silicone Time Per Mold (min)", Icons.timer, isTablet: isTablet),
            _buildField(_sLaborCtrl, "Silicone Labor Rate (\$ / min)", Icons.work, isTablet: isTablet),
          ],
          isTablet: isTablet,
        ),
        _buildSectionContainer(
          "Urethane Parameters",
          [
            _buildField(_uCostCtrl, "Urethane Cost (\$ / kg)", Icons.attach_money, isTablet: isTablet),
            _buildField(_uKgCtrl, "Urethane Volume Density (mm³/kg)", Icons.science, isTablet: isTablet),
            _buildField(_uTimeCtrl, "Urethane Time Per Unit (min)", Icons.timer, isTablet: isTablet),
            _buildField(_uLaborCtrl, "Urethane Labor Rate (\$ / min)", Icons.work, isTablet: isTablet),
          ],
          isTablet: isTablet,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? Colors.white70 : Colors.blueAccent),
                    foregroundColor: textColor,
                  ),
                  onPressed: _resetDefaults,
                  child: Text("RESET DEFAULTS", style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.blueAccent,
                    foregroundColor: isDark ? const Color(0xFF04060A) : Colors.white,
                  ),
                  onPressed: _saveSettings,
                  child: Text("SAVE SETTINGS", style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: topGradientColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isTablet ? 56 : 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor, size: isTablet ? 24 : 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings", style: TextStyle(color: textColor, fontSize: isTablet ? 20 : 16, fontWeight: FontWeight.bold)),
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
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isLandscape ? 1450 : 700,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24.0 : 16.0,
                    vertical: isTablet ? 16.0 : 8.0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                    child: Form(
                      key: _formKey,
                      child: isLandscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: leftColumn),
                                SizedBox(width: isTablet ? 32 : 24),
                                Expanded(child: rightColumn),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                leftColumn,
                                rightColumn,
                                const SizedBox(height: 12),
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