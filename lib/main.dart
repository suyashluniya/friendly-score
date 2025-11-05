import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/pin_login_screen.dart';
import 'screens/event_location_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/jumping_screen.dart';
import 'screens/top_score_screen.dart';
import 'screens/normal_jumping_screen.dart';
import 'screens/mountain_sport_screen.dart';
import 'screens/time_confirmation_screen.dart';
import 'screens/rider_details_screen.dart';
import 'screens/timer_start_screen.dart';
import 'screens/bluetooth_ready_screen.dart';
import 'screens/bluetooth_failed_screen.dart';
import 'screens/active_race_screen.dart';
import 'screens/race_results_screen.dart';
import 'screens/reporting_screen.dart';
import 'screens/performance_report_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for modern look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

// Modern Design System Colors
class AppColors {
  // Primary colors - Modern blue palette
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF3385FF);

  // Neutral colors - Clean grays
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1D1F);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFF9FA6AD);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
}

// Consistent spacing values
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Consistent border radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timing App',
      theme: ThemeData(
        // Color Scheme
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.textSecondary,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          error: AppColors.error,
          onPrimary: Colors.white,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
        ),

        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,

        // Typography
        textTheme: GoogleFonts.interTextTheme().copyWith(
          // Display styles
          displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            color: AppColors.textPrimary,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),

          // Headline styles
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),

          // Title styles
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
            color: AppColors.textPrimary,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),

          // Body styles
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            color: AppColors.textSecondary,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            color: AppColors.textTertiary,
          ),

          // Label styles
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.textTertiary,
          ),
        ),

        // AppBar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            minimumSize: const Size(0, 52),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),
      ),
      initialRoute: PinLoginScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == TimeConfirmationScreen.routeName) {
          final args = settings.arguments as Map<String, int>;
          return MaterialPageRoute(
            builder: (_) => TimeConfirmationScreen(
              selectedHours: args['hours']!,
              selectedMinutes: args['minutes']!,
              selectedSeconds: args['seconds']!,
            ),
          );
        } else if (settings.name == RiderDetailsScreen.routeName) {
          final args = settings.arguments as Map<String, int>;
          return MaterialPageRoute(
            builder: (_) => RiderDetailsScreen(
              selectedHours: args['selectedHours']!,
              selectedMinutes: args['selectedMinutes']!,
              selectedSeconds: args['selectedSeconds']!,
              maxHours: args['maxHours']!,
              maxMinutes: args['maxMinutes']!,
              maxSeconds: args['maxSeconds']!,
            ),
          );
        } else if (settings.name == TimerStartScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => TimerStartScreen(
              selectedHours: args['selectedHours'] as int,
              selectedMinutes: args['selectedMinutes'] as int,
              selectedSeconds: args['selectedSeconds'] as int,
              maxHours: args['maxHours'] as int,
              maxMinutes: args['maxMinutes'] as int,
              maxSeconds: args['maxSeconds'] as int,
              riderName: args['riderName'] as String,
              eventName: args['eventName'] as String,
              horseName: args['horseName'] as String,
              horseId: args['horseId'] as String,
              additionalDetails: args['additionalDetails'] as String,
            ),
          );
        } else if (settings.name == BluetoothReadyScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BluetoothReadyScreen(
              selectedHours: args['selectedHours'] as int,
              selectedMinutes: args['selectedMinutes'] as int,
              selectedSeconds: args['selectedSeconds'] as int,
              maxHours: args['maxHours'] as int,
              maxMinutes: args['maxMinutes'] as int,
              maxSeconds: args['maxSeconds'] as int,
              riderName: args['riderName'] as String,
              eventName: args['eventName'] as String,
              horseName: args['horseName'] as String,
              horseId: args['horseId'] as String,
              additionalDetails: args['additionalDetails'] as String,
            ),
          );
        } else if (settings.name == BluetoothFailedScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => BluetoothFailedScreen(
              selectedHours: args['selectedHours'] as int,
              selectedMinutes: args['selectedMinutes'] as int,
              selectedSeconds: args['selectedSeconds'] as int,
              maxHours: args['maxHours'] as int,
              maxMinutes: args['maxMinutes'] as int,
              maxSeconds: args['maxSeconds'] as int,
              riderName: args['riderName'] as String,
              eventName: args['eventName'] as String,
              horseName: args['horseName'] as String,
              horseId: args['horseId'] as String,
              additionalDetails: args['additionalDetails'] as String,
              errorMessage: args['errorMessage'] as String,
            ),
          );
        } else if (settings.name == ActiveRaceScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ActiveRaceScreen(
              maxHours: args['maxHours'] as int,
              maxMinutes: args['maxMinutes'] as int,
              maxSeconds: args['maxSeconds'] as int,
              riderName: args['riderName'] as String,
              eventName: args['eventName'] as String,
              horseName: args['horseName'] as String,
              horseId: args['horseId'] as String,
              additionalDetails: args['additionalDetails'] as String,
            ),
          );
        } else if (settings.name == RaceResultsScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => RaceResultsScreen(
              elapsedSeconds: args['elapsedSeconds'] as int,
              elapsedHours: args['elapsedHours'] as int? ?? 0,
              elapsedMinutes: args['elapsedMinutes'] as int? ?? 0,
              elapsedSecondsOnly: args['elapsedSecondsOnly'] as int? ?? 0,
              elapsedMilliseconds: args['elapsedMilliseconds'] as int? ?? 0,
              maxSeconds: args['maxSeconds'] as int,
              riderName: args['riderName'] as String,
              eventName: args['eventName'] as String,
              horseName: args['horseName'] as String,
              horseId: args['horseId'] as String,
              additionalDetails: args['additionalDetails'] as String,
              isSuccess: args['isSuccess'] as bool,
              raceStatus: args['raceStatus'] as String?,
            ),
          );
        }
        return null;
      },
      routes: {
        PinLoginScreen.routeName: (_) => const PinLoginScreen(),
        EventLocationScreen.routeName: (_) => const EventLocationScreen(),
        ModeSelectionScreen.routeName: (_) => const ModeSelectionScreen(),
        JumpingScreen.routeName: (_) => const JumpingScreen(),
        MountainSportScreen.routeName: (_) => const MountainSportScreen(),
        TopScoreJumpingScreen.routeName: (_) => const TopScoreJumpingScreen(),
        NormalJumpingScreen.routeName: (_) => const NormalJumpingScreen(),
        ReportingScreen.routeName: (_) => const ReportingScreen(),
        PerformanceReportScreen.routeName: (_) =>
            const PerformanceReportScreen(),
      },
    );
  }
}
