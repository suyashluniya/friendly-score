import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/pin_service.dart';

/// Screen for resetting PIN using master password
class ForgotPinScreen extends StatefulWidget {
  const ForgotPinScreen({super.key});

  static const routeName = '/forgot-pin';

  @override
  State<ForgotPinScreen> createState() => _ForgotPinScreenState();
}

class _ForgotPinScreenState extends State<ForgotPinScreen> {
  final TextEditingController _phraseController = TextEditingController();
  final PinService _pinService = PinService();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndReset() async {
    final phrase = _phraseController.text.trim();

    if (phrase.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the master password';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final isValid = await _pinService.verifyMasterReset(phrase);

    if (mounted) {
      if (isValid) {
        // Reset PIN to default
        await _pinService.resetToDefault();

        // Show success dialog
        _showSuccessDialog();
      } else {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Incorrect master password. Please try again.';
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('PIN Reset Successful'),
        content: const Text('Your PIN has been reset to the default: 0000\n\nPlease use this PIN to log in.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to login
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // Icon
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ).animate().scale(duration: 400.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                'Master Password Required',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Description
              Text(
                'Enter the master password to reset your PIN to the default value (0000).',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 48),

              // Master password input
              TextField(
                controller: _phraseController,
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  hintText: 'Enter master password',
                  prefixIcon: const Icon(Icons.key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _errorMessage,
                ),
                obscureText: true,
                enabled: !_isVerifying,
                onSubmitted: (_) => _verifyAndReset(),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -0.1),

              const SizedBox(height: 32),

              // Reset button
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndReset,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Reset PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1),

              const Spacer(),

              // Warning text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Only administrators should have access to the master password.',
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
