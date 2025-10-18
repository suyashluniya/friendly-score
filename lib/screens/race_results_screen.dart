import 'package:flutter/material.dart';
import 'rider_details_screen.dart';
import '../services/location_service.dart';
import '../services/mode_service.dart';
import '../services/unified_race_data_service.dart';

class RaceResultsScreen extends StatefulWidget {
  const RaceResultsScreen({
    super.key,
    required this.elapsedSeconds,
    required this.maxSeconds,
    required this.riderName,
    required this.eventName,
    required this.horseName,
    required this.horseId,
    required this.additionalDetails,
    required this.isSuccess,
  });

  static const routeName = '/race-results';

  final int elapsedSeconds;
  final int maxSeconds;
  final String riderName;
  final String eventName;
  final String horseName;
  final String horseId;
  final String additionalDetails;
  final bool isSuccess;

  @override
  State<RaceResultsScreen> createState() => _RaceResultsScreenState();
}

class _RaceResultsScreenState extends State<RaceResultsScreen> {
  bool _isSaving = false;

  Future<void> _saveRaceData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Use the unified race data service
      final unifiedDataService = UnifiedRaceDataService();

      final success = await unifiedDataService.saveRaceData(
        riderName: widget.riderName,
        eventName: widget.eventName,
        horseName: widget.horseName,
        horseId: widget.horseId,
        additionalDetails: widget.additionalDetails,
        elapsedSeconds: widget.elapsedSeconds,
        maxSeconds: widget.maxSeconds,
        isSuccess: widget.isSuccess,
      );

      if (!success) {
        throw Exception('Failed to save race data to unified storage');
      }

      print('✅ Race data saved to unified storage');

      if (mounted) {
        // Get file path for display
        final filePath = await unifiedDataService.getDataFilePath();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Race data saved to unified storage!\n$filePath'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving race data: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to save: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Race Results'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Success/Failure Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: widget.isSuccess
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.isSuccess ? Icons.check_circle : Icons.access_time,
                  color: widget.isSuccess
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Result Title
              Text(
                widget.isSuccess ? 'Race Completed!' : 'Time Exceeded',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isSuccess
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Time Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.isSuccess
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Time Taken',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatTime(widget.elapsedSeconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Max: ${_formatTime(widget.maxSeconds)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rider Details Card
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: Colors.amber.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Race Details',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.person,
                      'Rider',
                      widget.riderName,
                      Colors.blue.shade600,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      context,
                      Icons.pets,
                      'Horse',
                      '${widget.horseName} (${widget.horseId})',
                      Colors.brown.shade600,
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      context,
                      Icons.event,
                      'Event',
                      widget.eventName,
                      Colors.purple.shade600,
                    ),
                    const Divider(height: 20),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: LocationService().loadLocation(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final location = snapshot.data!;
                          final locationDisplay =
                              '${location['locationName']} - ${location['address']}';
                          return Column(
                            children: [
                              _buildDetailRow(
                                context,
                                Icons.location_on,
                                'Location',
                                locationDisplay,
                                Colors.green.shade600,
                              ),
                              const Divider(height: 20),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    _buildDetailRow(
                      context,
                      Icons.sports,
                      'Mode',
                      ModeService().getModeDisplayName(),
                      Colors.orange.shade600,
                    ),
                    if (widget.additionalDetails.isNotEmpty) ...[
                      const Divider(height: 20),
                      _buildDetailRow(
                        context,
                        Icons.info_outline,
                        'Notes',
                        widget.additionalDetails,
                        Colors.grey.shade600,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveRaceData,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'SAVING...' : 'SAVE'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Calculate original selected time from maxSeconds (maxSeconds = selectedSeconds * 2)
                        int totalMaxSeconds = widget.maxSeconds;
                        int selectedTotalSeconds = totalMaxSeconds ~/ 2;

                        int nextSelectedHours = selectedTotalSeconds ~/ 3600;
                        int nextSelectedMinutes =
                            (selectedTotalSeconds % 3600) ~/ 60;
                        int nextSelectedSeconds = selectedTotalSeconds % 60;

                        int nextMaxHours = totalMaxSeconds ~/ 3600;
                        int nextMaxMinutes = (totalMaxSeconds % 3600) ~/ 60;
                        int nextMaxSeconds = totalMaxSeconds % 60;

                        // Navigate to rider details for next rider
                        Navigator.of(context).pushNamed(
                          RiderDetailsScreen.routeName,
                          arguments: {
                            'selectedHours': nextSelectedHours,
                            'selectedMinutes': nextSelectedMinutes,
                            'selectedSeconds': nextSelectedSeconds,
                            'maxHours': nextMaxHours,
                            'maxMinutes': nextMaxMinutes,
                            'maxSeconds': nextMaxSeconds,
                          },
                        );
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('NEXT'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
}
