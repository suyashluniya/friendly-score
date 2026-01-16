import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing PIN storage and validation
class PinService {
  static const String _pinKey = 'user_pin';
  static const String _defaultPin = '0000';
  static const String _masterResetPhrase = 'masterreset';

  /// Get the stored PIN or return default PIN if not set
  Future<String> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) ?? _defaultPin;
  }

  /// Set a new PIN
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  /// Verify if the provided PIN matches the stored PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    return pin == storedPin;
  }

  /// Verify if the provided phrase matches the master reset phrase
  Future<bool> verifyMasterReset(String phrase) async {
    return phrase.toLowerCase() == _masterResetPhrase;
  }

  /// Reset PIN to default (0000)
  Future<void> resetToDefault() async {
    await setPin(_defaultPin);
  }
}
