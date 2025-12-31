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
    required this.riderNumber,
    required this.photoPath,
    this.raceType,
  });

  static const routeName = '/bluetooth-ready';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;
  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String riderName;
  final String riderNumber;
  final String photoPath;
  final String? raceType; // 'startFinish' or 'startVerifyFinish' for Mounted Sports

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
      if (message.contains('START')) {
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
          'riderNumber': widget.riderNumber,
          'photoPath': widget.photoPath,
          'raceType': widget.raceType,
        },
      );
    }
  }

  bool get _isMountedSports => widget.raceType != null;

  Future<void> _showDisarmConfirmation() async {
    final bool? shouldDisarm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disarm Device'),
          content: const Text(
            'Do you really want to disarm the device? This will stop the system and return to home.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Disarm'),
            ),
          ],
        );
      },
    );

    if (shouldDisarm == true) {
      await _disarmDevice();
    }
  }

  Future<void> _disarmDevice() async {
    final btService = BluetoothService();

    bool sent = await btService.sendData('d1,e0');
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Device has been manually disarmed')),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Failed to disarm device. Please try again.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      appBar: AppBar(title: const Text('System Armed')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

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
                    if (widget.riderName.isNotEmpty)
                      _buildSummaryRow('Rider', widget.riderName),
                    if (widget.riderNumber.isNotEmpty)
                      _buildSummaryRow('Number', widget.riderNumber),
                    if (_isMountedSports) ...[
                      _buildSummaryRow(
                        'Race Type',
                        widget.raceType == 'startVerifyFinish'
                            ? 'Start → Verify → Finish'
                            : 'Start → Finish',
                      ),
                      _buildSummaryRow('Timer', 'Starts from 0:00:00'),
                    ] else
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
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SYSTEM READY',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.white, letterSpacing: 1),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .scale(curve: Curves.elasticOut),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: _showDisarmConfirmation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.power_settings_new,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'DISARM DEVICE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.red,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

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
