import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'timer_start_screen.dart';

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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Rider Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.blue.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
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
                                            color: Colors.black87,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Max: ${_formatTime(widget.maxHours, widget.maxMinutes, widget.maxSeconds)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

                        const SizedBox(height: 32),

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
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save & Continue',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
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
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(color: Colors.red.shade600, fontSize: 16),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
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
