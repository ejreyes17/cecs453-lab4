import 'package:flutter/material.dart';
import 'mortgage.dart';

void main() {
  runApp(const MortgageApp());
}

class MortgageApp extends StatelessWidget {
  const MortgageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mortgage Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MortgageHomeScreen(),
    );
  }
}

// ------------------------------------------------------------
// SCREEN 1 - Displays the mortgage information and results.
// ------------------------------------------------------------
class MortgageHomeScreen extends StatefulWidget {
  const MortgageHomeScreen({super.key});

  @override
  State<MortgageHomeScreen> createState() => _MortgageHomeScreenState();
}

class _MortgageHomeScreenState extends State<MortgageHomeScreen> {
  Mortgage _mortgage = Mortgage();

  bool _termsAccepted = false;

  Future<void> _openModifyScreen() async {
    final Mortgage? updatedMortgage = await Navigator.push<Mortgage>(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyMortgageScreen(
          currentMortgage: _mortgage,
        ),
      ),
    );

    if (updatedMortgage != null) {
      setState(() {
        _mortgage = updatedMortgage;
      });
    }
  }

  Future<void> _handleTermsChanged(bool? value) async {
    if (value == false) {
      setState(() {
        _termsAccepted = false;
      });
      return;
    }

    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: const Text(
            'Please confirm that you accept the terms and conditions.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('ACCEPT'),
            ),
          ],
        );
      },
    );

    setState(() {
      _termsAccepted = accepted ?? false;
    });
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 17),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage Calculator'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _infoRow('Amount', _mortgage.formattedAmount()),
              _infoRow('Years', _mortgage.years.toString()),
              _infoRow('Interest Rate', _mortgage.formattedRate()),
              const Divider(thickness: 2),
              _infoRow(
                'Monthly Payment',
                _mortgage.formattedMonthlyPayment(),
              ),
              _infoRow(
                'Total Payment',
                _mortgage.formattedTotalPayment(),
              ),

              // Required by the PDF: checkbox after Total Payment.
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Terms and Conditions'),
                value: _termsAccepted,
                onChanged: _handleTermsChanged,
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 28),

              Center(
                child: ElevatedButton(
                  onPressed: _openModifyScreen,
                  child: const Text('MODIFY DATA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// SCREEN 2 - Allows the user to modify years, amount, and rate.
// ------------------------------------------------------------
class ModifyMortgageScreen extends StatefulWidget {
  final Mortgage currentMortgage;

  const ModifyMortgageScreen({
    super.key,
    required this.currentMortgage,
  });

  @override
  State<ModifyMortgageScreen> createState() => _ModifyMortgageScreenState();
}

class _ModifyMortgageScreenState extends State<ModifyMortgageScreen> {
  late TextEditingController _amountController;

  late int _selectedYears;
  late double _selectedRatePercent;

  // The lab image shows these three year choices.
  final List<int> _yearOptions = [10, 15, 30];

  // Requirement from PDF:
  // Interest rates from 2% through 15% in increments of 0.25%.
  late final List<double> _rateOptions;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.currentMortgage.amount.toStringAsFixed(2),
    );

    _selectedYears = widget.currentMortgage.years;

    if (!_yearOptions.contains(_selectedYears)) {
      _selectedYears = 30;
    }

    _selectedRatePercent = widget.currentMortgage.rate * 100;

    _rateOptions = List.generate(
      53,
      (index) => 2.0 + (index * 0.25),
    );

    if (_selectedRatePercent < 2.0 || _selectedRatePercent > 15.0) {
      _selectedRatePercent = 3.5;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _done() {
    final double? amount = double.tryParse(_amountController.text);

    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      return;
    }

    final Mortgage updatedMortgage = Mortgage(
      amount: amount,
      years: _selectedYears,
      rate: _selectedRatePercent / 100,
    );

    // Returns the updated Mortgage object to Screen 1.
    Navigator.pop(context, updatedMortgage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Mortgage'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Years',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Wrap(
                spacing: 6,
                children: _yearOptions.map((year) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<int>(
                        value: year,
                        groupValue: _selectedYears,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedYears = value;
                            });
                          }
                        },
                      ),
                      Text('$year'),
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Interest Rate: '
                '${_selectedRatePercent.toStringAsFixed(2)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Required by the PDF: interest rate is a ListView.
              Expanded(
                child: ListView.builder(
                  itemCount: _rateOptions.length,
                  itemBuilder: (context, index) {
                    final double rate = _rateOptions[index];
                    final bool selected =
                        (rate - _selectedRatePercent).abs() < 0.001;

                    return ListTile(
                      title: Text('${rate.toStringAsFixed(2)}%'),
                      trailing: selected
                          ? const Icon(Icons.check_circle)
                          : null,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _selectedRatePercent = rate;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _done,
                child: const Text('DONE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
