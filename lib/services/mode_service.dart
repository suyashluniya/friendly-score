class ModeService {
  static final ModeService _instance = ModeService._internal();
  factory ModeService() => _instance;
  ModeService._internal();

  String? _selectedMode;

  // Mode constants
  static const String showJumping = 'SHOW_JUMPING';
  static const String mountedSports = 'MOUNTED_SPORTS';

  // Set the selected mode
  void setMode(String mode) {
    _selectedMode = mode;
    print('🎯 Mode selected: $mode');
  }

  // Get the selected mode
  String? getMode() {
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

  // Clear the selected mode
  void clearMode() {
    _selectedMode = null;
    print('🎯 Mode cleared');
  }

  // Check if mode is selected
  bool hasMode() {
    return _selectedMode != null;
  }
}