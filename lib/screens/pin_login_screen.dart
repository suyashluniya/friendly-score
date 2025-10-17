import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'mode_selection_screen.dart';

/// PIN login screen that appears before the main app
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  static const routeName = '/login';
  static const String correctPin = '0000';

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final List<String> _enteredPin = [];
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(number);
        _isError = false;
      });

      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // Check if PIN is complete
      if (_enteredPin.length == 4) {
        _checkPin();
      }
    }
  }

  void _checkPin() {
    final enteredPinString = _enteredPin.join();

    if (enteredPinString == PinLoginScreen.correctPin) {
      // Correct PIN - navigate to main app
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacementNamed(ModeSelectionScreen.routeName);
    } else {
      // Wrong PIN - show error and reset
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
      });

      // Clear PIN after a delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _enteredPin.clear();
          _isError = false;
        });
      });
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _isError = false;
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Title
              Text(
                'Timing App',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter PIN to continue',
                style: Theme.of(context).textTheme.bodyLarge,
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: 64),

              // PIN Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < _enteredPin.length
                              ? (_isError ? const Color(0xFFEF4444) : const Color(0xFF0066FF))
                              : const Color(0xFFE5E7EB),
                        ),
                      )
                      .animate(target: _isError ? 1 : 0)
                      .shake(duration: 500.ms, hz: 4);
                }),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

              if (_isError) ...[
                const SizedBox(height: 20),
                Text(
                  'Incorrect PIN. Try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ],

              const SizedBox(height: 64),

              // Number Pad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    // Empty space
                    return const SizedBox();
                  } else if (index == 10) {
                    // Zero button
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    // Delete button
                    return _buildDeleteButton();
                  } else {
                    // Number buttons 1-9
                    return _buildNumberButton('${index + 1}');
                  }
                },
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

              const Spacer(),

              // Hint text
              Text(
                'Default PIN: 0000',
                style: Theme.of(context).textTheme.bodySmall,
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}
