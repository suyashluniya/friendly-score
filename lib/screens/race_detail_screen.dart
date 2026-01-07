import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RaceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> raceData;

  const RaceDetailScreen({super.key, required this.raceData});

  @override
  Widget build(BuildContext context) {
    final rider = raceData['rider'] as Map<String, dynamic>? ?? {};
    final performance = raceData['performance'] as Map<String, dynamic>? ?? {};
    final event = raceData['event'] as Map<String, dynamic>? ?? {};
    final location = event['location'] as Map<String, dynamic>? ?? {};
    final hardware = raceData['hardware'] as Map<String, dynamic>? ?? {};
    
    final riderName = rider['name']?.toString() ?? 'Unknown Rider';
    final riderNumber = rider['number']?.toString() ?? '';
    final photoPath = rider['photoPath']?.toString() ?? '';
    final elapsedTime = performance['elapsedTime']?.toString() ?? '00:00:00:00';
    final targetTime = performance['targetTime']?.toString() ?? '';
    final isSuccess = performance['isSuccess'] ?? false;
    final isStopped = performance['isStopped'] ?? false;
    final status = performance['status']?.toString() ?? 'Unknown';
    final mode = event['mode']?.toString() ?? 'Unknown Mode';
    final locationName = location['name']?.toString() ?? 'Unknown Location';
    final locationAddress = location['address']?.toString() ?? '';
    final timestamp = raceData['timestamp']?.toString() ?? '';
    final deviceUsed = hardware['deviceUsed']?.toString() ?? 'Unknown Device';
    
    // Determine status details
    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    
    if (isStopped) {
      statusColor = Colors.orange.shade600;
      statusIcon = FontAwesomeIcons.stop;
      statusLabel = 'STOPPED';
    } else if (isSuccess) {
      statusColor = Colors.green.shade600;
      statusIcon = FontAwesomeIcons.flagCheckered;
      statusLabel = 'FINISHED';
    } else {
      statusColor = Colors.red.shade600;
      statusIcon = FontAwesomeIcons.xmark;
      statusLabel = 'DISQUALIFIED';
    }
    
    // Format timestamp
    String formattedDateTime = '';
    if (timestamp.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(timestamp);
        formattedDateTime = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        formattedDateTime = 'Unknown date';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'Race Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [statusColor, statusColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    statusIcon,
                    size: 48,
                    color: Colors.white,
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    statusLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    elapsedTime,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HH:MM:SS:MS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
            
            const SizedBox(height: 24),
            
            // Rider Information Card
            _buildInfoCard(
              context,
              title: 'Rider Information',
              icon: FontAwesomeIcons.user,
              iconColor: Colors.blue.shade600,
              children: [
                _buildInfoRow(
                  context,
                  'Name',
                  riderName,
                  FontAwesomeIcons.user,
                ),
                if (riderNumber.isNotEmpty)
                  _buildInfoRow(
                    context,
                    'Number',
                    '#$riderNumber',
                    FontAwesomeIcons.hashtag,
                  ),
                if (photoPath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: File(photoPath).existsSync()
                        ? Image.file(
                            File(photoPath),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.image,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Photo not available',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2),
            
            const SizedBox(height: 16),
            
            // Performance Details Card
            _buildInfoCard(
              context,
              title: 'Performance Details',
              icon: FontAwesomeIcons.stopwatch,
              iconColor: Colors.purple.shade600,
              children: [
                _buildInfoRow(
                  context,
                  'Elapsed Time',
                  elapsedTime,
                  FontAwesomeIcons.clock,
                ),
                if (targetTime.isNotEmpty)
                  _buildInfoRow(
                    context,
                    'Target Time',
                    targetTime,
                    FontAwesomeIcons.bullseye,
                  ),
                _buildInfoRow(
                  context,
                  'Status',
                  status,
                  statusIcon,
                  valueColor: statusColor,
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: 0.2),
            
            const SizedBox(height: 16),
            
            // Event Information Card
            _buildInfoCard(
              context,
              title: 'Event Information',
              icon: FontAwesomeIcons.calendar,
              iconColor: Colors.green.shade600,
              children: [
                _buildInfoRow(
                  context,
                  'Mode',
                  mode,
                  FontAwesomeIcons.gamepad,
                ),
                _buildInfoRow(
                  context,
                  'Date & Time',
                  formattedDateTime,
                  FontAwesomeIcons.calendarDay,
                ),
                _buildInfoRow(
                  context,
                  'Location',
                  locationName,
                  FontAwesomeIcons.mapMarkerAlt,
                ),
                if (locationAddress.isNotEmpty)
                  _buildInfoRow(
                    context,
                    'Address',
                    locationAddress,
                    FontAwesomeIcons.locationDot,
                  ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.2),
            
            const SizedBox(height: 16),
            
            // Hardware Information Card
            _buildInfoCard(
              context,
              title: 'Hardware Information',
              icon: FontAwesomeIcons.microchip,
              iconColor: Colors.orange.shade600,
              children: [
                _buildInfoRow(
                  context,
                  'Device',
                  deviceUsed,
                  FontAwesomeIcons.bluetooth,
                ),
                _buildInfoRow(
                  context,
                  'Connection',
                  'Successful',
                  FontAwesomeIcons.checkCircle,
                  valueColor: Colors.green.shade600,
                ),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideX(begin: 0.2),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor ?? const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
