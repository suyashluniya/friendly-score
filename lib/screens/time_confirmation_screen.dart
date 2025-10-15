import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon
              Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 50,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                    'Time Set Successfully!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Selected Time Display
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Selected Time',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.blue.shade700,
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
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 20),

              // Max Time Display (Non-editable)
              Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock,
                              color: Colors.orange.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Maximum Time (Non-editable)',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.orange.shade700,
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
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Auto-set to twice your selected time',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.orange.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideX(begin: 0.2),

              const Spacer(),

              // Next Button
              SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to rider details screen
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
