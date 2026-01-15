import 'package:flutter/material.dart';
import 'bluetooth_ready_screen.dart';
import 'bluetooth_failed_screen.dart';
import '../services/bluetooth_service.dart';
import '../services/mode_service.dart';
import '../utils/command_protocol.dart';

class TimerStartScreen extends StatefulWidget {
  const TimerStartScreen({
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

  static const routeName = '/timer-start';

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
  State<TimerStartScreen> createState() => _TimerStartScreenState();
}

class _TimerStartScreenState extends State<TimerStartScreen>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  static const String targetBluetoothDevice = 'ESP32-BT-Client';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    final btService = BluetoothService();

    if (btService.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            BluetoothReadyScreen.routeName,
            arguments: _buildArgs(),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildArgs() {
    return {
      'selectedHours': widget.selectedHours,
      'selectedMinutes': widget.selectedMinutes,
      'selectedSeconds': widget.selectedSeconds,
      'maxHours': widget.maxHours,
      'maxMinutes': widget.maxMinutes,
      'maxSeconds': widget.maxSeconds,
      'riderName': widget.riderName,
      'riderNumber': widget.riderNumber,
      'photoPath': widget.photoPath,
      'raceType': widget.raceType,
    };
  }

  bool get _isMountedSports => widget.raceType != null;

  void _onStartPressed() async {
    setState(() {
      _isPressed = true;
      _isConnecting = true;
    });
    _glowController.forward();

    try {
      await _checkBluetoothConnection();

      if (_isConnected) {
        Navigator.of(context).pushNamed(
          BluetoothReadyScreen.routeName,
          arguments: _buildArgs(),
        );
      }
    } catch (e) {
      _showConnectionError(e.toString());
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isPressed = false;
          _isConnecting = false;
        });
        _glowController.reverse();
      }
    });
  }

  Future<void> _checkBluetoothConnection() async {
    final btService = BluetoothService();

    bool permissionsGranted = await btService.requestBluetoothPermissions();
    if (!permissionsGranted) {
      throw Exception('Bluetooth permissions are required. Please grant permissions in settings.');
    }

    bool isEnabled = await btService.isBluetoothEnabled();
    if (!isEnabled) {
      bool enabled = await btService.requestEnable();
      if (!enabled) {
        throw Exception('Bluetooth is not enabled. Please turn on Bluetooth.');
      }
    }

    var device = await btService.findDeviceByName(targetBluetoothDevice);
    if (device == null) {
      throw Exception(
        'Device "$targetBluetoothDevice" not found. Please pair it in Bluetooth settings first.',
      );
    }

    bool connected = await btService.connectToDevice(device);
    if (!connected) {
      throw Exception('Failed to connect to $targetBluetoothDevice');
    }

    setState(() {
      _isConnected = true;
    });

    await _sendBeaconSignal();
  }

  Future<void> _sendBeaconSignal() async {
    final btService = BluetoothService();
    final modeService = ModeService();
    final eventCode = modeService.getEventCode();
    
    // For Top Score mode, include the time allowed in seconds
    String command;
    if (!_isMountedSports && modeService.isTopScoreMode()) {
      final timeAllowedSeconds = (widget.selectedHours * 3600) + 
                                (widget.selectedMinutes * 60) + 
                                widget.selectedSeconds;
      command = CommandProtocol.buildStartCommand(eventCode, timeInSeconds: timeAllowedSeconds);
    } else {
      command = CommandProtocol.buildStartCommand(eventCode);
    }
    
    print('📡 Sending START beacon signal: $command');
    await btService.sendData(command);
  }

  void _showConnectionError(String error) {
    Navigator.of(context).pushNamed(
      BluetoothFailedScreen.routeName,
      arguments: {
        ..._buildArgs(),
        'errorMessage': error,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready to Start'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Rider Info Card
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
                  children: [
                    if (widget.riderName.isNotEmpty) ...[
                      _buildInfoRow(Icons.person, 'Rider', widget.riderName),
                      const Divider(height: 20),
                    ],
                    if (widget.riderNumber.isNotEmpty) ...[
                      _buildInfoRow(Icons.numbers, 'Number', widget.riderNumber),
                      const Divider(height: 20),
                    ],
                    if (_isMountedSports) ...[
                      _buildInfoRow(
                        Icons.flag_rounded,
                        'Race Type',
                        widget.raceType == 'startVerifyFinish'
                            ? 'Start → Verify → Finish'
                            : 'Start → Finish',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        Icons.timer,
                        'Timer',
                        'Starts from 0:00:00',
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.timer,
                        'Time Set',
                        _formatTime(
                          widget.selectedHours,
                          widget.selectedMinutes,
                          widget.selectedSeconds,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        Icons.schedule,
                        'Max Time',
                        _formatTime(
                          widget.maxHours,
                          widget.maxMinutes,
                          widget.maxSeconds,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _isConnected
                    ? 'Hardware Connected - Verifying...'
                    : _isConnecting
                        ? 'Connecting to ESP32-BT-Client...'
                        : 'Press to connect to ESP32 timing system',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade400.withOpacity(
                            0.3 + (0.2 * _pulseController.value),
                          ),
                          blurRadius: 30 + (20 * _pulseController.value),
                          spreadRadius: 5 + (10 * _pulseController.value),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return GestureDetector(
                          onTapDown: (_) => _onStartPressed(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: _isPressed
                                    ? [
                                        Colors.green.shade300,
                                        Colors.green.shade600,
                                        Colors.green.shade800,
                                      ]
                                    : [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                        Colors.green.shade700,
                                      ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 3,
                              ),
                              boxShadow: _isPressed
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.shade600
                                            .withOpacity(0.6),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bluetooth,
                                    size: 48,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isConnecting ? 'CONNECTING' : 'CONNECT',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.check_circle_outline
                          : _isConnecting
                              ? Icons.sync
                              : Icons.pending_outlined,
                      color: _isConnected
                          ? const Color(0xFF10B981)
                          : _isConnecting
                              ? const Color(0xFF0066FF)
                              : const Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isConnecting
                          ? 'Connecting to Hardware'
                          : _isConnected
                              ? 'Hardware Connected'
                              : 'Ready to Connect',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _isConnected
                                ? const Color(0xFF10B981)
                                : _isConnecting
                                    ? const Color(0xFF0066FF)
                                    : const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6C757D)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
