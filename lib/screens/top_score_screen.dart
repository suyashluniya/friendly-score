import 'package:flutter/material.dart';

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
    // Handle the timer set action here
    print('Timer set: $_selectedHours:$_selectedMinutes:$_selectedSeconds');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Top Score Jumping'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter time allowed'.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 40),
              // Scrollable timer pickers
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                    Text(
                      ':',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                    Text(
                      ':',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
              const SizedBox(height: 40),
              // Set button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleSetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Set',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScrollableTimePicker extends StatelessWidget {
  const _ScrollableTimePicker({
    required this.maxValue,
    required this.label,
    required this.onSelectedItemChanged,
  });

  final int maxValue;
  final String label;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            diameterRatio: 1.5,
            perspective: 0.003,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelectedItemChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                );
              },
              childCount: maxValue + 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
