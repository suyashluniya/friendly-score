import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Simple encryption key (in production, this should be more secure)
  static const String _encryptionKey = 'EventLocationKey2024';
  static const String _locationFileName = '.event_location.dat';

  // Simple XOR encryption for location data
  String _encrypt(String data) {
    List<int> bytes = utf8.encode(data);
    List<int> keyBytes = utf8.encode(_encryptionKey);
    
    List<int> encrypted = [];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    // Convert to base64 for safe storage
    return base64Encode(encrypted);
  }

  String _decrypt(String encryptedData) {
    List<int> encrypted = base64Decode(encryptedData);
    List<int> keyBytes = utf8.encode(_encryptionKey);
    
    List<int> decrypted = [];
    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return utf8.decode(decrypted);
  }

  // Get the location file path
  Future<File> _getLocationFile() async {
    final directory = await getApplicationDocumentsDirectory();
    
    // Create race_results folder if it doesn't exist (same as race results)
    final raceResultsDir = Directory('${directory.path}/race_results');
    if (!await raceResultsDir.exists()) {
      await raceResultsDir.create(recursive: true);
    }
    
    return File('${raceResultsDir.path}/$_locationFileName');
  }

  // Save location data
  Future<void> saveLocation({
    required String locationName,
    required String address,
    String? additionalDetails,
  }) async {
    try {
      final file = await _getLocationFile();
      
      final locationData = {
        'locationName': locationName,
        'address': address,
        'additionalDetails': additionalDetails ?? '',
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      
      final jsonString = jsonEncode(locationData);
      final encryptedData = _encrypt(jsonString);
      
      await file.writeAsString(encryptedData);
      print('✅ Location saved successfully: $locationName');
    } catch (e) {
      print('❌ Error saving location: $e');
      throw Exception('Failed to save location: $e');
    }
  }

  // Load location data
  Future<Map<String, dynamic>?> loadLocation() async {
    try {
      final file = await _getLocationFile();
      
      if (!await file.exists()) {
        print('📍 No location file found');
        return null;
      }
      
      final encryptedData = await file.readAsString();
      final jsonString = _decrypt(encryptedData);
      final locationData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      print('✅ Location loaded successfully: ${locationData['locationName']}');
      return locationData;
    } catch (e) {
      print('❌ Error loading location: $e');
      return null;
    }
  }

  // Check if location exists
  Future<bool> hasLocation() async {
    try {
      final file = await _getLocationFile();
      return await file.exists();
    } catch (e) {
      print('❌ Error checking location existence: $e');
      return false;
    }
  }

  // Delete location data
  Future<void> deleteLocation() async {
    try {
      final file = await _getLocationFile();
      if (await file.exists()) {
        await file.delete();
        print('✅ Location data deleted');
      }
    } catch (e) {
      print('❌ Error deleting location: $e');
      throw Exception('Failed to delete location: $e');
    }
  }

  // Format location for display
  String formatLocationDisplay(Map<String, dynamic> locationData) {
    final name = locationData['locationName'] ?? 'Unknown Location';
    final address = locationData['address'] ?? 'No address';
    final lastUpdated = locationData['lastUpdated'] ?? '';
    
    String display = '$name\n$address';
    
    if (lastUpdated.isNotEmpty) {
      try {
        final DateTime date = DateTime.parse(lastUpdated);
        final String formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        display += '\n\nLast updated: $formattedDate';
      } catch (e) {
        // If date parsing fails, just ignore the timestamp
      }
    }
    
    return display;
  }

  // Get location summary for race results
  String getLocationSummary(Map<String, dynamic> locationData) {
    final name = locationData['locationName'] ?? 'Unknown Location';
    final address = locationData['address'] ?? 'No address';
    return '$name - $address';
  }
}