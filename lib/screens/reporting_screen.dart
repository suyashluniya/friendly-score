import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/unified_race_data_service.dart';
import 'race_detail_screen.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  static const routeName = '/reporting';

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  final UnifiedRaceDataService _dataService = UnifiedRaceDataService();
  List<Map<String, dynamic>> _allRaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllRaces();
  }

  Future<void> _loadAllRaces() async {
    try {
      // Trigger migration of old data if needed
      try {
        await _dataService.migrateOldData();
      } catch (migrationError) {
        print('Warning: Migration failed but continuing: $migrationError');
      }

      // Load all race data
      final races = await _dataService.loadAllRaceData();

      // Sort by timestamp - newest first
      races.sort((a, b) {
        final aTimestamp = a['timestamp']?.toString() ?? '';
        final bTimestamp = b['timestamp']?.toString() ?? '';
        return bTimestamp.compareTo(aTimestamp); // Descending order
      });

      if (mounted) {
        setState(() {
          _allRaces = races;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading race data: $e');
      if (mounted) {
        setState(() {
          _allRaces = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'All Race Records',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading race records...'),
                ],
              ),
            )
          : _allRaces.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.inbox,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No race records found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start racing to see records here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAllRaces,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allRaces.length,
                itemBuilder: (context, index) {
                  final race = _allRaces[index];
                  return _buildRaceCard(context, race, index);
                },
              ),
            ),
    );
  }

  Widget _buildRaceCard(
    BuildContext context,
    Map<String, dynamic> race,
    int index,
  ) {
    final rider = race['rider'] as Map<String, dynamic>? ?? {};
    final performance = race['performance'] as Map<String, dynamic>? ?? {};
    final event = race['event'] as Map<String, dynamic>? ?? {};

    final riderName = rider['name']?.toString() ?? 'Rider name not available';
    final riderNumber = rider['number']?.toString() ?? '';
    final elapsedTime = performance['elapsedTime']?.toString() ?? '00:00:00:00';
    final isSuccess = performance['isSuccess'] ?? false;
    final isStopped = performance['isStopped'] ?? false;
    final mode = event['mode']?.toString() ?? 'Unknown Mode';
    final timestamp = race['timestamp']?.toString() ?? '';

    // Determine status
    String status;
    Color statusColor;
    IconData statusIcon;

    if (isStopped) {
      status = 'STOPPED';
      statusColor = Colors.orange.shade600;
      statusIcon = FontAwesomeIcons.stop;
    } else if (isSuccess) {
      status = 'FINISHED';
      statusColor = Colors.green.shade600;
      statusIcon = FontAwesomeIcons.flagCheckered;
    } else {
      status = 'DISQUALIFIED';
      statusColor = Colors.red.shade600;
      statusIcon = FontAwesomeIcons.xmark;
    }

    // Format timestamp
    String formattedDate = '';
    String formattedTime = '';
    if (timestamp.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(timestamp);
        formattedDate =
            '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
        formattedTime =
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDate = 'Unknown date';
        formattedTime = '';
      }
    }

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RaceDetailScreen(raceData: race),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Left side - Main info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rider name
                          Text(
                            riderName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                          const SizedBox(height: 4),

                          // Rider number and mode
                          Row(
                            children: [
                              if (riderNumber.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '#$riderNumber',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  mode,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Time and date
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.clock,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$formattedDate • $formattedTime',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right side - Time and status
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Elapsed time
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            elapsedTime,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                  fontFeatures: [
                                    const FontFeature.tabularFigures(),
                                  ],
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 10, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 50).ms)
        .slideX(begin: 0.2, duration: 400.ms, delay: (index * 50).ms);
  }
}
