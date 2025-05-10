import 'package:flutter/material.dart';

void main() {
  runApp(ConversionApp());
}

class ConversionApp extends StatelessWidget {
  const ConversionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Measures Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ConversionScreen(),
    );
  }
}

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
  //_ConversionScreenState createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _fromUnit = 'Miles';
  String _toUnit = 'Kilometers';
  String _result = '';

  // Lists of available units by category
  final Map<String, List<String>> _unitCategories = {
    'Distance': ['Miles', 'Kilometers', 'Meters', 'Feet'],
    'Weight': ['Kilograms', 'Pounds', 'Grams', 'Ounces'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  String _selectedCategory = 'Distance';

  // Conversion factors relative to base units
  final Map<String, double> _conversionFactors = {
    // Distance (base: meters)
    'Miles': 1609.34,
    'Kilometers': 1000.0,
    'Meters': 1.0,
    'Feet': 0.3048,

    // Weight (base: grams)
    'Kilograms': 1000.0,
    'Pounds': 453.592,
    'Grams': 1.0,
    'Ounces': 28.3495,

    // Temperature needs special handling
    'Celsius': 1.0,
    'Fahrenheit': 1.0,
    'Kelvin': 1.0,
  };

  // Conversion logic
  void _convert() {
    // Validate input
    if (_inputController.text.isEmpty) {
      setState(() {
        _result = 'Please enter a value';
      });
      return;
    }

    double inputValue = double.tryParse(_inputController.text) ?? 0.0;
    double convertedValue;

    // Handle temperature conversions separately due to offset formulas
    if (_selectedCategory == 'Temperature') {
      convertedValue = _convertTemperature(inputValue, _fromUnit, _toUnit);
    } else {
      // For distance and weight, convert to base unit first, then to target unit
      double valueInBaseUnit = inputValue * _conversionFactors[_fromUnit]!;
      convertedValue = valueInBaseUnit / _conversionFactors[_toUnit]!;
    }

    setState(() {
      // Grammar fix: use "are" for plural units, "is" for singular
      String verb = inputValue == 1.0 ? "is" : "are";
      _result = '${inputValue.toString()} $_fromUnit $verb ${convertedValue.toStringAsFixed(4)} $_toUnit';
    });
  }

  // Special handling for temperature conversions
  double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first (as base unit)
    double celsius;

    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else { // Kelvin
      celsius = value - 273.15;
    }

    // Convert from Celsius to target unit
    if (to == 'Celsius') {
      return celsius;
    } else if (to == 'Fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else { // Kelvin
      return celsius + 273.15;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Measures Converter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 27,
            ),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category selection
              Text(
                'Category',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                style: TextStyle(color: Colors.blue, fontSize: 18),
                items: _unitCategories.keys.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                    // Reset units when category changes
                    _fromUnit = _unitCategories[_selectedCategory]!.first;
                    _toUnit = _unitCategories[_selectedCategory]!.last;
                    _result = '';
                  });
                },
              ),
              SizedBox(height: 20),

              // Input field (Value)
              Text(
                'Value',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter a number',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
              SizedBox(height: 20),

              // From unit selection
              Text(
                'From',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _fromUnit,
                isExpanded: true,
                style: TextStyle(color: Colors.blue, fontSize: 18),
                items: _unitCategories[_selectedCategory]!.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _fromUnit = newValue!;
                    _result = '';
                  });
                },
              ),
              SizedBox(height: 20),

              // To unit selection
              Text(
                'To',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _toUnit,
                isExpanded: true,
                style: TextStyle(color: Colors.blue, fontSize: 18),
                items: _unitCategories[_selectedCategory]!.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _toUnit = newValue!;
                    _result = '';
                  });
                },
              ),
              SizedBox(height: 30),

              // Convert button
              ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Convert', style: TextStyle(fontSize: 21, color: Colors.blue)),
              ),

              // Result display directly under the convert button
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result.isNotEmpty ? _result : 'Result will appear here',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}