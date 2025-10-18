import 'package:flutter/material.dart';
import 'services/unified_race_data_service.dart';

/// Debug screen to check data integrity
class DataDebugScreen extends StatefulWidget {
  const DataDebugScreen({super.key});

  @override
  State<DataDebugScreen> createState() => _DataDebugScreenState();
}

class _DataDebugScreenState extends State<DataDebugScreen> {
  final _dataService = UnifiedRaceDataService();
  String _status = 'Checking data...';
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _checkData();
  }

  Future<void> _checkData() async {
    try {
      final stats = await _dataService.getDataStats();
      final data = await _dataService.loadAllRaceData();

      setState(() {
        _stats = stats;
        _status = 'Data OK - ${stats['totalRecords']} records found';
      });

      // Check each record
      int validRecords = 0;
      int invalidRecords = 0;

      for (var record in data) {
        if (record['rider'] is Map &&
            record['event'] is Map &&
            record['performance'] is Map) {
          validRecords++;
        } else {
          invalidRecords++;
          print('Invalid record structure: ${record['id']}');
        }
      }

      setState(() {
        _status =
            'Found $validRecords valid records, $invalidRecords invalid records';
      });
    } catch (e, stackTrace) {
      setState(() {
        _status = 'Error: $e';
      });
      print('Error checking data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will delete all race data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dataService.clearAllData();
      _checkData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (_stats != null) ...[
              Text('Total Records: ${_stats!['totalRecords']}'),
              Text('File Size: ${_stats!['fileSizeBytes']} bytes'),
              Text('Cache Status: ${_stats!['cacheStatus']}'),
              Text('File Path: ${_stats!['dataFilePath']}',
                  style: const TextStyle(fontSize: 10)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkData,
              child: const Text('Recheck Data'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Clear All Data (Dangerous!)'),
            ),
          ],
        ),
      ),
    );
  }
}
