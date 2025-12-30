import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BluetoothFailedScreen extends StatelessWidget {
  const BluetoothFailedScreen({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.selectedSeconds,
    required this.maxHours,
    required this.maxMinutes,
    required this.maxSeconds,
    required this.riderName,
    required this.riderNumber,
    required this.photoPath,
    required this.errorMessage,
  });

  static const routeName = '/bluetooth-failed';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;
  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String riderName;
  final String riderNumber;
  final String photoPath;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Failed'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight -
                  48, // Account for padding
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Error Animation
                Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bluetooth_disabled,
                        color: Color(0xFFEF4444),
                        size: 64,
                      ),
                    )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: 40),

                // Error Title
                Text(
                      'Hardware Connection Failed',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 20),

                // Error Details Card
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unable to connect to ESP32-BT-Client',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                          const SizedBox(height: 12),

                          // Troubleshooting Steps
                          Text(
                            'Troubleshooting Steps:',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),

                          const SizedBox(height: 12),

                          _buildTroubleshootingStep(
                            context,
                            '1.',
                            'Ensure ESP32-BT-Client is powered on',
                            Icons.power_settings_new,
                          ),

                          _buildTroubleshootingStep(
                            context,
                            '2.',
                            'Check that Bluetooth is enabled on your device',
                            Icons.bluetooth,
                          ),

                          _buildTroubleshootingStep(
                            context,
                            '3.',
                            'Make sure the timer module is within range (10m)',
                            Icons.radar,
                          ),

                          _buildTroubleshootingStep(
                            context,
                            '4.',
                            'Verify the device is not connected to another phone',
                            Icons.smartphone,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideY(begin: 0.3),

                const SizedBox(height: 40),

                // Action Buttons
                Column(
                  children: [
                    // Retry Button
                    SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _retryConnection(context),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry Connection'),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    // Settings Button
                    SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _openBluetoothSettings(context),
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Open Bluetooth Settings'),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 700.ms)
                        .slideY(begin: 0.3),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingStep(
    BuildContext context,
    String number,
    String instruction,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0066FF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: const Color(0xFF6C757D)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retryConnection(BuildContext context) {
    // Navigate back to timer start screen to retry connection
    Navigator.of(context).pop();
  }

  void _openBluetoothSettings(BuildContext context) {
    // In a real app, this would open device Bluetooth settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This would open device Bluetooth settings in a real app',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
