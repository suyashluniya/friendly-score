import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import 'active_race_screen.dart';

class BluetoothReadyScreen extends StatefulWidget {
  const BluetoothReadyScreen({
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
  });

  static const routeName = '/bluetooth-ready';

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

  @override
  State<BluetoothReadyScreen> createState() => _BluetoothReadyScreenState();
}

class _BluetoothReadyScreenState extends State<BluetoothReadyScreen> {
  StreamSubscription? _bluetoothSubscription;

  @override
  void initState() {
    super.initState();
    _listenForStartSignal();
  }

  void _listenForStartSignal() {
    final btService = BluetoothService();
    _bluetoothSubscription = btService.messageStream.listen((message) {
      print('📨 Ready screen received: $message');

      if (message.contains('START')) {
        print('🏁 START signal received - Starting race!');
        _startRace();
      }
    });
  }

  void _startRace() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        ActiveRaceScreen.routeName,
        arguments: {
          'maxHours': widget.maxHours,
          'maxMinutes': widget.maxMinutes,
          'maxSeconds': widget.maxSeconds,
          'riderName': widget.riderName,
          'eventName': widget.eventName,
          'horseName': widget.horseName,
          'horseId': widget.horseId,
          'additionalDetails': widget.additionalDetails,
        },
      );
    }
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Armed'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Success Animation
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bluetooth_connected,
                      color: Color(0xFF10B981),
                      size: 64,
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 40),

              // Main Status Message
              Text(
                    'Application Armed!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 20),

              // Detailed Status
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
                      children: [
                        Text(
                          'The application is armed with the hardware and the rider can now start the race',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Connection Status
                        Row(
                          children: [
                            Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(duration: 2000.ms),
                            const SizedBox(width: 12),
                            Text(
                              'Hardware Connected',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Bluetooth: ESP32-BT-Client',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 40),

              // Rider Info Summary
              Container(
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
                  children: [
                    Text(
                      'Race Setup Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Rider', widget.riderName),
                    _buildSummaryRow('Horse', '${widget.horseName} (${widget.horseId})'),
                    _buildSummaryRow('Event', widget.eventName),
                    _buildSummaryRow(
                      'Time',
                      _formatTime(
                        widget.selectedHours,
                        widget.selectedMinutes,
                        widget.selectedSeconds,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 32),

              // Ready Indicator
              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'SYSTEM READY',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .scale(curve: Curves.elasticOut),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hours, int minutes, int seconds) {
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
