import 'dart:io';
import 'package:demo/services/location_service.dart';
import 'package:demo/services/mode_service.dart';
import 'package:flutter/material.dart';
import 'mode_selection_screen.dart';
import 'jumping_screen.dart';
import 'top_score_screen.dart';
import 'normal_jumping_screen.dart';
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
  bool get _isDisqualifiedRace => widget.raceStatus == 'disqualified';
  bool get _isFinishedRace => widget.raceStatus == 'finished';

  @override
  void initState() {
    super.initState();
    // Auto-save data when results screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSaveRaceData();
    });
  }

  /// Auto-saves race data and shows confirmation modal
  Future<void> _autoSaveRaceData() async {
    await _saveRaceData();
    
    // Show success modal if saved
    if (mounted && _isSaved) {
      await _showSaveSuccessModal();
    }
  }

  /// Shows a modal dialog confirming data has been saved
  Future<void> _showSaveSuccessModal() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data Saved Successfully!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your race data has been automatically saved to the database.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles navigation - no save check needed since auto-saved
  Future<void> _handleNavigation(VoidCallback onNavigate) async {
    if (mounted) {
      onNavigate();
    }
  }

  Color _getResultColor() {
    if (_isStoppedRace || _isDisqualifiedRace) {
      return const Color(0xFFEF4444);
    } else if (widget.isSuccess || _isFinishedRace) {
      return const Color(0xFF10B981);
    } else {
      return const Color(0xFFF59E0B);
    }
  }

  IconData _getResultIcon() {
    if (_isDisqualifiedRace) {
      return Icons.cancel;
    } else if (_isStoppedRace) {
      return Icons.stop_circle;
    } else if (widget.isSuccess || _isFinishedRace) {
      return Icons.check_circle;
    } else {
      return Icons.access_time;
    }
  }

  String _getResultTitle() {
    if (_isDisqualifiedRace) {
      return 'Race Disqualified';
    } else if (_isStoppedRace) {
      return 'Race Stopped';
    } else if (_isFinishedRace || widget.isSuccess) {
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
    return WillPopScope(
      onWillPop: () async => true, // Allow back navigation since auto-saved
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Race Results'),
          leading: IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              _handleNavigation(() {
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
              const SizedBox(height: 16),
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
              Text(
                _getResultTitle(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getResultColor(),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (widget.photoPath.isNotEmpty && File(widget.photoPath).existsSync()) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.photoPath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 42,
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
                        _buildTimeLabels(),
                      ],
                    ),
                    // Only show max time for Show Jumping mode (when maxSeconds > 0)
                    if (widget.maxSeconds > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Max: ${_formatTime(widget.maxSeconds)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: null, // Disabled since auto-saved
                      icon: _isSaved
                          ? const Icon(Icons.check_circle_outline)
                          : _isSaving
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
                      label: Text(
                        _isSaving
                            ? 'SAVING...'
                            : _isSaved
                                ? 'SAVED'
                                : 'SAVE',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaved ? Colors.green.shade600 : null,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _isSaved ? Colors.green.shade600 : Colors.grey.shade400,
                        disabledForegroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _handleNavigation(() {
                          final currentMode = ModeService().getMode();

                          // Navigate with proper back button stack
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            ModeSelectionScreen.routeName,
                            (route) => false,
                          );
                          Navigator.of(context).pushNamed(JumpingScreen.routeName);

                          if (currentMode == ModeService.mountedSports) {
                            // Mounted Sports: Go to Rider Details with correct race type
                            final raceType = ModeService().getRaceType() ?? ModeService.startFinish;
                            Navigator.of(context).pushNamed(
                              RiderDetailsScreen.routeName,
                              arguments: {
                                'selectedHours': 0,
                                'selectedMinutes': 0,
                                'selectedSeconds': 0,
                                'maxHours': 0,
                                'maxMinutes': 0,
                                'maxSeconds': 0,
                                'raceType': raceType,
                              },
                            );
                          } else {
                            // Show Jumping: Go to correct Time Picker based on jumping mode
                            final jumpingMode = ModeService().getJumpingMode();
                            if (jumpingMode == ModeService.normal) {
                              Navigator.of(context).pushNamed(NormalJumpingScreen.routeName);
                            } else {
                              // Default to Top Score
                              Navigator.of(context).pushNamed(TopScoreJumpingScreen.routeName);
                            }
                          }
                        });
                      },
                      icon: const Icon(Icons.sports_outlined),
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
    if (widget.elapsedHours > 0 ||
        widget.elapsedMinutes > 0 ||
        widget.elapsedSecondsOnly > 0 ||
        widget.elapsedMilliseconds > 0) {
      final millisStr = widget.elapsedMilliseconds.toString();
      final millis = millisStr.length >= 2
          ? millisStr.substring(0, 2)
          : millisStr.padLeft(2, '0');

      if (widget.elapsedHours > 0) {
        return '${widget.elapsedHours.toString().padLeft(2, '0')}:${widget.elapsedMinutes.toString().padLeft(2, '0')}:${widget.elapsedSecondsOnly.toString().padLeft(2, '0')}:$millis';
      } else {
        return '${widget.elapsedMinutes.toString().padLeft(2, '0')}:${widget.elapsedSecondsOnly.toString().padLeft(2, '0')}:$millis';
      }
    } else {
      int hours = widget.elapsedSeconds ~/ 3600;
      int minutes = (widget.elapsedSeconds % 3600) ~/ 60;
      int secs = widget.elapsedSeconds % 60;

      if (hours > 0) {
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}:00';
      } else {
        return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}:00';
      }
    }
  }

  Widget _buildTimeLabels() {
    bool hasHours = widget.elapsedHours > 0;
    bool hasDetailedTime = widget.elapsedHours > 0 ||
        widget.elapsedMinutes > 0 ||
        widget.elapsedSecondsOnly > 0 ||
        widget.elapsedMilliseconds > 0;

    if (!hasDetailedTime) {
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
          color: Colors.transparent,
          fontSize: 12,
        ),
      ),
    );
  }
}
