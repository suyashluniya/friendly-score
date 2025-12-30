import 'package:demo/services/location_service.dart';
import 'package:demo/services/mode_service.dart';
import 'package:flutter/material.dart';
import 'rider_details_screen.dart';
import '../services/unified_race_data_service.dart';

class RaceResultsScreen extends StatefulWidget {
  const RaceResultsScreen({
    super.key,
    required this.elapsedSeconds,
    this.elapsedHours = 0,
    this.elapsedMinutes = 0,
    this.elapsedSecondsOnly = 0,
    this.elapsedMilliseconds = 0,
    required this.maxSeconds,
    required this.riderName,
    required this.riderNumber,
    required this.photoPath,
    required this.isSuccess,
    this.raceStatus,
  });

  static const routeName = '/race-results';

  final int elapsedSeconds;
  final int elapsedHours;
  final int elapsedMinutes;
  final int elapsedSecondsOnly;
  final int elapsedMilliseconds;
  final int maxSeconds;
  final String riderName;
  final String riderNumber;
  final String photoPath;
  final bool isSuccess;
  final String? raceStatus;

  @override
  State<RaceResultsScreen> createState() => _RaceResultsScreenState();
}

class _RaceResultsScreenState extends State<RaceResultsScreen> {
  bool _isSaving = false;
  bool _isSaved = false;

  bool get _isStoppedRace => widget.raceStatus == 'stopped';

  Color _getResultColor() {
    if (_isStoppedRace) {
      return const Color(0xFFEF4444); // Red for stopped
    } else if (widget.isSuccess) {
      return const Color(0xFF10B981); // Green for success
    } else {
      return const Color(0xFFF59E0B); // Orange for time exceeded
    }
  }

  IconData _getResultIcon() {
    if (_isStoppedRace) {
      return Icons.stop_circle;
    } else if (widget.isSuccess) {
      return Icons.check_circle;
    } else {
      return Icons.access_time;
    }
  }

  String _getResultTitle() {
    if (_isStoppedRace) {
      return 'Race Stopped';
    } else if (widget.isSuccess) {
      return 'Race Completed!';
    } else {
      return 'Time Exceeded';
    }
  }

  Future<void> _saveRaceData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final dataService = UnifiedRaceDataService();

      final success = await dataService.saveRaceData(
        riderName: widget.riderName,
        riderNumber: widget.riderNumber,
        photoPath: widget.photoPath,
        elapsedSeconds: widget.elapsedSeconds,
        maxSeconds: widget.maxSeconds,
        isSuccess: widget.isSuccess,
        elapsedHours: widget.elapsedHours,
        elapsedMinutes: widget.elapsedMinutes,
        elapsedSecondsOnly: widget.elapsedSecondsOnly,
        elapsedMilliseconds: widget.elapsedMilliseconds,
        raceStatus: widget.raceStatus,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          setState(() {
            _isSaved = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Race data saved to unified database!')),
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to save race data. Please try again.'),
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
    } catch (e) {
      print('Error saving race data: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error saving data: $e')),
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

              // Success/Failure/Stopped Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _getResultColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _getResultIcon(),
                  color: _getResultColor(),
                  size: 48,
                ),
              ),

              const SizedBox(height: 24),

              // Result Title
              Text(
                _getResultTitle(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getResultColor(),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Time Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getResultColor(),
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
                    Column(
                      children: [
                        Text(
                          _formatTimeWithMilliseconds(),
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    42, // Slightly smaller to fit milliseconds
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
                        // Time labels
                        _buildTimeLabels(),
                      ],
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
                    if (widget.riderName.isNotEmpty) ...[
                      _buildDetailRow(
                        context,
                        Icons.person,
                        'Rider',
                        widget.riderName,
                        Colors.blue.shade600,
                      ),
                      const Divider(height: 20),
                    ],
                    if (widget.riderNumber.isNotEmpty) ...[
                      _buildDetailRow(
                        context,
                        Icons.numbers,
                        'Number',
                        widget.riderNumber,
                        Colors.indigo.shade600,
                      ),
                      const Divider(height: 20),
                    ],
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: _isSaved
                          ? 'Race data has already been saved to prevent duplicates'
                          : 'Save this race data to the unified database',
                      child: ElevatedButton.icon(
                        onPressed: (_isSaving || _isSaved)
                            ? null
                            : _saveRaceData,
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
                            : _isSaved
                            ? const Icon(Icons.check_circle_outline)
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving
                              ? 'SAVING...'
                              : _isSaved
                              ? 'SAVED'
                              : 'SAVE',
                        ),
                        style: _isSaved
                            ? ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
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

  String _formatTimeWithMilliseconds() {
    // Use the detailed time data if available, otherwise fall back to parsing elapsedSeconds
    if (widget.elapsedHours > 0 ||
        widget.elapsedMinutes > 0 ||
        widget.elapsedSecondsOnly > 0 ||
        widget.elapsedMilliseconds > 0) {
      // Always take only the first 2 digits of milliseconds, regardless of length
      final millisStr = widget.elapsedMilliseconds.toString();
      final millis = millisStr.length >= 2
          ? millisStr.substring(0, 2)
          : millisStr.padLeft(2, '0');

      // Don't show hours if they are 00
      if (widget.elapsedHours > 0) {
        return '${widget.elapsedHours.toString().padLeft(2, '0')}:${widget.elapsedMinutes.toString().padLeft(2, '0')}:${widget.elapsedSecondsOnly.toString().padLeft(2, '0')}:$millis';
      } else {
        return '${widget.elapsedMinutes.toString().padLeft(2, '0')}:${widget.elapsedSecondsOnly.toString().padLeft(2, '0')}:$millis';
      }
    } else {
      // Fallback for backward compatibility
      int hours = widget.elapsedSeconds ~/ 3600;
      int minutes = (widget.elapsedSeconds % 3600) ~/ 60;
      int secs = widget.elapsedSeconds % 60;

      // Don't show hours if they are 0
      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}:00';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}:00';
      }
    }
  }

  Widget _buildTimeLabels() {
    // Determine which time format is being used
    bool hasHours = widget.elapsedHours > 0;
    bool hasDetailedTime = widget.elapsedHours > 0 ||
        widget.elapsedMinutes > 0 ||
        widget.elapsedSecondsOnly > 0 ||
        widget.elapsedMilliseconds > 0;

    if (!hasDetailedTime) {
      // Fallback format calculation
      hasHours = (widget.elapsedSeconds ~/ 3600) > 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasHours) ...[
          _buildTimeLabel('HH'),
          _buildTimeSeparator(),
        ],
        _buildTimeLabel('MM'),
        _buildTimeSeparator(),
        _buildTimeLabel('SS'),
        _buildTimeSeparator(),
        _buildTimeLabel('MS'),
      ],
    );
  }

  Widget _buildTimeLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTimeSeparator() {
    return const SizedBox(
      width: 16,
      child: Text(
        ':',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.transparent, // Hidden separator for spacing
          fontSize: 12,
        ),
      ),
    );
  }
}
