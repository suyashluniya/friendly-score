import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'bluetooth_ready_screen.dart';
import 'bluetooth_failed_screen.dart';
import '../services/bluetooth_service.dart';

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
    // Reset connection state when returning to this screen
    _resetConnectionState();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _resetConnectionState() {
    if (mounted) {
      setState(() {
        _isPressed = false;
        _isConnecting = false;
        _isConnected = false;
      });
      _glowController.reset();
    }
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
    bool sent = await btService.sendData('HELLO');
    if (sent) {
      print('✅ Beacon signal sent successfully to ESP32');
    } else {
      print('❌ Failed to send beacon signal');
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          'Ready to Start',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
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
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              const SizedBox(height: 30),

              // Instructions
              Text(
                _isConnected
                    ? 'Hardware Connected - Verifying...'
                    : _isConnecting
                    ? 'Connecting to ESP32-BT-Client...'
                    : 'Press to connect to ESP32 timing system',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 800.ms, delay: 400.ms),

              const SizedBox(height: 40),

              // Circular Start Button (Car Push Button Style)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Outer glow effect
                        BoxShadow(
                          color: Colors.green.shade400.withOpacity(
                            0.3 + (0.2 * _pulseController.value),
                          ),
                          blurRadius: 30 + (20 * _pulseController.value),
                          spreadRadius: 5 + (10 * _pulseController.value),
                        ),
                        // Inner shadow for depth
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
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
                            width: 200,
                            height: 200,
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
                                width: 4,
                              ),
                              boxShadow: _isPressed
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.shade600
                                            .withOpacity(0.6),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    size: 60,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isConnecting ? 'CONNECTING' : 'CONNECT',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
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
              ).animate().scale(
                duration: 800.ms,
                delay: 600.ms,
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: 30),

              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected
                          ? Icons.check_circle
                          : _isConnecting
                          ? Icons.sync
                          : Icons.pending,
                      color: _isConnected
                          ? Colors.green.shade600
                          : _isConnecting
                          ? Colors.blue.shade600
                          : Colors.orange.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnecting
                          ? 'Connecting to Hardware'
                          : _isConnected
                          ? 'Hardware Connected'
                          : 'Ready to Connect',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isConnected
                            ? Colors.green.shade700
                            : _isConnecting
                            ? Colors.blue.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

              const SizedBox(height: 20),
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
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
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
