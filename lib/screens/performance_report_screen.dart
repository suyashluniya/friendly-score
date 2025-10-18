import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
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

              _buildPerformerCard(
                rank: 1,
                name: 'Sarah Johnson',
                horse: 'Thunder Bolt',
                bestTime: '1:23.45',
                mode: 'Show Jumping',
                improvement: '+12%',
                avatar: 'SJ',
                color: Colors.amber.shade600,
                delay: 0,
              ),

              const SizedBox(height: 12),

              _buildPerformerCard(
                rank: 2,
                name: 'Michael Rodriguez',
                horse: 'Storm Runner',
                bestTime: '1:28.92',
                mode: 'Mountain Sport',
                improvement: '+8%',
                avatar: 'MR',
                color: Colors.grey.shade400,
                delay: 200,
              ),

              const SizedBox(height: 12),

              _buildPerformerCard(
                rank: 3,
                name: 'Emma Chen',
                horse: 'Lightning Strike',
                bestTime: '1:31.17',
                mode: 'Show Jumping',
                improvement: '+15%',
                avatar: 'EC',
                color: Colors.orange.shade600,
                delay: 400,
              ),

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
                      '1:45.2s',
                      '↓ 5.2s from last month',
                      FontAwesomeIcons.clock,
                      Colors.green.shade600,
                      600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Success Rate',
                      '87.3%',
                      '↑ 12% from last month',
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
                      'Best Category',
                      'Show Jumping',
                      '73% of top times',
                      FontAwesomeIcons.trophy,
                      Colors.amber.shade600,
                      1000,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Active Horses',
                      '18',
                      '↑ 3 new this month',
                      FontAwesomeIcons.horse,
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

              ...List.generate(5, (index) {
                final sessions = [
                  {
                    'date': '2025-10-17',
                    'rider': 'Alex Thompson',
                    'time': '1:34.12',
                    'mode': 'Show Jumping',
                    'result': 'Success',
                  },
                  {
                    'date': '2025-10-17',
                    'rider': 'Maria Santos',
                    'time': '1:41.89',
                    'mode': 'Mountain Sport',
                    'result': 'Success',
                  },
                  {
                    'date': '2025-10-16',
                    'rider': 'James Wilson',
                    'time': '1:52.34',
                    'mode': 'Show Jumping',
                    'result': 'Time Exceeded',
                  },
                  {
                    'date': '2025-10-16',
                    'rider': 'Lisa Park',
                    'time': '1:29.67',
                    'mode': 'Mountain Sport',
                    'result': 'Success',
                  },
                  {
                    'date': '2025-10-15',
                    'rider': 'David Kim',
                    'time': '1:38.91',
                    'mode': 'Show Jumping',
                    'result': 'Success',
                  },
                ];

                return Padding(
                  padding: EdgeInsets.only(bottom: index < 4 ? 12 : 0),
                  child: _buildSessionCard(sessions[index], index * 100 + 1400),
                );
              }),

              const SizedBox(height: 32),

              // Export/Action Buttons
              Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _exportReport(),
                          icon: const Icon(FontAwesomeIcons.download),
                          label: const Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareReport(),
                          icon: const Icon(FontAwesomeIcons.share),
                          label: const Text('Share Report'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade600,
                            side: BorderSide(color: Colors.blue.shade600),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 2000.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildSessionCard(Map<String, String> session, int delay) {
    final isSuccess = session['result'] == 'Success';

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
                          session['rider']!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                        ),
                        Text(
                          session['date']!,
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
                          session['mode']!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          session['time']!,
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
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedTimeframe,
              decoration: const InputDecoration(labelText: 'Timeframe'),
              items: [
                'Last 7 Days',
                'Last 30 Days',
                'Last 3 Months',
                'All Time',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedTimeframe = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMode,
              decoration: const InputDecoration(labelText: 'Mode'),
              items: [
                'All Modes',
                'Show Jumping',
                'Mountain Sport',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => setState(() => selectedMode = value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report exported as PDF')));
  }

  void _shareReport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report shared successfully')));
  }
}
