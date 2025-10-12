import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// First screen of the app allowing user to pick a sport mode.
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Modes'.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Flexible(
                flex: 1,
                child: _ModeButton(
                  label: 'Show Jumping'.toUpperCase(),
                  icon: Icons.sports_gymnastics,
                  heroTag: 'mode-jumping',
                  route: '/jumping',
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),
              ),
              const SizedBox(height: 20),
              Flexible(
                flex: 1,
                child: _ModeButton(
                  label: 'Mounted Sports'.toUpperCase(),
                  icon: Icons.terrain,
                  heroTag: 'mode-mountain',
                  route: '/mountain',
                ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.3, end: 0),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.heroTag,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String heroTag;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 140,
          maxHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.pushNamed(context, route),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 56,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
