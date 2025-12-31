import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'top_score_screen.dart';
import 'normal_jumping_screen.dart';
import 'rider_details_screen.dart';
import '../services/mode_service.dart';

class JumpingScreen extends StatelessWidget {
  const JumpingScreen({super.key});
  static const routeName = '/jumping';

  @override
  Widget build(BuildContext context) {
    // Get the current mode to display the correct title
    final modeService = ModeService();
    final currentMode = modeService.getMode();

    String appBarTitle;
    String titleText;
    String subtitleText;

    if (currentMode == ModeService.mountedSports) {
      appBarTitle = 'Mounted Sports';
      titleText = 'Choose Race Type';
      subtitleText = 'Select the race type for your event';
    } else {
      appBarTitle = 'Show Jumping';
      titleText = 'Choose Your Mode';
      subtitleText = 'Select the jumping mode for your event';
    }

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
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
                    titleText,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitleText,
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
                    child: currentMode == ModeService.mountedSports
                        ? _buildMountedSportsButtons(context)
                        : _buildShowJumpingButtons(context),
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

  Widget _buildShowJumpingButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: _JumpOptionButton(
            label: 'Top Score',
            description: 'Competitive mode with time limits',
            icon: FontAwesomeIcons.trophy,
            color: const Color(0xFFF59E0B),
            onTap: () => Navigator.pushNamed(
              context,
              TopScoreJumpingScreen.routeName,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Flexible(
          child: _JumpOptionButton(
            label: 'Normal',
            description: 'Practice mode for training sessions',
            icon: FontAwesomeIcons.personRunning,
            color: const Color(0xFF0066FF),
            onTap: () => Navigator.pushNamed(
              context,
              NormalJumpingScreen.routeName,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMountedSportsButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          child: _JumpOptionButton(
            label: 'Start → Finish',
            description: 'Simple race from start to finish',
            icon: FontAwesomeIcons.flagCheckered,
            color: const Color(0xFF10B981),
            onTap: () => Navigator.pushNamed(
              context,
              RiderDetailsScreen.routeName,
              arguments: {
                'selectedHours': 0,
                'selectedMinutes': 0,
                'selectedSeconds': 0,
                'maxHours': 0,
                'maxMinutes': 0,
                'maxSeconds': 0,
                'raceType': 'startFinish',
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        Flexible(
          child: _JumpOptionButton(
            label: 'Start → Verify → Finish',
            description: 'Race with verification checkpoint',
            icon: FontAwesomeIcons.listCheck,
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.pushNamed(
              context,
              RiderDetailsScreen.routeName,
              arguments: {
                'selectedHours': 0,
                'selectedMinutes': 0,
                'selectedSeconds': 0,
                'maxHours': 0,
                'maxMinutes': 0,
                'maxSeconds': 0,
                'raceType': 'startVerifyFinish',
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _JumpOptionButton extends StatelessWidget {
  const _JumpOptionButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C757D),
                      ),
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
    );
  }
}
