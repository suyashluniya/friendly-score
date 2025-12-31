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
    this.raceType,
  });

  static const routeName = '/rider-details';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;
  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String? raceType; // 'startFinish' or 'startVerifyFinish' for Mounted Sports, null for Show Jumping

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
    final btService = BluetoothService();
    final modeService = ModeService();
    final selectedMode = modeService.getMode();
    String payload;

    if (selectedMode == ModeService.showJumping) {
      payload = 'd0,e0';
    } else if (selectedMode == ModeService.mountedSports) {
      payload = 'd0,e1';
    } else {
      payload = 'd0,e0';
    }

    await btService.sendData(payload);
  }

  String _generateDummyRiderNumber() {
    final now = DateTime.now();
    return '${now.hour}${now.minute}${now.second}';
  }

  void _handleSave() async {
    if (_capturedImage == null || !_isPhotoAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture and accept a photo before continuing'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await _sendDeviceResetSignal();

      // Use dummy values if name/number are empty
      final riderName = _riderNameController.text.trim().isEmpty
          ? 'Unknown Rider'
          : _riderNameController.text.trim();
      final riderNumber = _riderNumberController.text.trim().isEmpty
          ? _generateDummyRiderNumber()
          : _riderNumberController.text.trim();

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
            'riderName': riderName,
            'riderNumber': riderNumber,
            'photoPath': _capturedImage!.path,
            'raceType': widget.raceType,
          },
        );
      }
    }
  }

  bool get _isMountedSports => widget.raceType != null;

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
                        if (!_isMountedSports) ...[
                          _buildTimeSummary(),
                          const SizedBox(height: 24),
                        ],
                        if (_isMountedSports) ...[
                          _buildRaceTypeInfo(),
                          const SizedBox(height: 24),
                        ],
                        _buildPhotoSection()
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 32),
                        _buildInputField(
                              controller: _riderNameController,
                              label: 'Rider Name (optional)',
                              icon: Icons.person,
                              hint: 'Enter rider name',
                              isRequired: false,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 100.ms)
                            .slideX(begin: -0.2),
                        const SizedBox(height: 20),
                        _buildInputField(
                              controller: _riderNumberController,
                              label: 'Rider Number (optional)',
                              icon: Icons.numbers,
                              hint: 'Enter rider number',
                              isRequired: false,
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideX(begin: 0.2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_capturedImage != null && _isPhotoAccepted)
                            ? _handleSave
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_capturedImage != null && _isPhotoAccepted)
                              ? null
                              : const Color(0xFFE5E7EB),
                      foregroundColor:
                          (_capturedImage != null && _isPhotoAccepted)
                              ? null
                              : const Color(0xFF9CA3AF),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Save & Continue'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSummary() {
    return Container(
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
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Max: ${_formatTime(widget.maxHours, widget.maxMinutes, widget.maxSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRaceTypeInfo() {
    final isVerifyMode = widget.raceType == 'startVerifyFinish';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerifyMode ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerifyMode ? Icons.checklist_rounded : Icons.flag_rounded,
            color: isVerifyMode ? const Color(0xFF8B5CF6) : const Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerifyMode ? 'Start → Verify → Finish' : 'Start → Finish',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  isVerifyMode
                      ? 'Race with verification checkpoint'
                      : 'Simple race from start to finish',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Timer starts from 0:00:00',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6C757D),
                      ),
                ),
              ],
            ),
          ),
        ],
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
              Expanded(
                child: Text(
                  'Horse with Rider Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 16),
              ),
              if (_isPhotoAccepted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
