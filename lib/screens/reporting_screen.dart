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
  List<Map<String, dynamic>> _filteredRaces = [];
  bool _isLoading = true;
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Filter and sort states
  String _sortOrder = 'newest'; // newest, oldest, timeAsc, timeDesc
  Set<String> _selectedStatuses = {}; // finished, stopped, disqualified
  Set<String> _selectedModes = {}; // mode names
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadAllRaces();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _applyFilters();
      }
    } catch (e) {
      print('Error loading race data: $e');
      if (mounted) {
        setState(() {
          _allRaces = [];
          _filteredRaces = [];
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allRaces);

    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((race) {
        final rider = race['rider'] as Map<String, dynamic>? ?? {};
        final riderName = rider['name']?.toString().toLowerCase() ?? '';
        final riderNumber = rider['number']?.toString().toLowerCase() ?? '';
        return riderName.contains(searchQuery) || riderNumber.contains(searchQuery);
      }).toList();
    }

    // Apply status filter
    if (_selectedStatuses.isNotEmpty) {
      filtered = filtered.where((race) {
        final performance = race['performance'] as Map<String, dynamic>? ?? {};
        final isSuccess = performance['isSuccess'] ?? false;
        final isStopped = performance['isStopped'] ?? false;
        
        String status;
        if (isStopped) {
          status = 'stopped';
        } else if (isSuccess) {
          status = 'finished';
        } else {
          status = 'disqualified';
        }
        return _selectedStatuses.contains(status);
      }).toList();
    }

    // Apply mode filter
    if (_selectedModes.isNotEmpty) {
      filtered = filtered.where((race) {
        final event = race['event'] as Map<String, dynamic>? ?? {};
        final mode = event['mode']?.toString() ?? '';
        return _selectedModes.contains(mode);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      if (_sortOrder == 'newest' || _sortOrder == 'oldest') {
        final aTimestamp = a['timestamp']?.toString() ?? '';
        final bTimestamp = b['timestamp']?.toString() ?? '';
        return _sortOrder == 'newest' 
          ? bTimestamp.compareTo(aTimestamp)
          : aTimestamp.compareTo(bTimestamp);
      } else if (_sortOrder == 'timeAsc' || _sortOrder == 'timeDesc') {
        final aPerf = a['performance'] as Map<String, dynamic>? ?? {};
        final bPerf = b['performance'] as Map<String, dynamic>? ?? {};
        final aTime = aPerf['elapsedTime']?.toString() ?? '99:99:99:999';
        final bTime = bPerf['elapsedTime']?.toString() ?? '99:99:99:999';
        return _sortOrder == 'timeAsc'
          ? aTime.compareTo(bTime)
          : bTime.compareTo(aTime);
      }
      return 0;
    });

    setState(() {
      _filteredRaces = filtered;
    });
  }

  Set<String> _getAvailableModes() {
    return _allRaces.map((race) {
      final event = race['event'] as Map<String, dynamic>? ?? {};
      return event['mode']?.toString() ?? '';
    }).where((mode) => mode.isNotEmpty).toSet();
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
        actions: [
          // Search button with expand animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSearchExpanded ? 200 : 48,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: _isSearchExpanded ? 2 : 0,
              child: _isSearchExpanded
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass, size: 14, color: Colors.grey.shade600),
                        suffixIcon: IconButton(
                          icon: Icon(FontAwesomeIcons.xmark, size: 14, color: Colors.grey.shade600),
                          onPressed: () {
                            setState(() {
                              _isSearchExpanded = false;
                              _searchController.clear();
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    )
                  : IconButton(
                      icon: Icon(FontAwesomeIcons.magnifyingGlass, size: 18, color: Colors.grey.shade700),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = true;
                        });
                      },
                    ),
            ),
          ),
          // Filter button
          IconButton(
            icon: Stack(
              children: [
                Icon(FontAwesomeIcons.filter, size: 18, color: Colors.grey.shade700),
                if (_selectedStatuses.isNotEmpty || _selectedModes.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          // Sort button
          PopupMenuButton<String>(
            icon: Icon(FontAwesomeIcons.arrowDownWideShort, size: 18, color: Colors.grey.shade700),
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              setState(() {
                _sortOrder = value;
              });
              _applyFilters();
            },
            itemBuilder: (context) => [
              _buildSortMenuItem('Newest First', 'newest', FontAwesomeIcons.arrowDown),
              _buildSortMenuItem('Oldest First', 'oldest', FontAwesomeIcons.arrowUp),
              _buildSortMenuItem('Fastest Time', 'timeAsc', FontAwesomeIcons.gaugeHigh),
              _buildSortMenuItem('Slowest Time', 'timeDesc', FontAwesomeIcons.clockRotateLeft),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showFilters ? null : 0,
            child: _showFilters ? _buildFilterPanel() : const SizedBox.shrink(),
          ),
          
          // Main content
          Expanded(
            child: _isLoading
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
                : _filteredRaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedModes.isNotEmpty
                              ? FontAwesomeIcons.magnifyingGlass
                              : FontAwesomeIcons.inbox,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedModes.isNotEmpty
                              ? 'No matching records found'
                              : 'No race records found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty || _selectedStatuses.isNotEmpty || _selectedModes.isNotEmpty
                              ? 'Try adjusting your filters'
                              : 'Start racing to see records here',
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
                      itemCount: _filteredRaces.length,
                      itemBuilder: (context, index) {
                        final race = _filteredRaces[index];
                        return _buildRaceCard(context, race, index);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String label, String value, IconData icon) {
    final isSelected = _sortOrder == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            Icon(FontAwesomeIcons.check, size: 14, color: Colors.blue.shade600),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    final availableModes = _getAvailableModes();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.filter, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              if (_selectedStatuses.isNotEmpty || _selectedModes.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedStatuses.clear();
                      _selectedModes.clear();
                    });
                    _applyFilters();
                  },
                  icon: Icon(FontAwesomeIcons.xmark, size: 12, color: Colors.blue.shade600),
                  label: Text(
                    'Clear All',
                    style: TextStyle(color: Colors.blue.shade600, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Status filters
          Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Finished', 'finished', Colors.green, FontAwesomeIcons.flagCheckered),
              _buildFilterChip('Stopped', 'stopped', Colors.orange, FontAwesomeIcons.stop),
              _buildFilterChip('Disqualified', 'disqualified', Colors.red, FontAwesomeIcons.xmark),
            ],
          ),
          
          if (availableModes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Mode',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableModes.map((mode) {
                return _buildModeFilterChip(mode);
              }).toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, duration: 300.ms);
  }

  Widget _buildFilterChip(String label, String value, Color color, IconData icon) {
    final isSelected = _selectedStatuses.contains(value);
    final materialColor = color is MaterialColor ? color : Colors.blue;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isSelected ? Colors.white : materialColor.shade700),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedStatuses.add(value);
          } else {
            _selectedStatuses.remove(value);
          }
        });
        _applyFilters();
      },
      backgroundColor: materialColor.shade50,
      selectedColor: materialColor.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : materialColor.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? materialColor.shade600 : materialColor.shade200,
          width: 1.5,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildModeFilterChip(String mode) {
    final isSelected = _selectedModes.contains(mode);
    return FilterChip(
      label: Text(mode),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedModes.add(mode);
          } else {
            _selectedModes.remove(mode);
          }
        });
        _applyFilters();
      },
      backgroundColor: Colors.blue.shade50,
      selectedColor: Colors.blue.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.blue.shade700,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue.shade600 : Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      showCheckmark: false,
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
