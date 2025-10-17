import 'package:flutter/material.dart';
import 'time_confirmation_screen.dart';

/// Custom scroll physics for ultra-smooth wheel scrolling
class FluidWheelScrollPhysics extends FixedExtentScrollPhysics {
  const FluidWheelScrollPhysics({super.parent});

  @override
  FluidWheelScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FluidWheelScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 0.5, // Much lighter mass for more responsive feel
    stiffness: 50.0, // Lower stiffness for smoother, less abrupt stops
    damping: 0.6, // Lower damping for longer momentum scrolling
  );
}

class TopScoreJumpingScreen extends StatefulWidget {
  const TopScoreJumpingScreen({super.key});
  static const routeName = '/jumping/top-score';

  @override
  State<TopScoreJumpingScreen> createState() => _TopScoreJumpingScreenState();
}

class _TopScoreJumpingScreenState extends State<TopScoreJumpingScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  void _handleSetTimer() {
    // Validate that time is not 0:0:0
    if (_selectedHours == 0 && _selectedMinutes == 0 && _selectedSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please set a time greater than 0 seconds'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Navigate to confirmation screen with selected time
    Navigator.of(context).pushNamed(
      TimeConfirmationScreen.routeName,
      arguments: {
        'hours': _selectedHours,
        'minutes': _selectedMinutes,
        'seconds': _selectedSeconds,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Score Jumping'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter Time Allowed',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              // Scrollable timer pickers
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _ScrollableTimePicker(
                        maxValue: 23,
                        label: 'Hours',
                        onSelectedItemChanged: (value) {
                          setState(() {
                            _selectedHours = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: Colors.black54,
                              fontSize: 32,
                            ),
                      ),
                    ),
                    Expanded(
                      child: _ScrollableTimePicker(
                        maxValue: 59,
                        label: 'Min',
                        onSelectedItemChanged: (value) {
                          setState(() {
                            _selectedMinutes = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        ':',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: Colors.black54,
                              fontSize: 32,
                            ),
                      ),
                    ),
                    Expanded(
                      child: _ScrollableTimePicker(
                        maxValue: 59,
                        label: 'Sec',
                        onSelectedItemChanged: (value) {
                          setState(() {
                            _selectedSeconds = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Set button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSetTimer,
                  child: const Text('Set Time'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollableTimePicker extends StatefulWidget {
  const _ScrollableTimePicker({
    required this.maxValue,
    required this.label,
    required this.onSelectedItemChanged,
  });

  final int maxValue;
  final String label;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  State<_ScrollableTimePicker> createState() => _ScrollableTimePickerState();
}

class _ScrollableTimePickerState extends State<_ScrollableTimePicker> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    widget.onSelectedItemChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Main scroll wheel with bidirectional infinite scroll
              ListWheelScrollView.useDelegate(
                controller: _scrollController,
                itemExtent: 60,
                diameterRatio: 2.0,
                perspective: 0.004,
                physics: const FluidWheelScrollPhysics(),
                onSelectedItemChanged: _onSelectedItemChanged,
                childDelegate: ListWheelChildLoopingListDelegate(
                  children: List.generate(widget.maxValue + 1, (index) {
                    return Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontSize: 32,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ),

              // iPhone-style blur/fade effects (pointer events disabled)
              // Top gradient fade
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 80,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom gradient fade
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Center selection highlight (subtle)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: const Color(0xFF6C757D),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
