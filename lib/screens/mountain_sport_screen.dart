import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MountainSportScreen extends StatelessWidget {
  const MountainSportScreen({super.key});
  static const routeName = '/mountain';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mounted Sports'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.terrain,
                    size: 64,
                    color: Color(0xFF0066FF),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 40),
                Text(
                  'Mounted Sports Mode',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
