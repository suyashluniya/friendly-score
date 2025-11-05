import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'timer_start_screen.dart';
import '../services/bluetooth_service.dart';
import '../services/mode_service.dart';

class RiderDetailsScreen extends StatefulWidget {
  const RiderDetailsScreen({
    super.key,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.selectedSeconds,
    required this.maxHours,
    required this.maxMinutes,
    required this.maxSeconds,
  });

  static const routeName = '/rider-details';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;
  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;

  @override
  State<RiderDetailsScreen> createState() => _RiderDetailsScreenState();
}

class _RiderDetailsScreenState extends State<RiderDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _riderNameController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _horseNameController = TextEditingController();
  final _horseIdController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  @override
  void dispose() {
    _riderNameController.dispose();
    _eventNameController.dispose();
    _horseNameController.dispose();
    _horseIdController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  Future<void> _sendDeviceResetSignal() async {
    print('🔄 RIDER DETAILS: _sendDeviceResetSignal() method called');
    final btService = BluetoothService();
    final modeService = ModeService();

    // Send reset signal based on current mode
    // SHOW_JUMPING -> d0,e0
    // MOUNTED_SPORTS -> d0,e1
    final selectedMode = modeService.getMode();
    print('🔄 RIDER DETAILS: Current mode is: $selectedMode');
    String payload;

    if (selectedMode == ModeService.showJumping) {
      payload = 'd0,e0';
    } else if (selectedMode == ModeService.mountedSports) {
      payload = 'd0,e1';
    } else {
      payload = 'd0,e0'; // Default fallback
    }

    print('🔄 RIDER DETAILS: About to send payload: $payload');
    print('🔄 RIDER DETAILS: Bluetooth connected: ${btService.isConnected}');
    bool sent = await btService.sendData(payload);
    if (sent) {
      print(
        '✅ RIDER DETAILS: Device reset signal sent successfully: $payload (mode=$selectedMode)',
      );
    } else {
      print(
        '❌ RIDER DETAILS: Failed to send device reset signal (mode=$selectedMode, payload=$payload)',
      );
    }
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      print('🔄 RIDER DETAILS: About to send device reset signal...');
      // Send device reset signal for next rider setup
      await _sendDeviceResetSignal();
      print('🔄 RIDER DETAILS: Device reset signal completed');
      
      if (mounted) {
        Navigator.of(context).pushNamed(
          TimerStartScreen.routeName,
          arguments: {
            'selectedHours': widget.selectedHours,
            'selectedMinutes': widget.selectedMinutes,
            'selectedSeconds': widget.selectedSeconds,
            'maxHours': widget.maxHours,
            'maxMinutes': widget.maxMinutes,
            'maxSeconds': widget.maxSeconds,
            'riderName': _riderNameController.text,
            'eventName': _eventNameController.text,
            'horseName': _horseNameController.text,
            'horseId': _horseIdController.text,
            'additionalDetails': _additionalDetailsController.text,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Details'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: Color(0xFF0066FF),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time Set: ${_formatTime(widget.selectedHours, widget.selectedMinutes, widget.selectedSeconds)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Max: ${_formatTime(widget.maxHours, widget.maxMinutes, widget.maxSeconds)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                        const SizedBox(height: 40),

                        // Form Fields
                        _buildInputField(
                              controller: _riderNameController,
                              label: 'Rider Name',
                              icon: Icons.person,
                              hint: 'Enter rider\'s full name',
                              isRequired: true,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideX(begin: -0.2),

                        const SizedBox(height: 20),

                        _buildInputField(
                              controller: _eventNameController,
                              label: 'Event Name',
                              icon: Icons.event,
                              hint: 'Enter event or competition name',
                              isRequired: true,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms)
                            .slideX(begin: 0.2),

                        const SizedBox(height: 20),

                        _buildInputField(
                              controller: _horseNameController,
                              label: 'Horse Name',
                              icon: Icons.pets,
                              hint: 'Enter horse\'s name',
                              isRequired: true,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideX(begin: -0.2),

                        const SizedBox(height: 20),

                        _buildInputField(
                              controller: _horseIdController,
                              label: 'Horse ID / Registration',
                              icon: Icons.badge,
                              hint: 'Enter horse ID or registration number',
                              isRequired: true,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideX(begin: 0.2),

                        const SizedBox(height: 20),

                        _buildInputField(
                              controller: _additionalDetailsController,
                              label: 'Additional Details',
                              icon: Icons.notes,
                              hint: 'Any additional notes or details',
                              isRequired: false,
                              maxLines: 3,
                            )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Save & Continue'),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 20,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required bool isRequired,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6C757D)),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 16),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
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
