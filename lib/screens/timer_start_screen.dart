import 'package:flutter/material.dart';
import 'bluetooth_ready_screen.dart';
import 'bluetooth_failed_screen.dart';
import '../services/bluetooth_service.dart';
import '../services/mode_service.dart';

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
    required this.eventName,
    required this.horseName,
    required this.horseId,
    required this.additionalDetails,
  });

  static const routeName = '/timer-start';

  final int selectedHours;
  final int selectedMinutes;
  final int selectedSeconds;
  final int maxHours;
  final int maxMinutes;
  final int maxSeconds;
  final String riderName;
  final String eventName;
  final String horseName;
  final String horseId;
  final String additionalDetails;

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

  // Target Bluetooth device name - customize this as needed
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
    // Check if already connected when screen loads
    _checkExistingConnection();
  }

  Future<void> _checkExistingConnection() async {
    final btService = BluetoothService();

    // If already connected, go directly to ready screen
    if (btService.isConnected) {
      print('✅ Already connected to Bluetooth device');
      // Navigate to Bluetooth ready screen immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            BluetoothReadyScreen.routeName,
            arguments: {
              'selectedHours': widget.selectedHours,
              'selectedMinutes': widget.selectedMinutes,
              'selectedSeconds': widget.selectedSeconds,
              'maxHours': widget.maxHours,
              'maxMinutes': widget.maxMinutes,
              'maxSeconds': widget.maxSeconds,
              'riderName': widget.riderName,
              'eventName': widget.eventName,
              'horseName': widget.horseName,
              'horseId': widget.horseId,
              'additionalDetails': widget.additionalDetails,
            },
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

  void _onStartPressed() async {
    setState(() {
      _isPressed = true;
      _isConnecting = true;
    });
    _glowController.forward();

    try {
      // Simulate Bluetooth connection check
      await _checkBluetoothConnection();

      if (_isConnected) {
        // Navigate to Bluetooth ready screen
        Navigator.of(context).pushNamed(
          BluetoothReadyScreen.routeName,
          arguments: {
            'selectedHours': widget.selectedHours,
            'selectedMinutes': widget.selectedMinutes,
            'selectedSeconds': widget.selectedSeconds,
            'maxHours': widget.maxHours,
            'maxMinutes': widget.maxMinutes,
            'maxSeconds': widget.maxSeconds,
            'riderName': widget.riderName,
            'eventName': widget.eventName,
            'horseName': widget.horseName,
            'horseId': widget.horseId,
            'additionalDetails': widget.additionalDetails,
          },
        );
      }
    } catch (e) {
      _showConnectionError(e.toString());
    }

    // Reset after animation
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

    // Request Bluetooth permissions first (Android 12+)
    bool permissionsGranted = await btService.requestBluetoothPermissions();
    if (!permissionsGranted) {
      throw Exception('Bluetooth permissions are required. Please grant permissions in settings.');
    }

    // Check if Bluetooth is enabled
    bool isEnabled = await btService.isBluetoothEnabled();
    if (!isEnabled) {
      print('🔴 Bluetooth is disabled, requesting to enable...');
      bool enabled = await btService.requestEnable();
      if (!enabled) {
        throw Exception('Bluetooth is not enabled. Please turn on Bluetooth.');
      }
    }

    print('🔵 Bluetooth is enabled');

    // Find the target device
    var device = await btService.findDeviceByName(targetBluetoothDevice);
    if (device == null) {
      throw Exception(
        'Device "$targetBluetoothDevice" not found. Please pair it in Bluetooth settings first.',
      );
    }

    // Connect to device
    bool connected = await btService.connectToDevice(device);
    if (!connected) {
      throw Exception('Failed to connect to $targetBluetoothDevice');
    }

    setState(() {
      _isConnected = true;
    });

    // Listen to messages from ESP32
    btService.messageStream.listen((message) {
      print('🎯 Message from ESP32: $message');
      // Handle the message here (e.g., start timer, stop timer, etc.)
      _handleArduinoMessage(message);
    });

    // Send a test beacon signal
    await _sendBeaconSignal();
  }

  Future<void> _sendBeaconSignal() async {
    final btService = BluetoothService();
    final modeService = ModeService();
    
    // Map selected mode to protocol codes:
    // SHOW_JUMPING -> d0,e0
    // MOUNTED_SPORTS -> d0,e1
    // Fallback / unknown -> d0,ff
    final selected = modeService.getMode();
    String payload;
    if (selected == ModeService.showJumping) {
      payload = 'd0,e0';
    } else if (selected == ModeService.mountedSports) {
      payload = 'd0,e1';
    } else {
      payload = 'd0,ff';
    }

    bool sent = await btService.sendData(payload);
    if (sent) {
      print('✅ Mode signal sent successfully to ESP32: $payload (mode=$selected)');
    } else {
      print('❌ Failed to send mode signal (mode=$selected, payload=$payload)');
    }
  }

  void _handleArduinoMessage(String message) {
    // Handle different messages from ESP32
    print('🔔 Processing message: $message');

    if (message.contains('START')) {
      print('▶️ Received START signal from ESP32');
      // TODO: Start your timer logic here
    } else if (message.contains('STOP')) {
      print('⏹️ Received STOP signal from ESP32');
      // TODO: Stop your timer logic here
    } else if (message.contains('ACK')) {
      print('✅ ESP32 acknowledged connection');
    } else {
      print('📬 Custom message: $message');
      // Handle other custom messages
    }
  }

  void _showConnectionError(String error) {
    // Navigate to dedicated error screen instead of just showing snackbar
    Navigator.of(context).pushNamed(
      BluetoothFailedScreen.routeName,
      arguments: {
        'selectedHours': widget.selectedHours,
        'selectedMinutes': widget.selectedMinutes,
        'selectedSeconds': widget.selectedSeconds,
        'maxHours': widget.maxHours,
        'maxMinutes': widget.maxMinutes,
        'maxSeconds': widget.maxSeconds,
        'riderName': widget.riderName,
        'eventName': widget.eventName,
        'horseName': widget.horseName,
        'horseId': widget.horseId,
        'additionalDetails': widget.additionalDetails,
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
                    _buildInfoRow(Icons.person, 'Rider', widget.riderName),
                    const Divider(height: 20),
                    _buildInfoRow(Icons.event, 'Event', widget.eventName),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.pets,
                      'Horse',
                      '${widget.horseName} (${widget.horseId})',
                    ),
                    const Divider(height: 20),
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
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
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

              // Connect Button
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

              // Status indicator
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
