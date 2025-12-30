import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../services/location_service.dart';
import '../services/mode_service.dart';
import '../utils/logger.dart';

class UnifiedRaceDataService {
  static const String _fileName = 'unified_race_data.json';
  static UnifiedRaceDataService? _instance;

  // Cache for race data
  List<Map<String, dynamic>>? _cachedData;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

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
  Future<List<Map<String, dynamic>>> loadAllRaceData({
    bool forceRefresh = false,
  }) async {
    // Check if we have valid cached data
    if (!forceRefresh &&
        _cachedData != null &&
        _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
      Logger.debug(
        'Returning cached race data (${_cachedData!.length} records)',
        tag: 'DataService',
      );
      return _cachedData!;
    }

    try {
      final file = await _getDataFile();

      // If file doesn't exist, return empty array
      if (!await file.exists()) {
        Logger.info(
          'Unified race data file not found, returning empty data',
          tag: 'DataService',
        );
        return [];
      }

      final jsonString = await file.readAsString();
      if (jsonString.trim().isEmpty) {
        return [];
      }

      try {
        final data = jsonDecode(jsonString);

        List<Map<String, dynamic>> result = [];
        // Handle both array and object formats for backward compatibility
        if (data is List) {
          // Filter out any invalid entries
          for (var item in data) {
            if (item is Map) {
              try {
                result.add(Map<String, dynamic>.from(item));
              } catch (e) {
                Logger.warning(
                  'Skipping invalid data entry',
                  tag: 'DataService',
                );
              }
            }
          }
        } else if (data is Map) {
          // If it's a single object, wrap it in an array
          result = [Map<String, dynamic>.from(data)];
        } else {
          Logger.warning(
            'Unexpected data format in unified file',
            tag: 'DataService',
          );
          result = [];
        }

        // Validate each record has the required structure
        result = result.where((record) {
          try {
            // Check if record has the minimum required fields
            return record['id'] != null &&
                record['timestamp'] != null &&
                record['performance'] is Map;
          } catch (e) {
            Logger.warning('Skipping malformed record', tag: 'DataService');
            return false;
          }
        }).toList();

        // Cache the loaded data
        _cachedData = result;
        _cacheTimestamp = DateTime.now();
        Logger.info(
          'Loaded and cached ${result.length} valid race records',
          tag: 'DataService',
        );

        return result;
      } on FormatException catch (e) {
        Logger.error('JSON parsing error', tag: 'DataService', error: e);
        // Try to restore from backup
        final backupFile = File('${file.path}.backup');
        if (await backupFile.exists()) {
          Logger.info(
            'Attempting to restore from backup...',
            tag: 'DataService',
          );
          try {
            final backupJsonString = await backupFile.readAsString();
            final backupData = jsonDecode(backupJsonString);
            // Restore the backup to the main file
            await file.writeAsString(backupJsonString);
            Logger.info(
              'Successfully restored from backup',
              tag: 'DataService',
            );
            if (backupData is List) {
              return List<Map<String, dynamic>>.from(backupData);
            }
          } catch (backupError) {
            Logger.error(
              'Backup file is also corrupted',
              tag: 'DataService',
              error: backupError,
            );
          }
        }
        return [];
      }
    } catch (e) {
      Logger.error('Error loading race data', tag: 'DataService', error: e);
      return [];
    }
  }

  /// Save a new race record to the unified file
  Future<bool> saveRaceData({
    required String riderName,
    required String riderNumber,
    required String photoPath,
    required int elapsedSeconds,
    required int maxSeconds,
    required bool isSuccess,
    int elapsedHours = 0,
    int elapsedMinutes = 0,
    int elapsedSecondsOnly = 0,
    int elapsedMilliseconds = 0,
    String? raceStatus,
  }) async {
    try {
      // Validate input data
      if (elapsedSeconds < 0) {
        Logger.error(
          'Validation error: Elapsed seconds cannot be negative',
          tag: 'DataService',
        );
        return false;
      }
      if (maxSeconds <= 0) {
        Logger.error(
          'Validation error: Max seconds must be greater than zero',
          tag: 'DataService',
        );
        return false;
      }

      // Get services
      final locationService = LocationService();
      final modeService = ModeService();

      // Load current location data
      final locationData = await locationService.loadLocation();

      // Calculate improvement percentage (must await this Future)
      final improvementPercentage = await _calculateImprovementPercentage(
        riderName,
        elapsedSeconds,
      );

      // Create the new race record
      final newRaceRecord = {
        'id': _generateUniqueId(),
        'timestamp': DateTime.now().toIso8601String(),
        'event': {
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
          'number': riderNumber,
          'photoPath': photoPath,
        },
        'performance': {
          'elapsedTime': _formatTime(
            elapsedSeconds,
            hours: elapsedHours,
            minutes: elapsedMinutes,
            seconds: elapsedSecondsOnly,
            milliseconds: elapsedMilliseconds,
          ),
          'elapsedSeconds': elapsedSeconds,
          'elapsedMilliseconds': elapsedMilliseconds,
          'elapsedComponents': {
            'hours': elapsedHours,
            'minutes': elapsedMinutes,
            'seconds': elapsedSecondsOnly,
            'milliseconds': elapsedMilliseconds,
          },
          'targetTime': _formatTime(maxSeconds),
          'targetSeconds': maxSeconds,
          'targetMilliseconds': 0,
          'isSuccess': isSuccess,
          'isStopped': raceStatus == 'stopped', // Add isStopped field for badges
          'status': _getStatusString(isSuccess, raceStatus),
          'improvementPercentage': improvementPercentage,
        },
        'hardware': {
          'connectionSuccess': true, // Assume successful if we reach this point
          'deviceUsed': 'IR-Timer-Module',
          'connectionAttempts': 1,
        },
        'version': '1.0', // For future data migration compatibility
      };

      // Load existing data
      final existingData = await loadAllRaceData();

      // Add new record
      existingData.add(newRaceRecord);

      // Create backup before saving
      final file = await _getDataFile();
      if (await file.exists()) {
        final backupFile = File('${file.path}.backup');
        try {
          await file.copy(backupFile.path);
        } catch (e) {
          Logger.warning('Could not create backup file', tag: 'DataService');
        }
      }

      // Save updated data
      try {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(existingData),
        );

        // Invalidate cache after saving
        _cachedData = null;
        _cacheTimestamp = null;
      } catch (e) {
        Logger.error('Error writing data file', tag: 'DataService', error: e);
        // Try to restore from backup
        final backupFile = File('${file.path}.backup');
        if (await backupFile.exists()) {
          await backupFile.copy(file.path);
          Logger.info('Restored data from backup', tag: 'DataService');
        }
        return false;
      }

      Logger.info(
        'Race data saved to unified file. Total records: ${existingData.length}',
        tag: 'DataService',
      );
      return true;
    } catch (e) {
      Logger.error('Error saving race data', tag: 'DataService', error: e);
      return false;
    }
  }

  /// Generate a unique ID for each race record
  String _generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'race_$timestamp$random';
  }

  /// Get status string based on success and race status
  String _getStatusString(bool isSuccess, String? raceStatus) {
    if (raceStatus == 'stopped') {
      return 'Stopped';
    } else if (isSuccess) {
      return 'Completed';
    } else {
      return 'Time Exceeded';
    }
  }

  /// Format time as HH:MM:SS:CC (centiseconds)
  String _formatTime(
    int totalSeconds, {
    int? hours,
    int? minutes,
    int? seconds,
    int milliseconds = 0,
  }) {
    final int limitedMillis = milliseconds.clamp(0, 999).toInt();
    final int totalMilliseconds = (totalSeconds * 1000) + limitedMillis;
    final duration = Duration(milliseconds: totalMilliseconds);

    final resolvedHours = hours ?? duration.inHours;
    final resolvedMinutes = minutes ?? duration.inMinutes.remainder(60);
    final resolvedSeconds = seconds ?? duration.inSeconds.remainder(60);
    final int rawCentiseconds = duration.inMilliseconds.remainder(1000) ~/ 10;
    final int centiseconds = rawCentiseconds.clamp(0, 99).toInt();

    return '${resolvedHours.toString().padLeft(2, '0')}:'
        '${resolvedMinutes.toString().padLeft(2, '0')}:'
        '${resolvedSeconds.toString().padLeft(2, '0')}:'
        '${centiseconds.toString().padLeft(2, '0')}';
  }

  /// Calculate improvement percentage for a rider
  Future<double> _calculateImprovementPercentage(
    String riderName,
    int currentTime,
  ) async {
    try {
      final existingData = await loadAllRaceData();
      final riderRecords = existingData.where((record) {
        final name = record['rider']?['name'];
        return name != null && name == riderName;
      }).toList();

      if (riderRecords.isEmpty) {
        return 0.0; // First record for this rider
      }

      // Sort by timestamp to get the most recent previous record
      riderRecords.sort((a, b) {
        final aTimestamp = a['timestamp']?.toString() ?? '';
        final bTimestamp = b['timestamp']?.toString() ?? '';
        return aTimestamp.compareTo(bTimestamp);
      });
      final previousRecord = riderRecords.last;
      final previousTimeValue =
          previousRecord['performance']?['elapsedSeconds'];

      int previousTime = 0;
      if (previousTimeValue is int) {
        previousTime = previousTimeValue;
      } else if (previousTimeValue is double) {
        previousTime = previousTimeValue.toInt();
      }

      if (previousTime == 0) return 0.0;

      final improvement = ((previousTime - currentTime) / previousTime) * 100;
      return double.parse(improvement.toStringAsFixed(2));
    } catch (e) {
      Logger.warning('Error calculating improvement', tag: 'DataService');
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
      filteredData = filteredData.where((record) {
        final name = record['rider']?['name'];
        if (name == null) return false;
        return name.toString().toLowerCase().contains(riderName.toLowerCase());
      }).toList();
    }

    // Filter by mode
    if (mode != null && mode.isNotEmpty && mode != 'All Modes') {
      filteredData = filteredData.where((record) {
        final recordMode = record['event']?['mode'];
        return recordMode != null && recordMode == mode;
      }).toList();
    }

    // Filter by location
    if (location != null && location.isNotEmpty) {
      filteredData = filteredData.where((record) {
        final locationName = record['event']?['location']?['name'];
        if (locationName == null) return false;
        return locationName.toString().toLowerCase().contains(
          location.toLowerCase(),
        );
      }).toList();
    }

    // Filter by date range
    if (startDate != null) {
      filteredData = filteredData.where((record) {
        try {
          final timestamp = record['timestamp'];
          if (timestamp == null) return false;
          final recordDate = DateTime.parse(timestamp.toString());
          return recordDate.isAfter(startDate) ||
              recordDate.isAtSameMomentAs(startDate);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (endDate != null) {
      filteredData = filteredData.where((record) {
        try {
          final timestamp = record['timestamp'];
          if (timestamp == null) return false;
          final recordDate = DateTime.parse(timestamp.toString());
          return recordDate.isBefore(endDate) ||
              recordDate.isAtSameMomentAs(endDate);
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter by success status
    if (successOnly != null) {
      filteredData = filteredData.where((record) {
        final isSuccess = record['performance']?['isSuccess'];
        return isSuccess == successOnly;
      }).toList();
    }

    // Sort by timestamp (most recent first)
    filteredData.sort((a, b) {
      try {
        final aTimestamp = a['timestamp']?.toString() ?? '';
        final bTimestamp = b['timestamp']?.toString() ?? '';
        return bTimestamp.compareTo(aTimestamp);
      } catch (e) {
        return 0;
      }
    });

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
    try {
      final data = await getRaceDataFiltered(
        startDate: startDate,
        endDate: endDate,
      );

      if (data.isEmpty) {
        return _getEmptyAnalytics();
      }

      // Validate all data entries before processing
      final validData = data.where((record) {
        try {
          return record['performance'] is Map &&
              record['rider'] is Map &&
              record['event'] is Map;
        } catch (e) {
          return false;
        }
      }).toList();

      if (validData.isEmpty) {
        return _getEmptyAnalytics();
      }

      // Basic statistics
      final totalSessions = validData.length;
      final successfulSessions = validData
          .where((r) => r['performance']?['isSuccess'] == true)
          .length;
      final successRate = totalSessions > 0
          ? (successfulSessions / totalSessions * 100)
          : 0.0;

      // Time statistics - filter out invalid times
      final times = validData
          .map((r) {
            final elapsed = r['performance']?['elapsedSeconds'];
            if (elapsed == null) return 0;
            if (elapsed is int) return elapsed;
            if (elapsed is double) return elapsed.toInt();
            return 0;
          })
          .where((time) => time > 0)
          .toList();

      if (times.isEmpty) {
        return _getEmptyAnalytics();
      }

      times.sort();
      final averageTime = times.reduce((a, b) => a + b) / times.length;
      final bestTime = times.first;
      final worstTime = times.last;

      // Rider statistics
      final riderStats = <String, Map<String, dynamic>>{};
      for (final record in validData) {
        final riderName = record['rider']?['name'];
        if (riderName == null || riderName.toString().isEmpty) continue;

        final riderNameStr = riderName.toString();
        if (!riderStats.containsKey(riderNameStr)) {
          riderStats[riderNameStr] = {
            'sessions': 0,
            'successfulSessions': 0,
            'bestTime': double.infinity,
            'totalTime': 0,
            'horseName': record['rider']?['horseName'] ?? 'Unknown Horse',
          };
        }

        final stats = riderStats[riderNameStr]!;
        stats['sessions']++;
        if (record['performance']?['isSuccess'] == true) {
          stats['successfulSessions']++;
        }

        final elapsed = record['performance']?['elapsedSeconds'];
        int elapsedTime = 0;
        if (elapsed is int) {
          elapsedTime = elapsed;
        } else if (elapsed is double) {
          elapsedTime = elapsed.toInt();
        }

        if (elapsedTime > 0) {
          stats['totalTime'] += elapsedTime;
          if (elapsedTime < stats['bestTime']) {
            stats['bestTime'] = elapsedTime.toDouble();
          }
        }
      }

      // Mode statistics
      final modeStats = <String, int>{};
      for (final record in validData) {
        final mode = record['event']?['mode'];
        if (mode != null && mode.toString().isNotEmpty) {
          final modeStr = mode.toString();
          modeStats[modeStr] = (modeStats[modeStr] ?? 0) + 1;
        }
      }

      // Location statistics
      final locationStats = <String, int>{};
      for (final record in validData) {
        final location = record['event']?['location']?['name'];
        if (location != null && location.toString().isNotEmpty) {
          final locationStr = location.toString();
          locationStats[locationStr] = (locationStats[locationStr] ?? 0) + 1;
        }
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
        'recentSessions': validData.take(10).toList(),
      };
    } catch (e, stackTrace) {
      Logger.error(
        'Error calculating analytics',
        tag: 'DataService',
        error: e,
        stackTrace: stackTrace,
      );
      return _getEmptyAnalytics();
    }
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
        Logger.info('No old race results directory found', tag: 'Migration');
        return;
      }

      final files = await raceResultsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      if (files.isEmpty) {
        Logger.info('No old JSON files found to migrate', tag: 'Migration');
        return;
      }

      Logger.info(
        'Starting migration of ${files.length} old files...',
        tag: 'Migration',
      );

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
          Logger.warning('Error migrating file ${file.path}', tag: 'Migration');
        }
      }

      if (migratedCount > 0) {
        // Save migrated data
        final unifiedFile = await _getDataFile();
        await unifiedFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(existingData),
        );

        Logger.info(
          'Successfully migrated $migratedCount records to unified format',
          tag: 'Migration',
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

        Logger.info(
          'Old files archived to: ${archiveDir.path}',
          tag: 'Migration',
        );
      }
    } catch (e) {
      Logger.error('Error during migration', tag: 'Migration', error: e);
    }
  }

  /// Get file path for debugging/export purposes
  Future<String> getDataFilePath() async {
    final file = await _getDataFile();
    return file.path;
  }

  /// Clear all data (use with caution - for debugging only)
  Future<bool> clearAllData() async {
    try {
      final file = await _getDataFile();
      if (await file.exists()) {
        await file.delete();
        _cachedData = null;
        _cacheTimestamp = null;
        Logger.info('All race data cleared', tag: 'DataService');
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Error clearing data', tag: 'DataService', error: e);
      return false;
    }
  }

  /// Get data statistics for debugging
  Future<Map<String, dynamic>> getDataStats() async {
    try {
      final data = await loadAllRaceData();
      final file = await _getDataFile();
      final fileSize = await file.exists() ? await file.length() : 0;

      return {
        'totalRecords': data.length,
        'fileSizeBytes': fileSize,
        'cacheStatus': _cachedData != null ? 'cached' : 'not cached',
        'dataFilePath': file.path,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
