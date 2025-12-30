import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'event_location_screen.dart';

/// Modern PIN login screen with Blinkit-inspired design
class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  static const routeName = '/login';
  static const String correctPin = '0000';

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _enteredPin = [];
  bool _isError = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin.add(number);
        _isError = false;
      });

      HapticFeedback.lightImpact();

      if (_enteredPin.length == 4) {
        _checkPin();
      }
    }
  }

  void _checkPin() {
    final enteredPinString = _enteredPin.join();

    if (enteredPinString == PinLoginScreen.correctPin) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacementNamed(EventLocationScreen.routeName);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isError = true;
      });
      _shakeController.forward(from: 0);

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _enteredPin.clear();
            _isError = false;
          });
        }
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // App Icon with gradient background
                  Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 48,
                        ),
                      )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 40),

                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                        begin: 0.2,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 8),

                  Text(
                    'Enter your PIN to continue',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: 48),

                  // PIN Dots
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final shakeValue =
                          _shakeController.isAnimating
                              ? (1 - _shakeController.value) *
                                  10 *
                                  ((_shakeController.value * 20).floor() % 2 ==
                                          0
                                      ? 1
                                      : -1)
                              : 0.0;
                      return Transform.translate(
                        offset: Offset(shakeValue, 0),
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _enteredPin.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          width: isFilled ? 18 : 16,
                          height: isFilled ? 18 : 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled
                                ? (_isError
                                    ? AppColors.error
                                    : AppColors.primary)
                                : Colors.transparent,
                            border: Border.all(
                              color: _isError
                                  ? AppColors.error
                                  : (isFilled
                                      ? AppColors.primary
                                      : AppColors.border),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                  // Error Message
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _isError
                        ? Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Incorrect PIN. Try again.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox(height: 0),
                  ),

                  const SizedBox(height: 48),

                  // Number Pad
                  _buildNumberPad()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 500.ms),

                  const SizedBox(height: 40),

                  // Hint text
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Default PIN: 0000',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('1'),
            const SizedBox(width: 24),
            _buildNumberButton('2'),
            const SizedBox(width: 24),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('4'),
            const SizedBox(width: 24),
            _buildNumberButton('5'),
            const SizedBox(width: 24),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberButton('7'),
            const SizedBox(width: 24),
            _buildNumberButton('8'),
            const SizedBox(width: 24),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        // Row 4: empty, 0, delete
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 72, height: 72),
            const SizedBox(width: 24),
            _buildNumberButton('0'),
            const SizedBox(width: 24),
            _buildDeleteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onDeletePressed,
        borderRadius: BorderRadius.circular(36),
        splashColor: AppColors.error.withOpacity(0.1),
        highlightColor: AppColors.error.withOpacity(0.05),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
