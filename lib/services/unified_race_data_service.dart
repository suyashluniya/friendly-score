import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../services/location_service.dart';
import '../services/mode_service.dart';

class UnifiedRaceDataService {
  static const String _fileName = 'unified_race_data.json';
  static UnifiedRaceDataService? _instance;

  factory UnifiedRaceDataService() {
    _instance ??= UnifiedRaceDataService._internal();
    return _instance!;
  }

  UnifiedRaceDataService._internal();

  /// Get the unified race data file
  Future<File> _getDataFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/race_data');

    // Create directory if it doesn't exist
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    return File('${dataDir.path}/$_fileName');
  }

  /// Load all race data from the unified file
  Future<List<Map<String, dynamic>>> loadAllRaceData() async {
    try {
      final file = await _getDataFile();

      // If file doesn't exist, return empty array
      if (!await file.exists()) {
        print('📄 Unified race data file not found, returning empty data');
        return [];
      }

      final jsonString = await file.readAsString();
      if (jsonString.trim().isEmpty) {
        return [];
      }

      final data = jsonDecode(jsonString);

      // Handle both array and object formats for backward compatibility
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map) {
        // If it's a single object, wrap it in an array
        return [Map<String, dynamic>.from(data)];
      } else {
        print('⚠️ Unexpected data format in unified file');
        return [];
      }
    } catch (e) {
      print('❌ Error loading race data: $e');
      return [];
    }
  }

  /// Save a new race record to the unified file
  Future<bool> saveRaceData({
    required String riderName,
    required String eventName,
    required String horseName,
    required String horseId,
    required String additionalDetails,
    required int elapsedSeconds,
    required int maxSeconds,
    required bool isSuccess,
  }) async {
    try {
      // Get services
      final locationService = LocationService();
      final modeService = ModeService();

      // Load current location data
      final locationData = await locationService.loadLocation();

      // Create the new race record
      final newRaceRecord = {
        'id': _generateUniqueId(),
        'timestamp': DateTime.now().toIso8601String(),
        'event': {
          'name': eventName,
          'mode': modeService.getModeDisplayName(),
          'modeCode': modeService.getMode() ?? 'UNKNOWN',
          'location': locationData != null
              ? {
                  'name': locationData['locationName'] ?? 'Unknown Location',
                  'address': locationData['address'] ?? 'No address',
                  'additionalDetails': locationData['additionalDetails'] ?? '',
                }
              : {
                  'name': 'Unknown Location',
                  'address': 'No address',
                  'additionalDetails': '',
                },
        },
        'rider': {
          'name': riderName,
          'horseName': horseName,
          'horseId': horseId,
        },
        'performance': {
          'elapsedTime': _formatTime(elapsedSeconds),
          'elapsedSeconds': elapsedSeconds,
          'targetTime': _formatTime(maxSeconds),
          'targetSeconds': maxSeconds,
          'isSuccess': isSuccess,
          'status': isSuccess ? 'Completed' : 'Time Exceeded',
          'improvementPercentage': _calculateImprovementPercentage(
            riderName,
            elapsedSeconds,
          ),
        },
        'hardware': {
          'connectionSuccess': true, // Assume successful if we reach this point
          'deviceUsed': 'IR-Timer-Module',
          'connectionAttempts': 1,
        },
        'additionalDetails': additionalDetails,
        'version': '1.0', // For future data migration compatibility
      };

      // Load existing data
      final existingData = await loadAllRaceData();

      // Add new record
      existingData.add(newRaceRecord);

      // Save updated data
      final file = await _getDataFile();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(existingData),
      );

      print(
        '✅ Race data saved to unified file. Total records: ${existingData.length}',
      );
      return true;
    } catch (e) {
      print('❌ Error saving race data: $e');
      return false;
    }
  }

  /// Generate a unique ID for each race record
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'race_$timestamp$random';
  }

  /// Format time in a readable format
  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Calculate improvement percentage for a rider
  Future<double> _calculateImprovementPercentage(
    String riderName,
    int currentTime,
  ) async {
    try {
      final existingData = await loadAllRaceData();
      final riderRecords = existingData
          .where((record) => record['rider']['name'] == riderName)
          .toList();

      if (riderRecords.isEmpty) {
        return 0.0; // First record for this rider
      }

      // Sort by timestamp to get the most recent previous record
      riderRecords.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      final previousRecord = riderRecords.last;
      final previousTime =
          previousRecord['performance']['elapsedSeconds'] as int;

      if (previousTime == 0) return 0.0;

      final improvement = ((previousTime - currentTime) / previousTime) * 100;
      return double.parse(improvement.toStringAsFixed(2));
    } catch (e) {
      print('⚠️ Error calculating improvement: $e');
      return 0.0;
    }
  }

  /// Get race data filtered by various criteria
  Future<List<Map<String, dynamic>>> getRaceDataFiltered({
    String? riderName,
    String? mode,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    bool? successOnly,
    int? limit,
  }) async {
    final allData = await loadAllRaceData();
    var filteredData = allData;

    // Filter by rider name
    if (riderName != null && riderName.isNotEmpty) {
      filteredData = filteredData
          .where(
            (record) => record['rider']['name']
                .toString()
                .toLowerCase()
                .contains(riderName.toLowerCase()),
          )
          .toList();
    }

    // Filter by mode
    if (mode != null && mode.isNotEmpty && mode != 'All Modes') {
      filteredData = filteredData
          .where((record) => record['event']['mode'] == mode)
          .toList();
    }

    // Filter by location
    if (location != null && location.isNotEmpty) {
      filteredData = filteredData
          .where(
            (record) => record['event']['location']['name']
                .toString()
                .toLowerCase()
                .contains(location.toLowerCase()),
          )
          .toList();
    }

    // Filter by date range
    if (startDate != null) {
      filteredData = filteredData.where((record) {
        final recordDate = DateTime.parse(record['timestamp']);
        return recordDate.isAfter(startDate) ||
            recordDate.isAtSameMomentAs(startDate);
      }).toList();
    }

    if (endDate != null) {
      filteredData = filteredData.where((record) {
        final recordDate = DateTime.parse(record['timestamp']);
        return recordDate.isBefore(endDate) ||
            recordDate.isAtSameMomentAs(endDate);
      }).toList();
    }

    // Filter by success status
    if (successOnly != null) {
      filteredData = filteredData
          .where((record) => record['performance']['isSuccess'] == successOnly)
          .toList();
    }

    // Sort by timestamp (most recent first)
    filteredData.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    // Apply limit
    if (limit != null && limit > 0) {
      filteredData = filteredData.take(limit).toList();
    }

    return filteredData;
  }

  /// Get analytics data for reporting
  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final data = await getRaceDataFiltered(
      startDate: startDate,
      endDate: endDate,
    );

    if (data.isEmpty) {
      return _getEmptyAnalytics();
    }

    // Basic statistics
    final totalSessions = data.length;
    final successfulSessions = data
        .where((r) => r['performance']['isSuccess'] == true)
        .length;
    final successRate = (successfulSessions / totalSessions * 100);

    // Time statistics
    final times = data
        .map((r) => r['performance']['elapsedSeconds'] as int)
        .toList();
    times.sort();
    final averageTime = times.reduce((a, b) => a + b) / times.length;
    final bestTime = times.first;
    final worstTime = times.last;

    // Rider statistics
    final riderStats = <String, Map<String, dynamic>>{};
    for (final record in data) {
      final riderName = record['rider']['name'] as String;
      if (!riderStats.containsKey(riderName)) {
        riderStats[riderName] = {
          'sessions': 0,
          'successfulSessions': 0,
          'bestTime': double.infinity,
          'totalTime': 0,
          'horseName': record['rider']['horseName'],
        };
      }

      final stats = riderStats[riderName]!;
      stats['sessions']++;
      if (record['performance']['isSuccess'] == true) {
        stats['successfulSessions']++;
      }

      final elapsedTime = record['performance']['elapsedSeconds'] as int;
      stats['totalTime'] += elapsedTime;
      if (elapsedTime < stats['bestTime']) {
        stats['bestTime'] = elapsedTime.toDouble();
      }
    }

    // Mode statistics
    final modeStats = <String, int>{};
    for (final record in data) {
      final mode = record['event']['mode'] as String;
      modeStats[mode] = (modeStats[mode] ?? 0) + 1;
    }

    // Location statistics
    final locationStats = <String, int>{};
    for (final record in data) {
      final location = record['event']['location']['name'] as String;
      locationStats[location] = (locationStats[location] ?? 0) + 1;
    }

    return {
      'summary': {
        'totalSessions': totalSessions,
        'successfulSessions': successfulSessions,
        'successRate': double.parse(successRate.toStringAsFixed(1)),
        'averageTime': averageTime.round(),
        'bestTime': bestTime,
        'worstTime': worstTime,
        'uniqueRiders': riderStats.length,
        'uniqueLocations': locationStats.length,
      },
      'riders': riderStats,
      'modes': modeStats,
      'locations': locationStats,
      'recentSessions': data.take(10).toList(),
    };
  }

  Map<String, dynamic> _getEmptyAnalytics() {
    return {
      'summary': {
        'totalSessions': 0,
        'successfulSessions': 0,
        'successRate': 0.0,
        'averageTime': 0,
        'bestTime': 0,
        'worstTime': 0,
        'uniqueRiders': 0,
        'uniqueLocations': 0,
      },
      'riders': <String, dynamic>{},
      'modes': <String, dynamic>{},
      'locations': <String, dynamic>{},
      'recentSessions': <Map<String, dynamic>>[],
    };
  }

  /// Migrate old individual JSON files to unified format (for backward compatibility)
  Future<void> migrateOldData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final raceResultsDir = Directory('${directory.path}/race_results');

      if (!await raceResultsDir.exists()) {
        print('📁 No old race results directory found');
        return;
      }

      final files = await raceResultsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      if (files.isEmpty) {
        print('📄 No old JSON files found to migrate');
        return;
      }

      print('🔄 Starting migration of ${files.length} old files...');

      final existingData = await loadAllRaceData();
      var migratedCount = 0;

      for (final file in files) {
        try {
          final jsonString = await file.readAsString();
          final oldData = jsonDecode(jsonString) as Map<String, dynamic>;

          // Convert old format to new unified format
          final migratedRecord = {
            'id': _generateUniqueId(),
            'timestamp':
                oldData['timestamp'] ?? DateTime.now().toIso8601String(),
            'event': oldData['event'] ?? {},
            'rider': oldData['rider'] ?? {},
            'performance': {
              'elapsedTime': oldData['result']?['elapsedTime'] ?? '0s',
              'elapsedSeconds': oldData['result']?['elapsedSeconds'] ?? 0,
              'targetTime': oldData['result']?['maxTime'] ?? '0s',
              'targetSeconds': oldData['result']?['maxSeconds'] ?? 0,
              'isSuccess': oldData['result']?['isSuccess'] ?? false,
              'status': oldData['result']?['status'] ?? 'Unknown',
              'improvementPercentage': 0.0,
            },
            'hardware': {
              'connectionSuccess': true,
              'deviceUsed': 'IR-Timer-Module',
              'connectionAttempts': 1,
            },
            'additionalDetails': oldData['additionalDetails'] ?? '',
            'version': '1.0',
            'migratedFrom': file.path,
          };

          existingData.add(migratedRecord);
          migratedCount++;
        } catch (e) {
          print('⚠️ Error migrating file ${file.path}: $e');
        }
      }

      if (migratedCount > 0) {
        // Save migrated data
        final unifiedFile = await _getDataFile();
        await unifiedFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(existingData),
        );

        print(
          '✅ Successfully migrated $migratedCount records to unified format',
        );

        // Optionally archive old files instead of deleting them
        final archiveDir = Directory('${raceResultsDir.path}/archived');
        if (!await archiveDir.exists()) {
          await archiveDir.create();
        }

        for (final file in files) {
          final fileName = file.path.split('/').last;
          await file.copy('${archiveDir.path}/$fileName');
        }

        print('📦 Old files archived to: ${archiveDir.path}');
      }
    } catch (e) {
      print('❌ Error during migration: $e');
    }
  }

  /// Get file path for debugging/export purposes
  Future<String> getDataFilePath() async {
    final file = await _getDataFile();
    return file.path;
  }
}
