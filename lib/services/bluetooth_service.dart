import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _dataSubscription;

  // Buffer for incoming data
  String _dataBuffer = '';

  // Stream controller for incoming messages
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _messageController.stream;

  // Request Bluetooth permissions (Android 12+)
  Future<bool> requestBluetoothPermissions() async {
    try {
      print('📋 Requesting Bluetooth permissions...');

      // Request all necessary Bluetooth permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        print('✅ All Bluetooth permissions granted');
        return true;
      } else {
        print('❌ Some Bluetooth permissions denied');
        statuses.forEach((permission, status) {
          print('  - $permission: $status');
        });
        return false;
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      return false;
    }
  }

  // Check if Bluetooth is available and enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await FlutterBluetoothSerial.instance.isEnabled ?? false;
    } catch (e) {
      print('❌ Error checking Bluetooth status: $e');
      return false;
    }
  }

  // Request to enable Bluetooth
  Future<bool> requestEnable() async {
    try {
      return await FlutterBluetoothSerial.instance.requestEnable() ?? false;
    } catch (e) {
      print('❌ Error requesting Bluetooth enable: $e');
      return false;
    }
  }

  // Get paired devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      print('❌ Error getting paired devices: $e');
      return [];
    }
  }

  // Find device by name
  Future<BluetoothDevice?> findDeviceByName(String deviceName) async {
    try {
      List<BluetoothDevice> devices = await getPairedDevices();
      print('🔍 Searching for device: $deviceName');
      print('📱 Found ${devices.length} paired devices');

      for (var device in devices) {
        print('  - ${device.name} (${device.address})');
        if (device.name == deviceName) {
          print('✅ Found target device: ${device.name}');
          return device;
        }
      }
      print('❌ Device "$deviceName" not found in paired devices');
      return null;
    } catch (e) {
      print('❌ Error finding device: $e');
      return null;
    }
  }

  // Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print('🔌 Attempting to connect to ${device.name}...');
      print('📍 Device address: ${device.address}');

      _connection = await BluetoothConnection.toAddress(device.address);
      print('✅ Connected to ${device.name}!');
      print('📡 Baud rate: 115200 (ESP32 default)');

      // Listen for incoming data
      _dataSubscription = _connection!.input!.listen(
        (Uint8List data) {
          // Add received data to buffer
          _dataBuffer += ascii.decode(data);

          // Process complete messages (separated by newlines)
          while (_dataBuffer.contains('\n')) {
            int newlineIndex = _dataBuffer.indexOf('\n');
            String message = _dataBuffer.substring(0, newlineIndex).trim();
            _dataBuffer = _dataBuffer.substring(newlineIndex + 1);

            if (message.isNotEmpty) {
              print('📨 Received from ESP32: $message');
              _messageController.add(message);
            }
          }
        },
        onDone: () {
          print('🔌 Disconnected from ${device.name}');
          disconnect();
        },
        onError: (error) {
          print('❌ Connection error: $error');
          disconnect();
        },
      );

      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  // Send data to ESP32
  Future<bool> sendData(String data) async {
    print('📡 BLUETOOTH SERVICE: sendData() called with data: $data');
    try {
      print('📡 BLUETOOTH SERVICE: Connection status - _connection: ${_connection != null}, isConnected: ${_connection?.isConnected}');
      if (_connection != null && _connection!.isConnected) {
        print('📡 BLUETOOTH SERVICE: About to send data to ESP32...');
        _connection!.output.add(Uint8List.fromList(utf8.encode(data + '\n')));
        await _connection!.output.allSent;
        print('📤 BLUETOOTH SERVICE: Successfully sent to ESP32: $data');
        return true;
      } else {
        print('❌ BLUETOOTH SERVICE: Not connected to device');
        return false;
      }
    } catch (e) {
      print('❌ BLUETOOTH SERVICE: Error sending data: $e');
      return false;
    }
  }

  // Send raw bytes to ESP32
  Future<bool> sendBytes(List<int> bytes) async {
    try {
      if (_connection != null && _connection!.isConnected) {
        _connection!.output.add(Uint8List.fromList(bytes));
        await _connection!.output.allSent;
        print('📤 Sent ${bytes.length} bytes to ESP32');
        return true;
      } else {
        print('❌ Not connected to device');
        return false;
      }
    } catch (e) {
      print('❌ Error sending bytes: $e');
      return false;
    }
  }

  // Disconnect
  void disconnect() {
    _dataSubscription?.cancel();
    _connection?.dispose();
    _connection = null;
    _dataBuffer = '';
    print('🔌 Bluetooth connection closed');
  }

  bool get isConnected => _connection != null && _connection!.isConnected;

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
