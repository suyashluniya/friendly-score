import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'rider_details_screen.dart';

/// Custom scroll physics for ultra-smooth wheel scrolling
class NormalSmoothWheelScrollPhysics extends FixedExtentScrollPhysics {
  const NormalSmoothWheelScrollPhysics({super.parent});

  @override
  NormalSmoothWheelScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NormalSmoothWheelScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.4,
        stiffness: 45.0,
        damping: 0.8,
      );
}

class NormalJumpingScreen extends StatefulWidget {
  const NormalJumpingScreen({super.key});
  static const routeName = '/jumping/normal';

  @override
  State<NormalJumpingScreen> createState() => _NormalJumpingScreenState();
}

class _NormalJumpingScreenState extends State<NormalJumpingScreen> {
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;
  late FixedExtentScrollController _secondsController;

  @override
  void initState() {
    super.initState();
    _hoursController = FixedExtentScrollController(initialItem: 0);
    _minutesController = FixedExtentScrollController(initialItem: 0);
    _secondsController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  String _formatTimeDigital(int hours, int minutes, int seconds) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _hasTimeSelected =>
      _selectedHours > 0 || _selectedMinutes > 0 || _selectedSeconds > 0;

  Future<void> _handleSetTimer() async {
    if (!_hasTimeSelected) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Please set a time greater than 0 seconds',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    final confirmed = await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (dialogContext) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Confirm Time Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildConfirmRow(
                            'Maximum Time',
                            _formatTimeDigital(
                              _selectedHours,
                              _selectedMinutes,
                              _selectedSeconds,
                            ),
                            AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Normal mode: Time set is the maximum allowed',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) return;

    Navigator.of(context).pushNamed(
      RiderDetailsScreen.routeName,
      arguments: {
        'selectedHours': _selectedHours,
        'selectedMinutes': _selectedMinutes,
        'selectedSeconds': _selectedSeconds,
        'maxHours': _selectedHours,
        'maxMinutes': _selectedMinutes,
        'maxSeconds': _selectedSeconds,
      },
    );
  }

  Widget _buildConfirmRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const cardShadow = [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 18,
        offset: Offset(0, 8),
      )
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
                        boxShadow: cardShadow,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                  const Spacer(),
                  Text(
                    'Normal Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Header
                    Text(
                      'Set Maximum Time',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                    const SizedBox(height: 8),

                    Text(
                      'Scroll to set hours, minutes, and seconds',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                    const SizedBox(height: 32),

                    // Modern Timer Picker Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: cardShadow,
                      ),
                      child: Column(
                        children: [
                          // Picker section
                          SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                // Hours
                                Expanded(
                                  child: _buildWheelPicker(
                                    controller: _hoursController,
                                    maxValue: 23,
                                    label: 'Hours',
                                    onChanged: (value) {
                                      setState(() => _selectedHours = value);
                                    },
                                  ),
                                ),
                                // Colon separator
                                _buildColon(),
                                // Minutes
                                Expanded(
                                  child: _buildWheelPicker(
                                    controller: _minutesController,
                                    maxValue: 59,
                                    label: 'Minutes',
                                    onChanged: (value) {
                                      setState(() => _selectedMinutes = value);
                                    },
                                  ),
                                ),
                                // Colon separator
                                _buildColon(),
                                // Seconds
                                Expanded(
                                  child: _buildWheelPicker(
                                    controller: _secondsController,
                                    maxValue: 59,
                                    label: 'Seconds',
                                    onChanged: (value) {
                                      setState(() => _selectedSeconds = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Divider
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: AppColors.border,
                          ),

                          // Selected time display
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withOpacity(0.15),
                                        AppColors.primary.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.timer_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Maximum Time',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatTimeDigital(
                                          _selectedHours,
                                          _selectedMinutes,
                                          _selectedSeconds,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.primary,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_hasTimeSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.success,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SET',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.success,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                          begin: 0.1,
                        ),

                    const SizedBox(height: 16),

                    // Info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: cardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'In Normal mode, the time you set is the maximum allowed time for the race.',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(
                          begin: 0.1,
                        ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _hasTimeSelected ? AppColors.primary : AppColors.border,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _hasTimeSelected
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _hasTimeSelected
                              ? Colors.white
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(
                  begin: 0.2,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildColon() {
    return SizedBox(
      width: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ':',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary.withOpacity(0.4),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int maxValue,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Wheel
        Expanded(
          child: Stack(
            children: [
              // Selection highlight
              Center(
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // The wheel
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 50,
                diameterRatio: 1.5,
                perspective: 0.004,
                physics: const NormalSmoothWheelScrollPhysics(),
                onSelectedItemChanged: (index) {
                  HapticFeedback.selectionClick();
                  onChanged(index % (maxValue + 1));
                },
                childDelegate: ListWheelChildLoopingListDelegate(
                  children: List.generate(maxValue + 1, (index) {
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Top fade
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 50,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom fade
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 50,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
