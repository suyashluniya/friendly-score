import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
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
  final _riderNumberController = TextEditingController();

  File? _capturedImage;
  bool _isPhotoAccepted = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _riderNameController.dispose();
    _riderNumberController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _isPhotoAccepted = false;
        });
      }
      // If null, user cancelled - no message needed
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture photo: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _acceptPhoto() {
    setState(() {
      _isPhotoAccepted = true;
    });
  }

  void _retakePhoto() {
    _capturePhoto();
  }

  Future<void> _sendDeviceResetSignal() async {
    print('🔄 RIDER DETAILS: _sendDeviceResetSignal() method called');
    final btService = BluetoothService();
    final modeService = ModeService();

    final selectedMode = modeService.getMode();
    print('🔄 RIDER DETAILS: Current mode is: $selectedMode');
    String payload;

    if (selectedMode == ModeService.showJumping) {
      payload = 'd0,e0';
    } else if (selectedMode == ModeService.mountedSports) {
      payload = 'd0,e1';
    } else {
      payload = 'd0,e0';
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
    // Validate photo is captured and accepted
    if (_capturedImage == null || !_isPhotoAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture and accept a photo before continuing'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    print('🔄 RIDER DETAILS: About to send device reset signal...');
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
          'riderName': _riderNameController.text.trim(),
          'riderNumber': _riderNumberController.text.trim(),
          'photoPath': _capturedImage!.path,
          // Keep empty values for backwards compatibility
          'eventName': '',
          'horseName': '',
          'horseId': '',
          'additionalDetails': '',
        },
      );
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

                        const SizedBox(height: 32),

                        // Photo Capture Section (Mandatory)
                        _buildPhotoSection()
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        // Optional Fields Section
                        Text(
                          'Optional Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C757D),
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _riderNameController,
                          label: 'Rider Name',
                          icon: Icons.person,
                          hint: 'Enter rider\'s name (optional)',
                          isRequired: false,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms)
                            .slideX(begin: -0.2),

                        const SizedBox(height: 20),

                        _buildInputField(
                          controller: _riderNumberController,
                          label: 'Rider Number',
                          icon: Icons.numbers,
                          hint: 'Enter rider\'s number (optional)',
                          isRequired: false,
                          keyboardType: TextInputType.text,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 500.ms)
                            .slideX(begin: 0.2),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_capturedImage != null && _isPhotoAccepted)
                        ? _handleSave
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_capturedImage != null && _isPhotoAccepted)
                          ? const Color(0xFF0066FF)
                          : const Color(0xFFE5E7EB),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Save & Continue',
                          style: TextStyle(
                            color: (_capturedImage != null && _isPhotoAccepted)
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: (_capturedImage != null && _isPhotoAccepted)
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPhotoAccepted
              ? const Color(0xFF10B981)
              : const Color(0xFFE5E7EB),
          width: _isPhotoAccepted ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                size: 20,
                color: _isPhotoAccepted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF6C757D),
              ),
              const SizedBox(width: 8),
              Text(
                'Horse with Rider Photo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 16),
              ),
              const Spacer(),
              if (_isPhotoAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Accepted',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_capturedImage == null) ...[
            // No photo captured yet - show capture button
            GestureDetector(
              onTap: _capturePhoto,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to capture photo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a photo of horse with rider',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Photo captured - show preview with retake/accept buttons
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    _capturedImage!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (_isPhotoAccepted)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF10B981),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Retake and Accept buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _retakePhoto,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C757D),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPhotoAccepted ? null : _acceptPhoto,
                    icon: Icon(
                      _isPhotoAccepted ? Icons.check_circle : Icons.check,
                    ),
                    label: Text(_isPhotoAccepted ? 'Accepted' : 'Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPhotoAccepted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
