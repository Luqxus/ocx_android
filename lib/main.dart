import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offconnectx/app_wrapper.dart';
import 'package:offconnectx/service/authentication/bloc.dart';
import 'package:offconnectx/service/authentication/event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// Enum to define different numpad modes
enum NumpadMode {
  pin,
  amount,
}

class NumpadWidget extends StatefulWidget {
  final NumpadMode mode;
  final int? pinLength;
  final double? maxAmount;
  final String? correctPin;
  final Function(String) onSubmit;
  final String? currencySymbol;
  final String? hint;

  const NumpadWidget({
    super.key,
    required this.mode,
    required this.onSubmit,
    this.pinLength = 4,
    this.maxAmount,
    this.correctPin,
    this.currencySymbol = '\$',
    this.hint,
  });

  @override
  State<NumpadWidget> createState() => _NumpadWidgetState();
}

class _NumpadWidgetState extends State<NumpadWidget> {
  String currentInput = '';
  bool isError = false;

  void _addDigit(String digit) {
    setState(() {
      if (widget.mode == NumpadMode.pin) {
        if (currentInput.length < widget.pinLength!) {
          currentInput += digit;
          isError = false;

          if (currentInput.length == widget.pinLength) {
            _verifyPin();
          }
        }
      } else {
        // Amount mode
        if (digit == '.' && currentInput.contains('.')) return;
        if (digit == '.' && currentInput.isEmpty) {
          currentInput = '0.';
          return;
        }

        // Handle decimal places
        if (currentInput.contains('.')) {
          if (currentInput.split('.')[1].length >= 2) return;
        }

        String newAmount = currentInput + digit;
        if (widget.maxAmount != null) {
          try {
            double amount = double.parse(newAmount);
            if (amount > widget.maxAmount!) return;
          } catch (_) {
            return;
          }
        }

        currentInput = newAmount;
      }
    });
  }

  void _verifyPin() {
    if (widget.correctPin != null && currentInput != widget.correctPin) {
      setState(() {
        isError = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {
            currentInput = '';
          });
        });
      });
    } else {
      widget.onSubmit(currentInput);
    }
  }

  void _removeDigit() {
    if (currentInput.isNotEmpty) {
      setState(() {
        currentInput = currentInput.substring(0, currentInput.length - 1);
        isError = false;
      });
    }
  }

  void _clearInput() {
    setState(() {
      currentInput = '';
      isError = false;
    });
  }

  String get _formattedAmount {
    if (currentInput.isEmpty) return '0.00';
    try {
      double amount = double.parse(currentInput);
      return intl.NumberFormat.currency(
        symbol: '',
        decimalDigits: 2,
      ).format(amount);
    } catch (_) {
      return currentInput;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Display section
        if (widget.mode == NumpadMode.pin)
          PinDisplay(
            length: widget.pinLength!,
            filledCount: currentInput.length,
            isError: isError,
          )
        else
          AmountDisplay(
            amount: _formattedAmount,
            currencySymbol: widget.currencySymbol!,
            hint: widget.hint,
          ),

        // Numpad grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              for (var i = 0; i < 3; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (j) => NumpadButton(
                      number: (i * 3 + j + 1).toString(),
                      onTap: () => _addDigit((i * 3 + j + 1).toString()),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Show decimal point only in amount mode
                  widget.mode == NumpadMode.amount
                      ? NumpadButton(
                          number: '.',
                          onTap: () => _addDigit('.'),
                        )
                      : const SizedBox(width: 80),
                  NumpadButton(
                    number: '0',
                    onTap: () => _addDigit('0'),
                  ),
                  DeleteButton(
                    onTap: _removeDigit,
                    // onLongPress: _clearInput,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Submit button for amount mode
        if (widget.mode == NumpadMode.amount && currentInput.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(currentInput),
              child: const Text('Continue'),
            ),
          ),
      ],
    );
  }
}

class AmountDisplay extends StatelessWidget {
  final String amount;
  final String currencySymbol;
  final String? hint;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.currencySymbol,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              hint!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currencySymbol,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Reuse PinDisplay, NumpadButton, and DeleteButton from previous example
// ... [Previous classes remain the same]

class PinDisplay extends StatelessWidget {
  final int length;
  final int filledCount;
  final bool isError;

  const PinDisplay({
    super.key,
    required this.length,
    required this.filledCount,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isError
                ? Colors.red
                : index < filledCount
                    ? Colors.blue
                    : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class NumpadButton extends StatelessWidget {
  final String number;
  final VoidCallback onTap;

  const NumpadButton({
    super.key,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const DeleteButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // PIN mode example
              Expanded(
                child: NumpadWidget(
                  mode: NumpadMode.pin,
                  correctPin: '1234',
                  onSubmit: (pin) {
                    print('PIN entered: $pin');
                  },
                ),
              ),

              // Amount mode example
              Expanded(
                child: NumpadWidget(
                  mode: NumpadMode.amount,
                  maxAmount: 1000,
                  hint: 'Enter transfer amount',
                  currencySymbol: '\$',
                  onSubmit: (amount) {
                    print('Amount entered: $amount');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
