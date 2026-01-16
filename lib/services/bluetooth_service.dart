import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

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
      Logger.debug('Requesting Bluetooth permissions...', tag: 'Bluetooth');

      // Request all necessary Bluetooth permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (allGranted) {
        Logger.info('All Bluetooth permissions granted', tag: 'Bluetooth');
        return true;
      } else {
        Logger.warning('Some Bluetooth permissions denied', tag: 'Bluetooth');
        statuses.forEach((permission, status) {
          Logger.debug('$permission: $status', tag: 'Bluetooth');
        });
        return false;
      }
    } catch (e) {
      Logger.error('Error requesting permissions', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Check if Bluetooth is available and enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      return await FlutterBluetoothSerial.instance.isEnabled ?? false;
    } catch (e) {
      Logger.error('Error checking Bluetooth status', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Request to enable Bluetooth
  Future<bool> requestEnable() async {
    try {
      return await FlutterBluetoothSerial.instance.requestEnable() ?? false;
    } catch (e) {
      Logger.error('Error requesting Bluetooth enable', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Get paired devices
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      Logger.error('Error getting paired devices', tag: 'Bluetooth', error: e);
      return [];
    }
  }

  // Find device by name
  Future<BluetoothDevice?> findDeviceByName(String deviceName) async {
    try {
      List<BluetoothDevice> devices = await getPairedDevices();
      Logger.debug('Searching for device: $deviceName', tag: 'Bluetooth');
      Logger.debug('Found ${devices.length} paired devices', tag: 'Bluetooth');

      for (var device in devices) {
        Logger.debug('${device.name} (${device.address})', tag: 'Bluetooth');
        if (device.name == deviceName) {
          Logger.info('Found target device: ${device.name}', tag: 'Bluetooth');
          return device;
        }
      }
      Logger.warning('Device "$deviceName" not found in paired devices', tag: 'Bluetooth');
      return null;
    } catch (e) {
      Logger.error('Error finding device', tag: 'Bluetooth', error: e);
      return null;
    }
  }

  // Connect to a device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      Logger.info('Attempting to connect to ${device.name}...', tag: 'Bluetooth');
      Logger.debug('Device address: ${device.address}', tag: 'Bluetooth');

      _connection = await BluetoothConnection.toAddress(device.address);
      Logger.info('Connected to ${device.name}!', tag: 'Bluetooth');
      Logger.debug('Baud rate: 115200 (ESP32 default)', tag: 'Bluetooth');

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
              Logger.debug('Received from ESP32: $message', tag: 'Bluetooth');
              _messageController.add(message);
            }
          }
        },
        onDone: () {
          Logger.info('Disconnected from ${device.name}', tag: 'Bluetooth');
          disconnect();
        },
        onError: (error) {
          Logger.error('Connection error', tag: 'Bluetooth', error: error);
          disconnect();
        },
      );

      return true;
    } catch (e) {
      Logger.error('Connection failed', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Send data to ESP32
  Future<bool> sendData(String data) async {
    Logger.debug('sendData() called with data: $data', tag: 'Bluetooth');
    try {
      Logger.debug('Connection status - _connection: ${_connection != null}, isConnected: ${_connection?.isConnected}', tag: 'Bluetooth');
      if (_connection != null && _connection!.isConnected) {
        Logger.debug('About to send data to ESP32...', tag: 'Bluetooth');
        _connection!.output.add(Uint8List.fromList(utf8.encode(data + '\n')));
        await _connection!.output.allSent;
        Logger.info('Successfully sent to ESP32: $data', tag: 'Bluetooth');
        return true;
      } else {
        Logger.warning('Not connected to device', tag: 'Bluetooth');
        return false;
      }
    } catch (e) {
      Logger.error('Error sending data', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Send raw bytes to ESP32
  Future<bool> sendBytes(List<int> bytes) async {
    try {
      if (_connection != null && _connection!.isConnected) {
        _connection!.output.add(Uint8List.fromList(bytes));
        await _connection!.output.allSent;
        Logger.info('Sent ${bytes.length} bytes to ESP32', tag: 'Bluetooth');
        return true;
      } else {
        Logger.warning('Not connected to device', tag: 'Bluetooth');
        return false;
      }
    } catch (e) {
      Logger.error('Error sending bytes', tag: 'Bluetooth', error: e);
      return false;
    }
  }

  // Disconnect
  void disconnect() {
    _dataSubscription?.cancel();
    _connection?.dispose();
    _connection = null;
    _dataBuffer = '';
    Logger.info('Bluetooth connection closed', tag: 'Bluetooth');
  }

  bool get isConnected => _connection != null && _connection!.isConnected;

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
