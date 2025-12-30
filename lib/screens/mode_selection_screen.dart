import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/mode_service.dart';

/// First screen of the app allowing user to pick a sport mode.
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Title section
              Column(
                children: [
                  Text(
                    'Select Mode',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose your sport to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF6C757D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: _ModeButton(
                            label: 'Mounted Sports',
                            description: 'Equestrian and mounted events',
                            icon: FontAwesomeIcons.hourglassHalf,
                            heroTag: 'mode-mountain',
                            route: '/jumping',
                            color: const Color(0xFF10B981),
                            mode: ModeService.mountedSports,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Flexible(
                          child: _ModeButton(
                            label: 'Show Jumping',
                            description: 'Time trials and competition modes',
                            icon: FontAwesomeIcons.paperPlane,
                            heroTag: 'mode-jumping',
                            route: '/jumping',
                            color: const Color(0xFF0066FF),
                            mode: ModeService.showJumping,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Flexible(
                          child: _ModeButton(
                            label: 'Reports & Analytics',
                            description:
                                'Performance insights and data analysis',
                            icon: FontAwesomeIcons.chartLine,
                            heroTag: 'mode-reporting',
                            route: '/reporting',
                            color: const Color(0xFF8B5CF6),
                            mode: 'reporting',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
    required this.description,
    required this.icon,
    required this.heroTag,
    required this.route,
    required this.color,
    required this.mode,
  });

  final String label;
  final String description;
  final IconData icon;
  final String heroTag;
  final String route;
  final Color color;
  final String mode;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              // Set the selected mode
              ModeService().setMode(mode);
              Navigator.pushNamed(context, route);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: FaIcon(icon, size: 36, color: color),
                  ),
                  const SizedBox(width: 24),
                  // Text content
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF6C757D)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Arrow icon
                  Icon(Icons.arrow_forward_ios, size: 20, color: color),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
