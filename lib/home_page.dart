import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'patients_database.dart';

class NutriHomePage extends StatefulWidget {
  const NutriHomePage({super.key});

  @override
  _NutriHomePageState createState() => _NutriHomePageState();
}

class _NutriHomePageState extends State<NutriHomePage>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _patientName = "";
  double _bmi = 0.0;
  double _bmr = 0.0;
  double _protein = 0.0;
  double _fat = 0.0;
  double _carbs = 0.0;
  double _minCal = 0.0;
  double _idealWeight = 0.0;
  String _category = "";
  String _gender = "Male";

  // AMR Suggestions
  double _weightLossCal = 0.0;
  double _weightGainCal = 0.0;
  double _maintainCal = 0.0;

  // Macros for each goal
  Map<String, double> _weightLossMacros = {};
  Map<String, double> _maintainMacros = {};
  Map<String, double> _weightGainMacros = {};

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // History
  List<double> _bmiHistory = [];
  List<double> _bmrHistory = [];
  List<double> _calorieMinHistory = [];
  List<String> _dateHistory = [];
  List<String> _nameHistory = [];

  late TabController _tabController;
  bool _isCalculated = false;

  final Map<String, double> activityMap = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extra Active': 1.9,
  };

  final Map<String, double> stressMap = {
    'Normal': 1.0,
    'Confined to bed': 1.2,
    'Minor': 1.2,
    'Skeletal Trauma': 1.35,
    'Cancer': 1.5,
    'Sepsis': 1.6,
    'Burn': 2.0,
  };

  String _selectedActivity = 'Sedentary';
  String _selectedStress = 'Normal';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _heightFeetController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Color _getBMIColor() {
    if (_bmi < 18.5) return Colors.blue;
    if (_bmi <= 24.9) return Colors.green;
    if (_bmi <= 29.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'NutriCalc Pro',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Patient Information", Icons.person),
                const SizedBox(height: 12),
                _buildPatientInfoCard(),
                const SizedBox(height: 24),

                _buildSectionHeader("Body Metrics", Icons.straighten),
                const SizedBox(height: 12),
                _buildBodyMetricsCard(),
                const SizedBox(height: 24),

                _buildSectionHeader("Activity & Stress", Icons.fitness_center),
                const SizedBox(height: 12),
                _buildActivityStressCard(),
                const SizedBox(height: 24),

                _buildActionButtons(),
                const SizedBox(height: 24),

                if (_isCalculated) ...[
                  _buildSectionHeader("Results", Icons.analytics),
                  const SizedBox(height: 12),
                  _buildBMICard(),
                  const SizedBox(height: 16),
                  _buildNutritionCard(),
                  const SizedBox(height: 16),
                  _buildAMRSuggestionsCard(),
                  const SizedBox(height: 24),

                  _buildSectionHeader("Trends", Icons.show_chart),
                  const SizedBox(height: 12),
                  _buildChartTabs(),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              _patientNameController,
              "Patient Name",
              Icons.person_outline,
              TextInputType.text,
            ),
            const SizedBox(height: 12),
            _buildGenderSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _heightFeetController,
                    "Height (ft)",
                    Icons.height,
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    _weightController,
                    "Weight (kg)",
                    Icons.monitor_weight_outlined,
                    TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _ageController,
              "Age (years)",
              Icons.cake_outlined,
              TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdown(
              "Activity Level",
              _selectedActivity,
              activityMap.keys.toList(),
              Icons.directions_run,
                  (v) => setState(() => _selectedActivity = v!),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              "Stress Factor",
              _selectedStress,
              stressMap.keys.toList(),
              Icons.psychology_outlined,
                  (v) => setState(() => _selectedStress = v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _gender = "Male"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gender == "Male" ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.male,
                      color: _gender == "Male" ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Male",
                      style: TextStyle(
                        color: _gender == "Male" ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _gender = "Female"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _gender == "Female" ? Colors.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.female,
                      color: _gender == "Female" ? Colors.white : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Female",
                      style: TextStyle(
                        color: _gender == "Female" ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      TextInputType keyboardType,
      ) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (keyboardType == TextInputType.number) {
          final num = double.tryParse(v);
          if (num == null || num <= 0) return 'Invalid value';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown(
      String label,
      String value,
      List<String> items,
      IconData icon,
      void Function(String?) onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _calculateAll,
            icon: const Icon(Icons.calculate),
            label: const Text(
              "Calculate",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isCalculated ? _savePatient : null,
            icon: const Icon(Icons.save),
            label: const Text(
              "Save Patient",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBMICard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_getBMIColor().withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Body Mass Index",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _getBMIColor(),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getBMIColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem("BMR", "${_bmr.toStringAsFixed(0)} kcal", Icons.local_fire_department),
                _buildMetricItem("IBW", "${_idealWeight.toStringAsFixed(1)} kg", Icons.monitor_weight),
                _buildMetricItem("AMR", "${_minCal.toStringAsFixed(0)} kcal", Icons.energy_savings_leaf),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daily Macronutrients",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMacroBar("Protein", _protein, Colors.red),
            const SizedBox(height: 12),
            _buildMacroBar("Fat", _fat, Colors.orange),
            const SizedBox(height: 12),
            _buildMacroBar("Carbs", _carbs, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(String name, double value, Color color) {
    double maxValue = max(_protein, max(_fat, _carbs));
    double percentage = maxValue > 0 ? (value / maxValue) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "${value.toStringAsFixed(1)}g",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAMRSuggestionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Diet Plans (AMR Based)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weight Loss Plan
            _buildDietPlanCard(
              "Weight Loss Plan",
              _weightLossCal,
              Icons.trending_down,
              Colors.red,
              "Deficit: 500 kcal/day • ~0.5 kg/week",
              _weightLossMacros,
            ),
            const SizedBox(height: 16),

            // Maintain Weight Plan
            _buildDietPlanCard(
              "Maintenance Plan",
              _maintainCal,
              Icons.balance,
              Colors.blue,
              "Current AMR • Maintain weight",
              _maintainMacros,
            ),
            const SizedBox(height: 16),

            // Weight Gain Plan
            _buildDietPlanCard(
              "Weight Gain Plan",
              _weightGainCal,
              Icons.trending_up,
              Colors.green,
              "Surplus: 500 kcal/day • ~0.5 kg/week",
              _weightGainMacros,
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Macros: Protein 4kcal/g • Carbs 4kcal/g • Fat 9kcal/g",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPlanCard(String title, double calories, IconData icon,
      Color color, String subtitle, Map<String, double> macros) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${calories.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                " kcal",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Daily Macronutrients:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroColumn(
                "Protein",
                macros['protein'] ?? 0,
                Colors.red,
                Icons.egg_outlined,
              ),
              _buildMacroColumn(
                "Carbs",
                macros['carbs'] ?? 0,
                Colors.orange,
                Icons.rice_bowl_outlined,
              ),
              _buildMacroColumn(
                "Fat",
                macros['fat'] ?? 0,
                Colors.amber,
                Icons.oil_barrel_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroColumn(String label, double grams, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          "${grams.toStringAsFixed(0)}g",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildChartTabs() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.show_chart), text: "BMI Trend"),
                Tab(icon: Icon(Icons.local_fire_department), text: "Calories"),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildLineChart(_bmiHistory, Colors.blue),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildLineChart(_calorieMinHistory, Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> values, Color color) {
    if (values.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No data yet",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: values.length.toDouble() - 1,
        minY: values.reduce(min) - 2,
        maxY: values.reduce(max) + 2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _dateHistory.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _dateHistory[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
                  (i) => FlSpot(i.toDouble(), values[i]),
            ),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateAll() {
    if (!_formKey.currentState!.validate()) return;

    _patientName = _patientNameController.text;
    double heightFeet = double.parse(_heightFeetController.text);

    // ✅ CORRECT CONVERSION: feet → inches → cm → meters
    // 1 foot = 12 inches
    // 1 inch = 2.54 cm
    double heightInches = heightFeet * 12;
    double heightCm = heightInches * 2.54;
    double heightMeters = heightCm / 100;

    double weight = double.parse(_weightController.text);
    int age = int.parse(_ageController.text);

    // BMI = weight (kg) / height² (m²)
    _bmi = weight / pow(heightMeters, 2);

    if (_bmi < 18.5)
      _category = "Underweight";
    else if (_bmi <= 24.9)
      _category = "Normal";
    else if (_bmi <= 29.9)
      _category = "Overweight";
    else if (_bmi <= 34.9)
      _category = "Obesity I";
    else if (_bmi <= 39.9)
      _category = "Obesity II";
    else
      _category = "Obesity III";

    // BMR using Mifflin-St Jeor Equation
    if (_gender == "Male")
      _bmr = 10 * weight + 6.25 * heightCm - 5 * age + 5;
    else
      _bmr = 10 * weight + 6.25 * heightCm - 5 * age - 161;

    double af = activityMap[_selectedActivity]!;
    double sf = stressMap[_selectedStress]!;
    _minCal = _bmr * af * sf; // This is the AMR (Active Metabolic Rate)

    // ✅ AMR Suggestions for weight goals
    _maintainCal = _minCal; // Current AMR to maintain weight
    _weightLossCal = _minCal - 500; // 500 kcal deficit for weight loss
    _weightGainCal = _minCal + 500; // 500 kcal surplus for weight gain

    // Ensure weight loss calories don't go below BMR
    if (_weightLossCal < _bmr) {
      _weightLossCal = _bmr;
    }

    // ✅ Calculate macros for each goal
    // Weight Loss: Higher protein (35%), Lower carbs (30%), Moderate fat (35%)
    double lossProtein = (_weightLossCal * 0.35) / 4;
    double lossCarbs = (_weightLossCal * 0.30) / 4;
    double lossFat = (_weightLossCal * 0.35) / 9;

    _weightLossMacros = {
      'protein': lossProtein,
      'carbs': lossCarbs,
      'fat': lossFat,
    };

    // Maintenance: Balanced (30% protein, 40% carbs, 30% fat)
    double maintainProtein = (_maintainCal * 0.30) / 4;
    double maintainCarbs = (_maintainCal * 0.40) / 4;
    double maintainFat = (_maintainCal * 0.30) / 9;

    _maintainMacros = {
      'protein': maintainProtein,
      'carbs': maintainCarbs,
      'fat': maintainFat,
    };

    // Weight Gain: Higher carbs (45%), Moderate protein (25%), Moderate fat (30%)
    double gainProtein = (_weightGainCal * 0.25) / 4;
    double gainCarbs = (_weightGainCal * 0.45) / 4;
    double gainFat = (_weightGainCal * 0.30) / 9;

    _weightGainMacros = {
      'protein': gainProtein,
      'carbs': gainCarbs,
      'fat': gainFat,
    };

    // ✅ IBW (Ideal Body Weight) using Devine Formula
    // For men: 50 kg + 2.3 kg per inch over 5 feet
    // For women: 45.5 kg + 2.3 kg per inch over 5 feet
    double totalInches = heightFeet * 12;
    double baseIbw = _gender == "Male" ? 50.0 : 45.5;

    if (totalInches > 60) { // If taller than 5 feet (60 inches)
      double extraInches = totalInches - 60;
      _idealWeight = baseIbw + (2.3 * extraInches);
    } else {
      // For people shorter than 5 feet
      _idealWeight = baseIbw - (2.3 * (60 - totalInches));
    }

    // Ensure ideal weight is not negative or unrealistic
    if (_idealWeight < 30) _idealWeight = 30;

    // Macronutrient calculations for current maintenance
    _protein = weight * 1.8; // 1.8g per kg body weight
    _fat = (_minCal * 0.25) / 9; // 25% of calories from fat
    _carbs = (_minCal - (_protein * 4) - (_fat * 9)) / 4; // Remaining calories

    final dateStr = DateFormat("dd/MM").format(DateTime.now());
    _dateHistory.add(dateStr);
    _nameHistory.add(_patientName);
    _bmiHistory.add(_bmi);
    _bmrHistory.add(_bmr);
    _calorieMinHistory.add(_minCal);

    setState(() {
      _isCalculated = true;
    });
  }

  void _savePatient() async {
    if (_patientNameController.text.trim().isEmpty) {
      _showSnackBar("Please enter patient name", Colors.red);
      return;
    }

    final patient = {
      'name': _patientNameController.text.trim(),
      'bmi': _bmi,
      'bmr': _bmr,
      'bodyFat': 0.0,
      'minCal': _minCal,
      'maxCal': _minCal,
      'date': DateTime.now().toString(),
    };

    try {
      await PatientDatabase.instance.insertPatient(patient);
      _showSnackBar("Patient saved successfully!", Colors.green);
    } catch (e) {
      _showSnackBar("Error saving patient: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}