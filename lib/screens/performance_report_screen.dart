import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import '../services/unified_race_data_service.dart';

class PerformanceReportScreen extends StatefulWidget {
  const PerformanceReportScreen({super.key});

  static const routeName = '/performance-report';

  @override
  State<PerformanceReportScreen> createState() =>
      _PerformanceReportScreenState();
}

class _PerformanceReportScreenState extends State<PerformanceReportScreen> {
  String selectedTimeframe = 'Last 30 Days';
  String selectedMode = 'All Modes';
  final UnifiedRaceDataService _dataService = UnifiedRaceDataService();
  Map<String, dynamic>? _analyticsData;
  List<Map<String, dynamic>> _raceData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPerformanceData();
  }

  Future<void> _loadPerformanceData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Calculate date range based on selected timeframe
      DateTime? startDate;
      DateTime now = DateTime.now();

      switch (selectedTimeframe) {
        case 'Last 7 Days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last 30 Days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last 3 Months':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'All Time':
          startDate = null;
          break;
      }

      // Apply filters
      try {
        final raceRecords = await _dataService.getRaceDataFiltered(
          mode: selectedMode == 'All Modes' ? null : selectedMode,
          startDate: startDate,
          endDate: now,
        );

        // Get analytics for the filtered data
        final analytics = await _dataService.getAnalytics(
          startDate: startDate,
          endDate: now,
        );

        if (mounted) {
          setState(() {
            _analyticsData = analytics;
            _raceData = raceRecords;
            _isLoading = false;
          });
        }
      } catch (e, stackTrace) {
        print('Error loading performance data: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          setState(() {
            _analyticsData = null;
            _raceData = [];
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('Error in _loadPerformanceData: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          title: Text(
            'Performance Report',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          centerTitle: true,
          foregroundColor: const Color(0xFF1E293B),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading performance data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'Performance Report',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.filter),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.filter,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Showing: $selectedMode • $selectedTimeframe',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

              const SizedBox(height: 24),

              // Best Performers Section
              _buildSectionHeader(
                'Top Performers',
                'Best riders across all categories',
              ),
              const SizedBox(height: 16),

              _buildTopPerformers(),

              const SizedBox(height: 32),

              // Performance Analytics
              _buildSectionHeader(
                'Performance Analytics',
                'Detailed breakdown by categories',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Average Time',
                      _formatTime(
                        (_analyticsData?['summary']?['averageTime'] ?? 0).toDouble(),
                      ),
                      'Based on ${_raceData.length} sessions',
                      FontAwesomeIcons.clock,
                      Colors.green.shade600,
                      600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Success Rate',
                      '${_analyticsData?['summary']?['successRate']?.toString() ?? '0'}%',
                      'Completed within target time',
                      FontAwesomeIcons.bullseye,
                      Colors.blue.shade600,
                      800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Best Time',
                      _formatTime((_analyticsData?['summary']?['bestTime'] ?? 0).toDouble()),
                      'Personal best record',
                      FontAwesomeIcons.trophy,
                      Colors.amber.shade600,
                      1000,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Total Sessions',
                      _analyticsData?['summary']?['totalSessions']
                              ?.toString() ??
                          '0',
                      'Across all modes',
                      FontAwesomeIcons.calendar,
                      Colors.purple.shade600,
                      1200,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent Performance Trends
              _buildSectionHeader(
                'Recent Sessions',
                'Last 5 recorded sessions',
              ),
              const SizedBox(height: 16),

              ..._buildRecentSessionsList(),

              const SizedBox(height: 32),

              // Export/Action Buttons
              // Row(
              //       children: [
              //         Expanded(
              //           child: ElevatedButton.icon(
              //             onPressed: _isLoading ? null : () => _exportReport(),
              //             icon: _isLoading
              //                 ? const SizedBox(
              //                     width: 20,
              //                     height: 20,
              //                     child: CircularProgressIndicator(
              //                       color: Colors.white,
              //                       strokeWidth: 2,
              //                     ),
              //                   )
              //                 : const Icon(FontAwesomeIcons.download),
              //             label: Text(_isLoading ? 'Exporting Report...' : 'Export Performance Report'),
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: Colors.blue.shade600,
              //               foregroundColor: Colors.white,
              //               padding: const EdgeInsets.symmetric(vertical: 16),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 16),
              //         Expanded(
              //           child: OutlinedButton.icon(
              //             onPressed: () => _shareReport(),
              //             icon: const Icon(FontAwesomeIcons.share),
              //             label: const Text('Share Report'),
              //             style: OutlinedButton.styleFrom(
              //               foregroundColor: Colors.blue.shade600,
              //               side: BorderSide(color: Colors.blue.shade600),
              //               padding: const EdgeInsets.symmetric(vertical: 16),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     )
              //     .animate()
              //     .fadeIn(duration: 600.ms, delay: 2000.ms)
              //     .slideY(begin: 0.3),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(double timeInSeconds) {
    if (timeInSeconds == 0) return '0:00.0';

    int minutes = (timeInSeconds / 60).floor();
    double seconds = timeInSeconds % 60;

    return '${minutes}:${seconds.toStringAsFixed(1).padLeft(4, '0')}';
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Unknown';

    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();

      int daysDiff = now.difference(date).inDays;
      if (daysDiff == 0) return 'Today';
      if (daysDiff == 1) return 'Yesterday';
      if (daysDiff < 7) return '$daysDiff days ago';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTopPerformers() {
    if (_raceData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No performance data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Group data by rider and calculate best times
    Map<String, Map<String, dynamic>> riderData = {};

    try {
      for (var entry in _raceData) {
        try {
          // Validate entry structure
          if (entry == null || entry is! Map) continue;

          final rider = entry['rider'];
          final performance = entry['performance'];
          final event = entry['event'];

          if (rider is! Map || performance is! Map || event is! Map) continue;

          String riderName = rider['name']?.toString() ?? 'Unknown';
          if (riderName == 'Unknown') continue;

          // Get elapsed time safely
          double time = 0.0;
          final elapsedSeconds = performance['elapsedSeconds'];
          if (elapsedSeconds is int) {
            time = elapsedSeconds.toDouble();
          } else if (elapsedSeconds is double) {
            time = elapsedSeconds;
          }

          String mode = event['mode']?.toString() ?? 'Unknown';

          if (time > 0) {
            if (!riderData.containsKey(riderName)) {
              riderData[riderName] = {
                'bestTime': time,
                'sessionCount': 1,
                'mode': mode,
                'horseName': rider['horseName']?.toString() ?? 'Unknown Horse',
              };
            } else {
              if (time < riderData[riderName]!['bestTime']) {
                riderData[riderName]!['bestTime'] = time;
                riderData[riderName]!['mode'] = mode;
                riderData[riderName]!['horseName'] = rider['horseName']?.toString() ?? 'Unknown Horse';
              }
              riderData[riderName]!['sessionCount']++;
            }
          }
        } catch (e) {
          print('Error processing entry in _buildTopPerformers: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in _buildTopPerformers: $e');
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Error loading performance data: $e',
          style: const TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Sort by best time and take top performers
    var sortedPerformers = riderData.entries.toList()
      ..sort((a, b) => a.value['bestTime'].compareTo(b.value['bestTime']));

    List<Widget> performerCards = [];

    for (int i = 0; i < sortedPerformers.length && i < 3; i++) {
      var performer = sortedPerformers[i];
      String riderName = performer.key;
      double bestTime = performer.value['bestTime'];
      int sessionCount = performer.value['sessionCount'];
      String mode = performer.value['mode'];
      String horseName = performer.value['horseName'] ?? 'Unknown Horse';

      performerCards.add(
        _buildPerformerCard(
          rank: i + 1,
          name: riderName,
          horse: horseName,
          bestTime: _formatTime(bestTime),
          mode: mode,
          improvement: '$sessionCount sessions',
          avatar: String.fromCharCode(0x1F3C7 + i), // Different emojis
          color: i == 0
              ? Colors.amber.shade600
              : i == 1
              ? Colors.grey.shade600
              : Colors.orange.shade600,
          delay: 200 + (i * 200),
        ),
      );

      if (i < sortedPerformers.length - 1 && i < 2) {
        performerCards.add(const SizedBox(height: 16));
      }
    }

    return Column(children: performerCards);
  }

  List<Widget> _buildRecentSessionsList() {
    if (_raceData.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No recent sessions available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    try {
      // Filter valid sessions only
      var validSessions = _raceData.where((session) {
        try {
          return session is Map &&
                 session['rider'] is Map &&
                 session['event'] is Map &&
                 session['performance'] is Map &&
                 session['timestamp'] != null;
        } catch (e) {
          return false;
        }
      }).toList();

      if (validSessions.isEmpty) {
        return [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No valid sessions available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ];
      }

      // Sort by date (most recent first) and take last 5
      var sortedSessions = List<Map<String, dynamic>>.from(validSessions);
      sortedSessions.sort((a, b) {
        try {
          DateTime dateA = DateTime.tryParse(a['timestamp']?.toString() ?? '') ?? DateTime.now();
          DateTime dateB = DateTime.tryParse(b['timestamp']?.toString() ?? '') ?? DateTime.now();
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      List<Widget> sessionWidgets = [];
      int count = sortedSessions.length > 5 ? 5 : sortedSessions.length;

      for (int i = 0; i < count; i++) {
        try {
          var session = sortedSessions[i];
          sessionWidgets.add(_buildSessionCard(session, i * 100 + 1400));

          if (i < count - 1) {
            sessionWidgets.add(const SizedBox(height: 12));
          }
        } catch (e) {
          print('Error building session card $i: $e');
        }
      }

      return sessionWidgets.isNotEmpty ? sessionWidgets : [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Error displaying sessions',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    } catch (e) {
      print('Error in _buildRecentSessionsList: $e');
      return [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Error loading sessions: $e',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildPerformerCard({
    required int rank,
    required String name,
    required String horse,
    required String bestTime,
    required String mode,
    required String improvement,
    required String avatar,
    required Color color,
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Avatar
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  avatar,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Horse: $horse',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            mode,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Performance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bestTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      improvement,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: 0.3);
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    int delay,
  ) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Icon(
                    change.contains('↑')
                        ? FontAwesomeIcons.arrowUp
                        : FontAwesomeIcons.arrowDown,
                    size: 12,
                    color: change.contains('↑')
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color: change.contains('↑')
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideY(begin: 0.3);
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int delay) {
    try {
      // Safely extract values with type checking
      double time = 0.0;
      final elapsedSeconds = session['performance']?['elapsedSeconds'];
      if (elapsedSeconds is int) {
        time = elapsedSeconds.toDouble();
      } else if (elapsedSeconds is double) {
        time = elapsedSeconds;
      } else if (elapsedSeconds != null) {
        time = double.tryParse(elapsedSeconds.toString()) ?? 0.0;
      }

      final String riderName = session['rider']?['name']?.toString() ?? 'Unknown';
      final String mode = session['event']?['mode']?.toString() ?? 'Unknown';
      final String location = session['event']?['location']?['name']?.toString() ?? '';
      final String date = session['timestamp']?.toString() ?? '';
      final bool isSuccess = session['performance']?['isSuccess'] == true;

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          riderName,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                        Text(
                          _formatDate(date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          mode + (location.isNotEmpty ? ' • $location' : ''),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          _formatTime(time),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSuccess
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: 0.2);
    } catch (e) {
      print('Error building session card: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Text(
          'Error displaying session',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  void _showFilterDialog() {
    String tempTimeframe = selectedTimeframe;
    String tempMode = selectedMode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempTimeframe,
                decoration: const InputDecoration(labelText: 'Timeframe'),
                items: [
                  'Last 7 Days',
                  'Last 30 Days',
                  'Last 3 Months',
                  'All Time',
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    tempTimeframe = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempMode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: [
                  'All Modes',
                  'Show Jumping',
                  'Mounted Sports',
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    tempMode = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedTimeframe = tempTimeframe;
                  selectedMode = tempMode;
                });
                Navigator.pop(context);
                _loadPerformanceData();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Add a small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      // Create a simple text report
      final StringBuffer reportBuffer = StringBuffer();

      reportBuffer.writeln('PERFORMANCE REPORT');
      reportBuffer.writeln('==================');
      reportBuffer.writeln('');

      // Performance Summary
      reportBuffer.writeln('PERFORMANCE SUMMARY');
      reportBuffer.writeln('-------------------');

      if (_analyticsData != null && _analyticsData!['summary'] != null) {
        reportBuffer.writeln(
          'Total Sessions: ${_analyticsData!['summary']['totalSessions'] ?? 0}',
        );
        reportBuffer.writeln(
          'Average Time: ${_formatTime(_analyticsData!['summary']['averageTime']?.toDouble() ?? 0)}',
        );
        reportBuffer.writeln(
          'Best Time: ${_formatTime(_analyticsData!['summary']['bestTime']?.toDouble() ?? 0)}',
        );
        reportBuffer.writeln(
          'Success Rate: ${_analyticsData!['summary']['successRate']?.toString() ?? '0'}%',
        );
      } else {
        reportBuffer.writeln('No performance data available');
      }

      reportBuffer.writeln('');

      // Recent Sessions
      reportBuffer.writeln('RECENT SESSIONS');
      reportBuffer.writeln('---------------');

      if (_raceData.isNotEmpty) {
        reportBuffer.writeln('Rider\t\t\tMode\t\t\tTime\t\t\tDate');
        reportBuffer.writeln('-----\t\t\t----\t\t\t----\t\t\t----');

        for (var session in _raceData.take(10)) {
          try {
            if (session is! Map) continue;

            final rider = session['rider']?['name']?.toString() ?? 'Unknown';
            final mode = session['event']?['mode']?.toString() ?? 'Unknown';

            double timeValue = 0.0;
            final elapsedSeconds = session['performance']?['elapsedSeconds'];
            if (elapsedSeconds is int) {
              timeValue = elapsedSeconds.toDouble();
            } else if (elapsedSeconds is double) {
              timeValue = elapsedSeconds;
            }

            final time = _formatTime(timeValue);
            final date = _formatDate(session['timestamp']?.toString() ?? '');

            reportBuffer.writeln('$rider\t\t\t$mode\t\t\t$time\t\t\t$date');
          } catch (e) {
            print('Error exporting session: $e');
            continue;
          }
        }
      } else {
        reportBuffer.writeln('No recent sessions available');
      }

      reportBuffer.writeln('');
      reportBuffer.writeln(
        'Generated on: ${DateTime.now().toString().split(' ')[0]}',
      );

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: reportBuffer.toString()));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show detailed export information dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Report Exported Successfully!'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your performance report has been copied to your clipboard.'),
                  SizedBox(height: 16),
                  Text('How to access your exported report:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Open any text editor (Notepad, Word, Google Docs, etc.)'),
                  Text('• Press Ctrl+V (Windows) or Cmd+V (Mac) to paste'),
                  Text('• Save the document to your desired location'),
                  SizedBox(height: 16),
                  Text('The report includes all performance metrics, analytics, and recent session data in a formatted text layout.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Got it!'),
                ),
              ],
            );
          },
        );

        // Also show the snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Report copied to clipboard - check the dialog for details')),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to export report: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _shareReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report shared successfully')));
  }
}
