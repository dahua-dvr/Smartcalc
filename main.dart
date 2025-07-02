import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Supports both full and popup
  runApp(SmartCalcApp());
}

class SmartCalcApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCalc+',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, // Auto switch dark/light
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  bool _isTorchOn = false;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _evaluate(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  String _evaluate(String expr) {
    try {
      expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
      final result = double.parse(expr);
      return result.toString();
    } catch (e) {
      return 'Invalid';
    }
  }

  void _toggleTorch() async {
    try {
      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Torch not available on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonLabels = [
      ['7', '8', '9', '/'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['C', '0', '=', '+'],
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_expression, style: TextStyle(fontSize: 32)),
                    Text(_result, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: buttonLabels.map((row) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: row.map((label) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => _onButtonPressed(label),
                              child: Text(label, style: TextStyle(fontSize: 28)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: IconButton(
                icon: Icon(
                  _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                  size: 32,
                  color: Colors.orangeAccent,
                ),
                onPressed: _toggleTorch,
              ),
            )
          ],
        ),
      ),
    );
  }
}