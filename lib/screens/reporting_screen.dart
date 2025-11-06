import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/unified_race_data_service.dart';

class ReportingScreen extends StatefulWidget {
  const ReportingScreen({super.key});

  static const routeName = '/reporting';

  @override
  State<ReportingScreen> createState() => _ReportingScreenState();
}

class _ReportingScreenState extends State<ReportingScreen> {
  final UnifiedRaceDataService _dataService = UnifiedRaceDataService();
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      // Trigger migration of old data if needed (but don't let it block us)
      try {
        await _dataService.migrateOldData();
      } catch (migrationError, stackTrace) {
        print('Warning: Migration failed but continuing: $migrationError');
        print('Migration stack trace: $stackTrace');
      }

      // Load analytics data
      final analytics = await _dataService.getAnalytics();

      if (mounted) {
        setState(() {
          _analyticsData = analytics;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading analytics data: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _analyticsData = null;
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
            'Reports & Analytics',
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
              Text('Loading analytics data...'),
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
          'Reports & Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      FontAwesomeIcons.chartLine,
                      color: Colors.white,
                      size: 32,
                    ).animate().scale(
                      duration: 800.ms,
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 16),
                    Text(
                          'Performance Analytics',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideX(begin: -0.3),
                    const SizedBox(height: 8),
                    Text(
                          'Comprehensive insights into rider performance, event statistics, and training progress across all disciplines.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideX(begin: -0.3),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2),

              const SizedBox(height: 16),

              // Timing Format Note
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'All timing displays are in HH:MM:SS:MS format (Hours:Minutes:Seconds:Milliseconds)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

              const SizedBox(height: 24),

              // Quick Stats Section
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'Total Sessions',
                      _analyticsData?['summary']?['totalSessions']
                              ?.toString() ??
                          '0',
                      FontAwesomeIcons.clock,
                      Colors.green.shade600,
                      0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'Active Riders',
                      _analyticsData?['summary']?['uniqueRiders']?.toString() ??
                          '0',
                      FontAwesomeIcons.users,
                      Colors.blue.shade600,
                      200,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'Best Time',
                      _formatTimeFromSeconds(
                        _analyticsData?['summary']?['bestTime'] ?? 0,
                      ),
                      FontAwesomeIcons.trophy,
                      Colors.amber.shade600,
                      400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickStatCard(
                      context,
                      'Success Rate',
                      '${_analyticsData?['summary']?['successRate']?.toString() ?? '0'}%',
                      FontAwesomeIcons.bullseye,
                      Colors.purple.shade600,
                      600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Report Categories
              Text(
                'Report Categories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms),

              const SizedBox(height: 16),

              // Performance Reports
              _buildReportSection(
                context,
                'Performance Reports',
                'Detailed analysis of rider and horse performance',
                FontAwesomeIcons.chartLine,
                Colors.blue.shade600,
                [
                  _ReportItem(
                    'Best Performers by Mode',
                    'Top riders in Show Jumping & Mounted Sports',
                    FontAwesomeIcons.medal,
                  ),
                  _ReportItem(
                    'Personal Records',
                    'Individual rider best times & achievements',
                    FontAwesomeIcons.stopwatch,
                  ),
                  // _ReportItem(
                  //   'Performance Trends',
                  //   'Progress tracking over time',
                  //   FontAwesomeIcons.chartLine,
                  // ),
                  // _ReportItem(
                  //   'Comparison Analysis',
                  //   'Rider vs rider performance metrics',
                  //   FontAwesomeIcons.balanceScale,
                  // ),
                ],
                1000,
              ),

              const SizedBox(height: 24),

              // Event & Session Reports
              _buildReportSection(
                context,
                'Event & Session Reports',
                'Complete event statistics and session data',
                FontAwesomeIcons.calendar,
                Colors.green.shade600,
                [
                  _ReportItem(
                    'Recent Sessions',
                    'Last 10 recorded sessions with details',
                    FontAwesomeIcons.history,
                  ),
                  // _ReportItem(
                  //   'Event Summary',
                  //   'Complete event breakdowns by location',
                  //   FontAwesomeIcons.mapMarkerAlt,
                  // ),
                  _ReportItem(
                    'Mode Statistics',
                    'Show Jumping vs Mounted Sports analytics',
                    FontAwesomeIcons.chartPie,
                  ),
                  // _ReportItem(
                  //   'Hardware Performance',
                  //   'IR-Timer connection success rates',
                  //   FontAwesomeIcons.microchip,
                  // ),
                ],
                1200,
              ),

              // Horse & Equipment Reports
              // _buildReportSection(
              //   context,
              //   'Horse & Equipment Reports',
              //   'Horse performance and equipment analytics',
              //   FontAwesomeIcons.horse,
              //   Colors.amber.shade600,
              //   [
              //     _ReportItem(
              //       'Horse Performance',
              //       'Individual horse statistics & records',
              //       FontAwesomeIcons.horse,
              //     ),
              //     _ReportItem(
              //       'Equipment Usage',
              //       'IR-Timer module usage patterns',
              //       FontAwesomeIcons.cogs,
              //     ),
              //     _ReportItem(
              //       'Horse-Rider Combinations',
              //       'Best performing partnerships',
              //       FontAwesomeIcons.handshake,
              //     ),
              //     _ReportItem(
              //       'Training Progress',
              //       'Horse improvement over time',
              //       FontAwesomeIcons.chartLine,
              //     ),
              //   ],
              //   1400,
              // ),

              const SizedBox(height: 24),

              // Location & Environmental Reports
              _buildReportSection(
                context,
                'Location & Analysis Reports',
                'Location-based performance and environmental factors',
                FontAwesomeIcons.mapMarkerAlt,
                Colors.purple.shade600,
                [
                  _ReportItem(
                    'Location Performance',
                    'Best/worst performing venues',
                    FontAwesomeIcons.map,
                  ),
                  // _ReportItem(
                  //   'Time Analysis',
                  //   'Peak performance hours & patterns',
                  //   FontAwesomeIcons.clock,
                  // ),
                  // _ReportItem(
                  //   'Weather Impact',
                  //   'Performance correlation with conditions',
                  //   FontAwesomeIcons.cloudSun,
                  // ),
                  // _ReportItem(
                  //   'Venue Comparison',
                  //   'Cross-location performance analysis',
                  //   FontAwesomeIcons.exchangeAlt,
                  // ),
                ],
                1600,
              ),

              const SizedBox(height: 24),

              // Advanced Analytics
              // _buildReportSection(
              //   context,
              //   'Advanced Analytics',
              //   'AI-powered insights and predictive analysis',
              //   FontAwesomeIcons.brain,
              //   Colors.red.shade600,
              //   [
              //     _ReportItem(
              //       'Predictive Performance',
              //       'AI-based performance predictions',
              //       FontAwesomeIcons.gem,
              //     ),
              //     _ReportItem(
              //       'Training Recommendations',
              //       'Personalized improvement suggestions',
              //       FontAwesomeIcons.lightbulb,
              //     ),
              //     _ReportItem(
              //       'Risk Analysis',
              //       'Performance consistency & risk factors',
              //       FontAwesomeIcons.shieldAlt,
              //     ),
              //     _ReportItem(
              //       'Goal Tracking',
              //       'Progress toward performance targets',
              //       FontAwesomeIcons.bullseye,
              //     ),
              //   ],
              //   1800,
              // ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatCard(
    BuildContext context,
    String title,
    String value,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      FontAwesomeIcons.arrowUp,
                      size: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: 800 + delay),
        )
        .slideY(begin: 0.3);
  }

  Widget _buildReportSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    List<_ReportItem> reports,
    int delay,
  ) {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...reports.asMap().entries.map((entry) {
                final index = entry.key;
                final report = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < reports.length - 1 ? 12 : 0,
                  ),
                  child: _buildReportItem(context, report, color, index * 100),
                );
              }).toList(),
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

  Widget _buildReportItem(
    BuildContext context,
    _ReportItem report,
    Color color,
    int delay,
  ) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openReport(context, report),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(report.icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 14,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideX(begin: 0.2);
  }

  String _formatTimeFromSeconds(int totalSeconds) {
    if (totalSeconds <= 0) return '0s';

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

  void _openReport(BuildContext context, _ReportItem report) {
    // Navigate to specific report screens based on report type
    if (report.title.contains('Best Performers') ||
        report.title.contains('Personal Records')) {
      Navigator.pushNamed(context, '/performance-report');
    } else {
      // For other reports, show detailed data in a dialog or new screen
      _showReportDetails(context, report);
    }
  }

  void _showReportDetails(BuildContext context, _ReportItem report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(report.icon, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                report.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildReportContent(report)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(_ReportItem report) {
    if (_analyticsData == null) {
      return const Center(child: Text('No data available'));
    }

    switch (report.title) {
      case 'Recent Sessions':
        return _buildRecentSessionsList();
      case 'Mode Statistics':
        return _buildModeStatistics();
      case 'Location Performance':
        return _buildLocationStatistics();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.chartLine,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Detailed ${report.title} report',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'This report will show comprehensive data for ${report.title.toLowerCase()}.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildRecentSessionsList() {
    final recentSessions =
        _analyticsData?['recentSessions'] as List<dynamic>? ?? [];

    if (recentSessions.isEmpty) {
      return const Center(child: Text('No recent sessions found'));
    }

    return ListView.builder(
      itemCount: recentSessions.length,
      itemBuilder: (context, index) {
    final session = recentSessions[index] as Map<String, dynamic>;
    final riderName = session['rider']?['name'] ?? 'Unknown';
    final horseName = session['rider']?['horseName'] ?? 'Unknown';
    final performance =
      session['performance'] as Map<String, dynamic>? ?? const {};
    final formattedTime = _formatPerformanceTime(performance);
        final isSuccess = session['performance']?['isSuccess'] ?? false;
        final mode = session['event']?['mode'] ?? 'Unknown';
        final timestamp =
            DateTime.tryParse(session['timestamp'] ?? '') ?? DateTime.now();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuccess
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
              ),
            ),
            title: Text('$riderName & $horseName'),
            subtitle: Text('$mode • ${_formatDate(timestamp)}'),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                _buildReportTimeLabels(formattedTime),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeStatistics() {
    final modeStats = _analyticsData?['modes'] as Map<String, dynamic>? ?? {};

    if (modeStats.isEmpty) {
      return const Center(child: Text('No mode statistics available'));
    }

    return ListView(
      children: modeStats.entries.map((entry) {
        final mode = entry.key;
        final count = entry.value as int;
        final percentage = _analyticsData?['summary']?['totalSessions'] != null
            ? (count / _analyticsData!['summary']['totalSessions'] * 100)
                  .round()
            : 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: mode == 'Show Jumping'
                  ? Colors.blue.shade100
                  : Colors.green.shade100,
              child: Icon(
                mode == 'Show Jumping'
                    ? FontAwesomeIcons.paperPlane
                    : FontAwesomeIcons.horse,
                color: mode == 'Show Jumping'
                    ? Colors.blue.shade600
                    : Colors.green.shade600,
                size: 16,
              ),
            ),
            title: Text(mode),
            subtitle: Text('$count sessions'),
            trailing: Text(
              '$percentage%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationStatistics() {
    final locationStats =
        _analyticsData?['locations'] as Map<String, dynamic>? ?? {};

    if (locationStats.isEmpty) {
      return const Center(child: Text('No location statistics available'));
    }

    return ListView(
      children: locationStats.entries.map((entry) {
        final location = entry.key;
        final count = entry.value as int;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.shade100,
              child: Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Colors.purple.shade600,
                size: 16,
              ),
            ),
            title: Text(location),
            subtitle: Text('$count sessions'),
            trailing: Icon(
              FontAwesomeIcons.chevronRight,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatPerformanceTime(Map<String, dynamic> performance) {
    final components =
        performance['elapsedComponents'] as Map<String, dynamic>?;

    final int milliseconds =
        (_tryParseInt(performance['elapsedMilliseconds']) ?? 0)
            .clamp(0, 999)
            .toInt();

    final int? hours = _tryParseInt(components?['hours']);
    final int? minutes = _tryParseInt(components?['minutes']);
    final int? seconds = _tryParseInt(components?['seconds']);

    double? totalSecondsDouble;
    final elapsedSecondsValue = performance['elapsedSeconds'];
    if (elapsedSecondsValue is num) {
      totalSecondsDouble = elapsedSecondsValue.toDouble();
    } else if (elapsedSecondsValue is String &&
        elapsedSecondsValue.trim().isNotEmpty) {
      totalSecondsDouble = double.tryParse(elapsedSecondsValue.trim());
    }

    Duration duration;
    if (hours != null || minutes != null || seconds != null) {
      duration = Duration(
        hours: hours ?? 0,
        minutes: minutes ?? 0,
        seconds: seconds ?? 0,
        milliseconds: milliseconds,
      );
    } else if (totalSecondsDouble != null) {
      final totalMillis = (totalSecondsDouble * 1000).round();
      final adjustedMillis =
          totalMillis - (totalMillis % 1000) + milliseconds;
      duration = Duration(milliseconds: adjustedMillis);
    } else {
      final int totalSecondsInt =
          _tryParseInt(performance['elapsedSeconds']) ?? 0;
      duration = Duration(
        seconds: totalSecondsInt,
        milliseconds: milliseconds,
      );
    }

    if (duration.inMilliseconds == 0) {
      final fallback = performance['elapsedTime']?.toString();
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
    }

    return _formatDuration(duration);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final centiseconds = (duration.inMilliseconds.remainder(1000) ~/ 10);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '${centiseconds.toString().padLeft(2, '0')}';
  }

  int? _tryParseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildReportTimeLabels(String timeString) {
    // Check if hours are present (if the time format starts with non-zero hours)
    final parts = timeString.split(':');
    final hasHours = parts.isNotEmpty && parts[0] != '00';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHours) ...[
          _buildReportTimeLabel('HH'),
          _buildReportTimeSeparator(),
        ],
        _buildReportTimeLabel('MM'),
        _buildReportTimeSeparator(),
        _buildReportTimeLabel('SS'),
        _buildReportTimeSeparator(),
        _buildReportTimeLabel('MS'),
      ],
    );
  }

  Widget _buildReportTimeLabel(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReportTimeSeparator() {
    return const SizedBox(width: 8);
  }
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;

  _ReportItem(this.title, this.description, this.icon);
}
