import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import '../services/mode_service.dart';
import '../utils/command_protocol.dart';
import 'race_results_screen.dart';

class ActiveRaceScreen extends StatefulWidget {
  const ActiveRaceScreen({
    super.key,
    required this.maxHours,
    required this.maxMinutes,
    required this.maxSeconds,
    required this.riderName,
    required this.riderNumber,
    required this.photoPath,
    this.raceType,
  });

  static const routeName = '/active-race';

  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String riderName;
  final String riderNumber;
  final String photoPath;
  final String? raceType; // 'startFinish' or 'startVerifyFinish' for Mounted Sports

  @override
  State<ActiveRaceScreen> createState() => _ActiveRaceScreenState();
}

class _ActiveRaceScreenState extends State<ActiveRaceScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late int _maxTimeSeconds; // Maximum time (the doubled value)
  late int _timeAllowedSeconds; // Time allowed (half of max)
  late int _elapsedSeconds;
  late DateTime _startTime;
  late AnimationController _pulseController;
  StreamSubscription? _bluetoothSubscription;
  bool _isPaused = false;
  bool _isTopScoreMode = false;
  bool _isInCountdownPhase = false; // Track if Top Score is in countdown phase

  bool get _isMountedSports => widget.raceType != null;

  @override
  void initState() {
    super.initState();

    // Detect if this is Top Score mode
    final modeService = ModeService();
    _isTopScoreMode = !_isMountedSports && modeService.isTopScoreMode();

    if (_isMountedSports) {
      // For Mounted Sports: No max time limit, timer counts from 0 indefinitely
      _maxTimeSeconds = 0; // No limit
      _timeAllowedSeconds = 0;
      _isInCountdownPhase = false;
    } else {
      // For Show Jumping: Use the provided max time
      _maxTimeSeconds =
          (widget.maxHours * 3600) + (widget.maxMinutes * 60) + widget.maxSeconds;
      // Time allowed is half of the maximum time
      _timeAllowedSeconds = _maxTimeSeconds ~/ 2;
      
      // Top Score mode starts with countdown from time allowed
      _isInCountdownPhase = _isTopScoreMode;
    }

    _elapsedSeconds = 0;
    _startTime = DateTime.now();

    // Pulse animation for the timer circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Start the timer (counting up)
    _startTimer();

    // Listen for STOP message from ESP32
    _listenForStopSignal();

    if (_isMountedSports) {
      print(
        '🏁 Mounted Sports Race started! Race type: ${widget.raceType}',
      );
    } else {
      print(
        '🏁 Race started! Time allowed: ${_formatTime(_timeAllowedSeconds)}, Max time: ${_formatTime(_maxTimeSeconds)}',
      );
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;

          // Top Score Mode: Switch from countdown to count-up phase
          if (_isTopScoreMode && _isInCountdownPhase && _elapsedSeconds >= _timeAllowedSeconds) {
            _isInCountdownPhase = false;
            _elapsedSeconds = 0; // Reset for count-up phase
            print('🔄 Top Score: Switching from countdown to count-up phase');
          }

          // Check if maximum time exceeded (for all Show Jumping modes)
          if (!_isMountedSports && _maxTimeSeconds > 0) {
            int totalElapsed = _isTopScoreMode && !_isInCountdownPhase 
                ? _timeAllowedSeconds + _elapsedSeconds
                : _elapsedSeconds;
            
            if (totalElapsed >= _maxTimeSeconds) {
              _handleTimeExpired();
            }
          }
        });
      }
    });
  }

  void _togglePause() async {
    final btService = BluetoothService();

    setState(() {
      _isPaused = !_isPaused;
    });

    // Send pause or resume command to hardware (just the keyword)
    String command;
    if (_isPaused) {
      command = CommandProtocol.buildPauseCommand();
      print('📤 Sending PAUSE command: $command');
    } else {
      command = CommandProtocol.buildResumeCommand();
    }
    
    bool sent = await btService.sendData(command);
    if (!sent) {
      print('❌ Failed to send pause/resume command');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isPaused ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(_isPaused ? 'Race paused' : 'Race resumed'),
            ),
          ],
        ),
        backgroundColor: _isPaused ? Colors.orange.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _showFinishRaceConfirmation() async {
    final bool? shouldFinish = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finish Race'),
          content: const Text(
            'Do you want to finish the race? This will mark the race as completed.',
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Finish Race'),
            ),
          ],
        );
      },
    );

    if (shouldFinish == true) {
      await _finishRace();
    }
  }

  Future<void> _finishRace() async {
    final btService = BluetoothService();
    final modeService = ModeService();
    final eventCode = modeService.getEventCode();
    final command = CommandProtocol.buildFinishCommand(eventCode);

    print('🏁 Sending finish command: $command');
    bool sent = await btService.sendData(command);
    if (sent) {
      final currentTime = _elapsedSeconds;
      final hours = currentTime ~/ 3600;
      final minutes = (currentTime % 3600) ~/ 60;
      final seconds = currentTime % 60;

      _timer.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Race finished successfully')),
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
        // For Mounted Sports (no max time), race is always successful when finished
        // For Show Jumping, check if time is within limit
        final isSuccess = _isMountedSports || currentTime <= _maxTimeSeconds;
        Navigator.of(context).pushReplacementNamed(
          RaceResultsScreen.routeName,
          arguments: {
            'elapsedSeconds': currentTime,
            'elapsedHours': hours,
            'elapsedMinutes': minutes,
            'elapsedSecondsOnly': seconds,
            'elapsedMilliseconds': 0,
            'maxSeconds': _maxTimeSeconds,
            'riderName': widget.riderName,
            'riderNumber': widget.riderNumber,
            'photoPath': widget.photoPath,
            'isSuccess': isSuccess,
            'raceStatus': 'finished',
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to finish race. Please try again.')),
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

  Future<void> _showDisqualifyConfirmation() async {
    final bool? shouldDisqualify = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disqualify Race'),
          content: const Text(
            'Are you sure you want to disqualify this race? This action cannot be undone.',
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
              child: const Text('Disqualify'),
            ),
          ],
        );
      },
    );

    if (shouldDisqualify == true) {
      await _disqualifyRace();
    }
  }

  Future<void> _disqualifyRace() async {
    final btService = BluetoothService();
    final modeService = ModeService();
    final eventCode = modeService.getEventCode();
    final command = CommandProtocol.buildFinishCommand(eventCode);

    print('❌ Sending disqualify command: $command');
    bool sent = await btService.sendData(command);
    if (sent) {
      final currentTime = _elapsedSeconds;
      final hours = currentTime ~/ 3600;
      final minutes = (currentTime % 3600) ~/ 60;
      final seconds = currentTime % 60;

      _timer.cancel();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Race has been disqualified')),
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

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          RaceResultsScreen.routeName,
          arguments: {
            'elapsedSeconds': currentTime,
            'elapsedHours': hours,
            'elapsedMinutes': minutes,
            'elapsedSecondsOnly': seconds,
            'elapsedMilliseconds': 0,
            'maxSeconds': _maxTimeSeconds,
            'riderName': widget.riderName,
            'riderNumber': widget.riderNumber,
            'photoPath': widget.photoPath,
            'isSuccess': false,
            'raceStatus': 'disqualified',
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to disqualify race. Please try again.')),
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

  void _listenForStopSignal() {
    final btService = BluetoothService();
    
    _bluetoothSubscription = btService.messageStream.listen((message) {
      print('📨 Race screen received: $message');

      // Check if it's a STOP/FINISH signal (either 'stop' keyword or beacon format d1,e#)
      final trimmedMessage = message.trim().toLowerCase();
      final isStopKeyword = trimmedMessage == 'stop';
      final isFinishBeacon = CommandProtocol.isValidBeaconCommand(message) && 
                            message.startsWith('d1'); // d1 = stop action
      
      if (isStopKeyword || isFinishBeacon) {
        print('🏁 STOP/FINISH command received: $message');
        _handleRaceComplete(message);
      }
    });
  }

  void _handleRaceComplete([String? stopMessage]) {
    _timer.cancel();

    Map<String, int> timeData;

    // Try to parse time from hardware message (format: stop,HH:MM:SS:mmm or d1,e#,HH:MM:SS:mmm)
    if (stopMessage != null && stopMessage.contains(',')) {
      timeData = _parseTimeFromHardware(stopMessage);
      if (timeData['totalSeconds']! > 0) {
        print(
          '✅ Using HARDWARE time: ${timeData['hours']}h ${timeData['minutes']}m ${timeData['seconds']}s ${timeData['milliseconds']}ms',
        );
      } else {
        // Parsing failed, fallback to internal timer
        timeData = _getInternalTimerData();
        print('⚠️ Hardware time parse failed, using internal timer');
      }
    } else {
      // No time data in message, use internal timer
      timeData = _getInternalTimerData();
      print('🕒 No time data from hardware, using internal timer');
    }

    // Determine if race was successful
    // For Mounted Sports (no max time), race is always successful when finished
    // For Show Jumping, check if time is within limit
    final isSuccess = _isMountedSports || timeData['totalSeconds']! <= _maxTimeSeconds;

    print(
      '🏁 Race result: ${isSuccess ? "COMPLETED" : "TIME EXCEEDED"} - Elapsed: ${timeData['totalSeconds']}s, Max: ${_maxTimeSeconds}s',
    );

    // Navigate to results screen
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        RaceResultsScreen.routeName,
        arguments: {
          'elapsedSeconds': timeData['totalSeconds'],
          'elapsedHours': timeData['hours'],
          'elapsedMinutes': timeData['minutes'],
          'elapsedSecondsOnly': timeData['seconds'],
          'elapsedMilliseconds': timeData['milliseconds'],
          'maxSeconds': _maxTimeSeconds,
          'riderName': widget.riderName,
          'riderNumber': widget.riderNumber,
          'photoPath': widget.photoPath,
          'isSuccess': isSuccess,
          'raceStatus': isSuccess ? 'finished' : 'timeExceeded',
        },
      );
    }
  }

  /// Parses time from hardware message
  /// Supports formats: 
  /// - stop,HH:MM:SS:mmm
  /// - d1,e#,HH:MM:SS:mmm
  /// - HH:MM:SS:mmm (just the time string)
  Map<String, int> _parseTimeFromHardware(String message) {
    try {
      print('🔍 Parsing hardware time from: $message');
      
      // Extract time string from message
      String timeString;
      final parts = message.split(',');
      
      if (parts.length >= 2) {
        // Could be "stop,HH:MM:SS:mmm" or "d1,e2,HH:MM:SS:mmm"
        // Time is always the last part
        timeString = parts.last.trim();
      } else {
        timeString = message.trim();
      }
      
      print('🕒 Extracted time string: $timeString');
      
      // Parse format: HH:MM:SS:mmm or HH:MM:SS or MM:SS:mmm
      final timeParts = timeString.split(':');
      
      if (timeParts.length == 4) {
        // Format: HH:MM:SS:mmm
        final hours = int.parse(timeParts[0]);
        final minutes = int.parse(timeParts[1]);
        final seconds = int.parse(timeParts[2]);
        final milliseconds = int.parse(timeParts[3]);
        final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
        
        print('✅ Parsed: ${hours}h ${minutes}m ${seconds}s ${milliseconds}ms = ${totalSeconds}s total');
        
        return {
          'hours': hours,
          'minutes': minutes,
          'seconds': seconds,
          'milliseconds': milliseconds,
          'totalSeconds': totalSeconds,
        };
      } else if (timeParts.length == 3) {
        // Format: MM:SS:mmm or HH:MM:SS
        final part1 = int.parse(timeParts[0]);
        final part2 = int.parse(timeParts[1]);
        final part3 = int.parse(timeParts[2]);
        
        // Check if part3 looks like milliseconds (< 1000) or seconds
        if (part3 < 100) {
          // Likely HH:MM:SS format
          final totalSeconds = (part1 * 3600) + (part2 * 60) + part3;
          return {
            'hours': part1,
            'minutes': part2,
            'seconds': part3,
            'milliseconds': 0,
            'totalSeconds': totalSeconds,
          };
        } else {
          // Likely MM:SS:mmm format
          final totalSeconds = (part1 * 60) + part2;
          return {
            'hours': 0,
            'minutes': part1,
            'seconds': part2,
            'milliseconds': part3,
            'totalSeconds': totalSeconds,
          };
        }
      }
    } catch (e) {
      print('❌ Error parsing hardware time from "$message": $e');
    }
    
    // Return invalid data to trigger fallback
    return {'hours': 0, 'minutes': 0, 'seconds': 0, 'milliseconds': 0, 'totalSeconds': 0};
  }
  
  /// Gets time from internal app timer as fallback
  Map<String, int> _getInternalTimerData() {
    final elapsedTime = DateTime.now().difference(_startTime);
    final elapsedSeconds = elapsedTime.inSeconds;
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    
    return {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'milliseconds': 0,
      'totalSeconds': elapsedSeconds,
    };
  }

  void _handleTimeExpired() {
    _timer.cancel();

    print('⏰ Maximum time exceeded!');

    // Navigate to results screen showing time exceeded
    if (mounted) {
      final hours = _maxTimeSeconds ~/ 3600;
      final minutes = (_maxTimeSeconds % 3600) ~/ 60;
      final seconds = _maxTimeSeconds % 60;

      Navigator.of(context).pushReplacementNamed(
        RaceResultsScreen.routeName,
        arguments: {
          'elapsedSeconds': _maxTimeSeconds,
          'elapsedHours': hours,
          'elapsedMinutes': minutes,
          'elapsedSecondsOnly': seconds,
          'elapsedMilliseconds': 0,
          'maxSeconds': _maxTimeSeconds,
          'riderName': widget.riderName,
          'riderNumber': widget.riderNumber,
          'photoPath': widget.photoPath,
          'isSuccess': false,
          'raceStatus': 'timeExceeded',
        },
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _bluetoothSubscription?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int displaySeconds = seconds;
    
    // Top Score Mode: Show countdown in Phase 1
    if (_isTopScoreMode && _isInCountdownPhase) {
      displaySeconds = _timeAllowedSeconds - seconds;
      if (displaySeconds < 0) displaySeconds = 0;
    }
    
    int hours = displaySeconds ~/ 3600;
    int minutes = (displaySeconds % 3600) ~/ 60;
    int secs = displaySeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  double get _progress {
    // No progress ring - using pulsing effect only
    return 0;
  }

  Color get _timerColor {
    // For Mounted Sports: always green (no time limit)
    if (_isMountedSports) {
      return const Color(0xFF10B981); // Green
    }

    if (_timeAllowedSeconds == 0) return const Color(0xFF10B981);

    // Top Score Mode
    if (_isTopScoreMode) {
      if (_isInCountdownPhase) {
        // Phase 1: Countdown (time_allowed → 0) - GREEN
        return const Color(0xFF10B981);
      } else {
        // Phase 2: Count-up (0 → time_allowed) - ORANGE → RED
        double progress = _elapsedSeconds / _timeAllowedSeconds;
        return Color.lerp(
          const Color(0xFFF59E0B), // Orange
          const Color(0xFFEF4444), // Red
          progress,
        )!;
      }
    }

    // Normal Mode: Gradual GREEN → ORANGE → RED
    if (_elapsedSeconds <= _timeAllowedSeconds) {
      // Phase 1: 0 → time_allowed - GREEN → ORANGE
      double progress = _elapsedSeconds / _timeAllowedSeconds;
      return Color.lerp(
        const Color(0xFF10B981), // Green
        const Color(0xFFF59E0B), // Orange
        progress,
      )!;
    } else {
      // Phase 2: time_allowed → max_time - ORANGE → RED
      int remainingTime = _maxTimeSeconds - _timeAllowedSeconds;
      int timeInPhase2 = _elapsedSeconds - _timeAllowedSeconds;
      double progress = remainingTime > 0 ? timeInPhase2 / remainingTime : 1.0;
      return Color.lerp(
        const Color(0xFFF59E0B), // Orange
        const Color(0xFFEF4444), // Red
        progress,
      )!;
    }
  }

  // Mounted Sports: Only Finish and Disqualify buttons
  Widget _buildMountedSportsButtons() {
    return Row(
      children: [
        // Finish Race Button
        Expanded(
          child: GestureDetector(
            onTap: _showFinishRaceConfirmation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'FINISH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Disqualify Button
        Expanded(
          child: GestureDetector(
            onTap: _showDisqualifyConfirmation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'DISQUALIFY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Show Jumping: Pause, Finish, and Disqualify buttons
  Widget _buildShowJumpingButtons() {
    return Row(
      children: [
        // Pause/Resume Button
        Expanded(
          child: GestureDetector(
            onTap: _togglePause,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPaused
                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                      : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (_isPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                        .withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPaused ? 'RESUME' : 'PAUSE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Finish Race Button
        Expanded(
          child: GestureDetector(
            onTap: _showFinishRaceConfirmation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10B981), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FINISH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Disqualify Button
        Expanded(
          child: GestureDetector(
            onTap: _showDisqualifyConfirmation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'DISQUALIFY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(_isMountedSports
              ? (widget.raceType == 'startVerifyFinish'
                  ? 'Start → Verify → Finish'
                  : 'Start → Finish')
              : 'Race In Progress'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                                // Rider Info
                Container(
                  padding: const EdgeInsets.all(16),
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
                        Icons.person_outline,
                        color: Color(0xFF0066FF),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.riderName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (widget.riderNumber.isNotEmpty)
                              Text(
                                '#${widget.riderNumber}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),


                const Spacer(),

                // Circular Timer
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _timerColor.withOpacity(
                              0.3 + (0.2 * _pulseController.value),
                            ),
                            blurRadius: 40 + (20 * _pulseController.value),
                            spreadRadius: 10 + (10 * _pulseController.value),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 20,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.grey.shade300,
                              ),
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: CircularProgressIndicator(
                              value: _progress,
                              strokeWidth: 20,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(_timerColor),
                            ),
                          ),
                          // Time display
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(_elapsedSeconds),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _timerColor,
                                        fontSize: 48,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ELAPSED',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                const Spacer(),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _isPaused ? Colors.orange : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isPaused)
                        Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            )
                            .animate(onPlay: (controller) => controller.repeat())
                            .fadeOut(duration: 1000.ms)
                            .then()
                            .fadeIn(duration: 1000.ms)
                      else
                        const Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 16,
                        ),
                      const SizedBox(width: 12),
                      Text(
                        _isPaused
                            ? 'RACE PAUSED'
                            : (_isMountedSports ? 'RACE IN PROGRESS' : 'WAITING FOR FINISH'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 32),

                // Race Control Buttons - Modern Design
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _isMountedSports
                      ? _buildMountedSportsButtons()
                      : _buildShowJumpingButtons(),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
