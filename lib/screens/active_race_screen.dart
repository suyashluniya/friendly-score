import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import 'race_results_screen.dart';

class ActiveRaceScreen extends StatefulWidget {
  const ActiveRaceScreen({
    super.key,
    required this.maxHours,
    required this.maxMinutes,
    required this.maxSeconds,
    required this.riderName,
    required this.eventName,
    required this.horseName,
    required this.horseId,
    required this.additionalDetails,
  });

  static const routeName = '/active-race';

  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String riderName;
  final String eventName;
  final String horseName;
  final String horseId;
  final String additionalDetails;

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

  @override
  void initState() {
    super.initState();

    // The widget receives the MAXIMUM time (already doubled)
    _maxTimeSeconds =
        (widget.maxHours * 3600) + (widget.maxMinutes * 60) + widget.maxSeconds;

    // Time allowed is half of the maximum time
    _timeAllowedSeconds = _maxTimeSeconds ~/ 2;

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

    print(
      '🏁 Race started! Time allowed: ${_formatTime(_timeAllowedSeconds)}, Max time: ${_formatTime(_maxTimeSeconds)}',
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;

        // Check if maximum time exceeded
        if (_elapsedSeconds >= _maxTimeSeconds) {
          _handleTimeExpired();
        }
      });
    });
  }

  void _listenForStopSignal() {
    final btService = BluetoothService();
    _bluetoothSubscription = btService.messageStream.listen((message) {
      print('📨 Race screen received: $message');

      if (message.contains('STOP')) {
        print('🏁 STOP signal received - Race finished!');
        _handleRaceComplete(message);
      }
    });
  }

  void _handleRaceComplete([String? stopMessage]) {
    _timer.cancel();

    Map<String, int> timeData;

    if (stopMessage != null && stopMessage.contains('STOP,')) {
      // Parse time from ESP32 message: STOP,12:34:34:456
      timeData = _parseTimeDataFromStopMessage(stopMessage);
      print(
        '✅ Race completed in time from ESP32: ${timeData['hours']}:${timeData['minutes']}:${timeData['seconds']}:${timeData['milliseconds']}',
      );
    } else {
      // Fallback to app's internal timer
      final elapsedTime = DateTime.now().difference(_startTime);
      final elapsedSeconds = elapsedTime.inSeconds;
      final hours = elapsedSeconds ~/ 3600;
      final minutes = (elapsedSeconds % 3600) ~/ 60;
      final seconds = elapsedSeconds % 60;

      timeData = {
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
        'milliseconds': 0, // No milliseconds from internal timer
        'totalSeconds': elapsedSeconds,
      };
      print(
        '✅ Race completed in ${_formatTime(elapsedSeconds)} (internal timer)',
      );
    }

    // Determine if race was successful by comparing elapsed time with max time
    final isSuccess = timeData['totalSeconds']! <= _maxTimeSeconds;

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
          'eventName': widget.eventName,
          'horseName': widget.horseName,
          'horseId': widget.horseId,
          'additionalDetails': widget.additionalDetails,
          'isSuccess': isSuccess,
          'raceStatus': isSuccess ? 'completed' : 'timeExceeded',
        },
      );
    }
  }

  Map<String, int> _parseTimeDataFromStopMessage(String message) {
    try {
      // Extract time part from "STOP,12:34:34:456"
      final parts = message.split(',');
      if (parts.length >= 2) {
        final timeString = parts[1].trim();

        // Parse format: HH:MM:SS:mmm (hours:minutes:seconds:milliseconds)
        final timeParts = timeString.split(':');
        if (timeParts.length == 4) {
          final hours = int.parse(timeParts[0]);
          final minutes = int.parse(timeParts[1]);
          final seconds = int.parse(timeParts[2]);
          final milliseconds = int.parse(timeParts[3]);

          final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
          print(
            '🕒 Parsed time: ${hours}h ${minutes}m ${seconds}s ${milliseconds}ms = ${totalSeconds}s total',
          );

          return {
            'hours': hours,
            'minutes': minutes,
            'seconds': seconds,
            'milliseconds': milliseconds,
            'totalSeconds': totalSeconds,
          };
        } else if (timeParts.length == 3) {
          // Fallback for old format: HH:MM:SSS or MM:SS:SSS
          final hours = int.parse(timeParts[0]);
          final minutes = int.parse(timeParts[1]);
          final secondsAndMillis = timeParts[2];

          // Handle seconds with milliseconds (e.g., "555" means 55.5 seconds)
          final seconds =
              int.parse(secondsAndMillis) ~/ 10; // Convert 555 to 55 seconds
          final milliseconds =
              (int.parse(secondsAndMillis) % 10) *
              100; // Approximate milliseconds

          final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
          print(
            '🕒 Parsed time (old format): ${hours}h ${minutes}m ${seconds}s ${milliseconds}ms = ${totalSeconds}s total',
          );

          return {
            'hours': hours,
            'minutes': minutes,
            'seconds': seconds,
            'milliseconds': milliseconds,
            'totalSeconds': totalSeconds,
          };
        }
      }
    } catch (e) {
      print('❌ Error parsing time from message: $message - $e');
    }

    // Fallback to internal timer if parsing fails
    print(
      '⚠️ Could not parse time from message: $message, using internal timer',
    );
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
          'eventName': widget.eventName,
          'horseName': widget.horseName,
          'horseId': widget.horseId,
          'additionalDetails': widget.additionalDetails,
          'isSuccess': false,
          'raceStatus': 'timeExceeded',
        },
      );
    }
  }

  Future<void> _showStopRaceConfirmation() async {
    final bool? shouldStop = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Race'),
          content: const Text(
            'Do you really want to stop the race? This will end the current race and record it as stopped.',
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
              child: const Text('Stop Race'),
            ),
          ],
        );
      },
    );

    if (shouldStop == true) {
      await _stopRace();
    }
  }

  Future<void> _stopRace() async {
    print('🛑 ACTIVE RACE: _stopRace() method called');
    final btService = BluetoothService();

    print('🛑 ACTIVE RACE: About to send d1,e0 payload');
    print('🛑 ACTIVE RACE: Bluetooth connected: ${btService.isConnected}');
    // Send disarm command to device to stop the race
    bool sent = await btService.sendData('d1,e0');
    if (sent) {
      print(
        '✅ ACTIVE RACE: Stop race signal sent successfully to ESP32: d1,e0',
      );

      // Calculate current elapsed time for the stopped race
      final currentTime = _elapsedSeconds;
      final hours = currentTime ~/ 3600;
      final minutes = (currentTime % 3600) ~/ 60;
      final seconds = currentTime % 60;

      // Stop the timer
      _timer.cancel();

      // Show confirmation that race was stopped
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Race has been stopped and recorded')),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to results screen with stopped race data
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
            'eventName': widget.eventName,
            'horseName': widget.horseName,
            'horseId': widget.horseId,
            'additionalDetails': widget.additionalDetails,
            'isSuccess': false, // Stopped race is considered unsuccessful
            'raceStatus': 'stopped', // Add status to identify stopped races
          },
        );
      }
    } else {
      print('❌ ACTIVE RACE: Failed to send stop race signal');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to stop race. Please try again.')),
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
    _timer.cancel();
    _pulseController.dispose();
    _bluetoothSubscription?.cancel();
    super.dispose();
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

  double get _progress {
    // Progress goes from 0 to 1 based on MAX time
    // This way the circle fills completely at max time (14 sec), not at allowed time (7 sec)
    return _elapsedSeconds / _maxTimeSeconds;
  }

  Color get _timerColor {
    if (_elapsedSeconds >= _timeAllowedSeconds) {
      // Over the allowed time - show RED
      return Colors.red;
    }

    // Calculate progress relative to allowed time for color changes
    double allowedProgress = _elapsedSeconds / _timeAllowedSeconds;

    if (allowedProgress < 0.5) {
      // Less than 50% of allowed time used - GREEN
      return Colors.green;
    } else if (allowedProgress < 0.75) {
      // 50-75% of allowed time used - still GREEN
      return Colors.green;
    } else {
      // 75-100% of allowed time used - ORANGE (warning)
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Race In Progress'),
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${widget.horseName} • ${widget.eventName}',
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
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          .fadeIn(duration: 1000.ms),
                      const SizedBox(width: 12),
                      Text(
                        'WAITING FOR FINISH',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

                const SizedBox(height: 24),

                // Stop Race Button
                GestureDetector(
                  onTap: _showStopRaceConfirmation,
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
                        const Icon(Icons.stop, color: Colors.red, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'STOP RACE',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.red, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
