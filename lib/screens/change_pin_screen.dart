import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pin_service.dart';

/// Screen for changing the user's PIN
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  static const routeName = '/change-pin';

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final PinService _pinService = PinService();
  final List<String> _enteredPin = [];
  
  int _currentStep = 0; // 0: verify current, 1: enter new, 2: confirm new
  String _newPin = '';
  bool _isError = false;
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(number);
        _isError = false;
        _errorMessage = '';
      });

      HapticFeedback.lightImpact();

      if (_enteredPin.length == 4) {
        _processPin();
      }
    }
  }

  Future<void> _processPin() async {
    final pinString = _enteredPin.join();

    if (_currentStep == 0) {
      // Verify current PIN
      final isValid = await _pinService.verifyPin(pinString);
      
      if (isValid) {
        HapticFeedback.mediumImpact();
        setState(() {
          _enteredPin.clear();
          _currentStep = 1;
        });
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _errorMessage = 'Incorrect current PIN';
        });
        _clearAfterDelay();
      }
    } else if (_currentStep == 1) {
      // Save new PIN
      HapticFeedback.mediumImpact();
      setState(() {
        _newPin = pinString;
        _enteredPin.clear();
        _currentStep = 2;
      });
    } else if (_currentStep == 2) {
      // Confirm new PIN
      if (pinString == _newPin) {
        // PINs match - save it
        await _pinService.setPin(_newPin);
        HapticFeedback.mediumImpact();
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        HapticFeedback.heavyImpact();
        setState(() {
          _isError = true;
          _errorMessage = 'PINs do not match. Try again.';
        });
        _clearAfterDelay();
      }
    }
  }

  void _clearAfterDelay() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _enteredPin.clear();
          _isError = false;
          _errorMessage = '';
        });
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('PIN Changed Successfully'),
        content: const Text('Your PIN has been updated. Use your new PIN the next time you log in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to settings
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin.removeLast();
        _isError = false;
        _errorMessage = '';
      });
      HapticFeedback.selectionClick();
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter Current PIN';
      case 1:
        return 'Enter New PIN';
      case 2:
        return 'Confirm New PIN';
      default:
        return '';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Verify your identity';
      case 1:
        return 'Choose a new 4-digit PIN';
      case 2:
        return 'Re-enter your new PIN';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 32 : 12,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: index <= _currentStep
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                  );
                }),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                _getStepTitle(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey(_currentStep)).fadeIn(duration: 400.ms).slideY(begin: -0.2),

              const SizedBox(height: 8),

              // Description
              Text(
                _getStepDescription(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ).animate(key: ValueKey('desc_$_currentStep')).fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 48),

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
              ).animate(key: ValueKey('pins_$_currentStep')).fadeIn(duration: 400.ms, delay: 200.ms),

              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 300.ms),
              ],

              const SizedBox(height: 48),

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
                    return const SizedBox();
                  } else if (index == 10) {
                    return _buildNumberButton('0');
                  } else if (index == 11) {
                    return _buildDeleteButton();
                  } else {
                    return _buildNumberButton('${index + 1}');
                  }
                },
              ).animate(key: ValueKey('pad_$_currentStep')).fadeIn(duration: 400.ms, delay: 300.ms),

              const Spacer(),
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
