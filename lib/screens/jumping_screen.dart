import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'top_score_screen.dart';
import 'normal_jumping_screen.dart';
import '../services/mode_service.dart';

/// Modern jumping mode selection screen
class JumpingScreen extends StatelessWidget {
  const JumpingScreen({super.key});
  static const routeName = '/jumping';

  @override
  Widget build(BuildContext context) {
    final modeService = ModeService();
    final currentMode = modeService.getMode();

    String screenTitle;
    String screenSubtitle;
    IconData headerIcon;
    Color headerColor;

    if (currentMode == ModeService.mountedSports) {
      screenTitle = 'Mounted Sports';
      screenSubtitle = 'Equestrian timing modes';
      headerIcon = FontAwesomeIcons.horseHead;
      headerColor = const Color(0xFF10B981);
    } else {
      screenTitle = 'Show Jumping';
      screenSubtitle = 'Competition timing modes';
      headerIcon = FontAwesomeIcons.stopwatch;
      headerColor = const Color(0xFF3B82F6);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppShadows.card,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.2),
                    const Spacer(),
                  ],
                ),
              ),

              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Badge
                    Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                headerColor,
                                headerColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: headerColor.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: FaIcon(
                              headerIcon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      screenTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(
                          begin: 0.2,
                        ),

                    const SizedBox(height: 8),

                    Text(
                      screenSubtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Section Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Select Timing Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              ),

              const SizedBox(height: 16),

              // Mode Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Top Score Card
                    _ModernJumpCard(
                      title: 'Top Score',
                      description:
                          'Competition mode with time limits. Maximum time is doubled from selected time.',
                      icon: FontAwesomeIcons.trophy,
                      color: const Color(0xFFF59E0B),
                      features: ['Time Limit', 'Fault Tracking', 'Competition'],
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                          context,
                          TopScoreJumpingScreen.routeName,
                        );
                      },
                      delay: 250,
                    ),

                    const SizedBox(height: 20),

                    // Normal Mode Card
                    _ModernJumpCard(
                      title: 'Normal',
                      description:
                          'Practice mode for training. Maximum time equals selected time.',
                      icon: FontAwesomeIcons.personRunning,
                      color: AppColors.primary,
                      features: ['Practice', 'Training', 'Flexible'],
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                          context,
                          NormalJumpingScreen.routeName,
                        );
                      },
                      delay: 350,
                    ),
                  ],
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

class _ModernJumpCard extends StatelessWidget {
  const _ModernJumpCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.onTap,
    required this.delay,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.card,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              splashColor: color.withOpacity(0.1),
              highlightColor: color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: FaIcon(
                              icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Arrow
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: color,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Feature Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: features.map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            feature,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1);
  }
}
