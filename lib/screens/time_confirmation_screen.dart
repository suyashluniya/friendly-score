import 'package:flutter/material.dart';
import 'rider_details_screen.dart';

class TimeConfirmationScreen extends StatelessWidget {
  const TimeConfirmationScreen({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.selectedSeconds,
  });

  static const routeName = '/time-confirmation';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;

  int get _maxTimeHours =>
      (selectedHours * 2) +
      ((selectedMinutes * 2) ~/ 60) +
      ((selectedSeconds * 2) ~/ 3600);
  int get _maxTimeMinutes =>
      ((selectedMinutes * 2) + ((selectedSeconds * 2) ~/ 60)) % 60;
  int get _maxTimeSeconds => (selectedSeconds * 2) % 60;

  String _formatTime(int hours, int minutes, int seconds) {
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Confirmation'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Time Set Successfully!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Selected Time Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0066FF).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selected Time',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF0066FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(
                        selectedHours,
                        selectedMinutes,
                        selectedSeconds,
                      ),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Max Time Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Maximum Time',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(
                        _maxTimeHours,
                        _maxTimeMinutes,
                        _maxTimeSeconds,
                      ),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Auto-set to twice your selected time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      RiderDetailsScreen.routeName,
                      arguments: {
                        'selectedHours': selectedHours,
                        'selectedMinutes': selectedMinutes,
                        'selectedSeconds': selectedSeconds,
                        'maxHours': _maxTimeHours,
                        'maxMinutes': _maxTimeMinutes,
                        'maxSeconds': _maxTimeSeconds,
                      },
                    );
                  },
                  child: const Text('Continue'),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
