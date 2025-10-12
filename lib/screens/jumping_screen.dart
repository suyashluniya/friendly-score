import 'package:flutter/material.dart';
import 'top_score_screen.dart';
import 'normal_jumping_screen.dart';

class JumpingScreen extends StatelessWidget {
  const JumpingScreen({super.key});
  static const routeName = '/jumping';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: const Text('Jumping Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Text(
                'Show Jumping'.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              const SizedBox(height: 20),
              Flexible(
                flex: 1,
                child: _JumpOptionButton(
                  label: 'Top Score'.toUpperCase(),
                  icon: Icons.emoji_events,
                  onTap: () => Navigator.pushNamed(
                    context,
                    TopScoreJumpingScreen.routeName,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                flex: 1,
                child: _JumpOptionButton(
                  label: 'Normal'.toUpperCase(),
                  icon: Icons.directions_run,
                  onTap: () => Navigator.pushNamed(
                    context,
                    NormalJumpingScreen.routeName,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _JumpOptionButton extends StatelessWidget {
  const _JumpOptionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 140,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          elevation: 2,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: Colors.black),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
