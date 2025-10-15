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
    required this.eventName,
    required this.horseName,
    required this.horseId,
    required this.additionalDetails,
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
  final String eventName;
  final String horseName;
  final String horseId;
  final String additionalDetails;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Connection Failed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bluetooth_disabled,
                        color: Colors.red.shade600,
                        size: 60,
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
                            color: Colors.red.shade700,
                          ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 16),

                // Error Details Card
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unable to connect to IR-Timer-Module',
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
                            'Ensure IR-Timer-Module is powered on',
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
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _retryConnection(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Retry Connection',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    // Settings Button
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _openBluetoothSettings(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Open Bluetooth Settings',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                              ],
                            ),
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
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: Colors.grey.shade600),
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
      SnackBar(
        content: const Text(
          'This would open device Bluetooth settings in a real app',
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
