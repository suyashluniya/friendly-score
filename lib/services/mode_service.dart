import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class ModeService {
  static final ModeService _instance = ModeService._internal();
  factory ModeService() => _instance;
  ModeService._internal() {
    _loadMode();
  }

  String? _selectedMode;
  static const String _modeKey = 'selected_mode';

  // Mode constants
  static const String showJumping = 'SHOW_JUMPING';
  static const String mountedSports = 'MOUNTED_SPORTS';

  // Load the persisted mode on initialization
  Future<void> _loadMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedMode = prefs.getString(_modeKey);
      if (_selectedMode != null) {
        Logger.info('Loaded persisted mode: $_selectedMode', tag: 'ModeService');
      }
    } catch (e) {
      Logger.error('Error loading mode', tag: 'ModeService', error: e);
    }
  }

  // Set the selected mode and persist it
  Future<void> setMode(String mode) async {
    _selectedMode = mode;
    Logger.info('Mode selected: $mode', tag: 'ModeService');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modeKey, mode);
      Logger.info('Mode persisted successfully', tag: 'ModeService');
    } catch (e) {
      Logger.error('Error persisting mode', tag: 'ModeService', error: e);
    }
  }

  // Get the selected mode
  String? getMode() {
    return _selectedMode;
  }

  // Async method to ensure mode is loaded
  Future<String?> getModeAsync() async {
    if (_selectedMode == null) {
      await _loadMode();
    }
    return _selectedMode;
  }

  // Get mode for Bluetooth communication
  String getModeForBluetooth() {
    if (_selectedMode == null) {
      return 'MODE:UNKNOWN';
    }
    return 'MODE:$_selectedMode';
  }

  // Get display name for mode
  String getModeDisplayName() {
    switch (_selectedMode) {
      case showJumping:
        return 'Show Jumping';
      case mountedSports:
        return 'Mounted Sports';
      default:
        return 'Unknown Mode';
    }
  }

  // Clear the selected mode and remove from persistence
  Future<void> clearMode() async {
    _selectedMode = null;
    Logger.info('Mode cleared', tag: 'ModeService');

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_modeKey);
      Logger.info('Mode removed from persistence', tag: 'ModeService');
    } catch (e) {
      Logger.error('Error clearing mode', tag: 'ModeService', error: e);
    }
  }

  // Check if mode is selected
  bool hasMode() {
    return _selectedMode != null;
  }
}