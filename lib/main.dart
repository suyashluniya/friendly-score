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

// Modern Design System Colors - Blinkit-Inspired Fresh Green Theme
class AppColors {
  // Primary colors - Fresh Green (Blinkit-style)
  static const Color primary = Color(0xFF00B37E);
  static const Color primaryDark = Color(0xFF009966);
  static const Color primaryLight = Color(0xFF33CC99);
  static const Color primarySoft = Color(0xFFE6F7F1);

  // Background colors - Clean whites
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);

  // Text colors - Strong contrast
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic colors
  static const Color success = Color(0xFF00B37E);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF2196F3);

  // Border colors
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Card shadow color
  static const Color shadowColor = Color(0x0F000000);
}

// Consistent spacing values (8px grid)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
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

// Modern shadows
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sport Timer Pro',
      theme: ThemeData(
        // Color Scheme - Fresh Green
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.primaryDark,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          error: AppColors.error,
          onPrimary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
        ),

        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,

        // Typography with Poppins
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          // Display styles - Bold & Impactful
          displayLarge: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
            color: AppColors.textPrimary,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),

          // Headline styles
          headlineLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),

          // Title styles
          titleLarge: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),
          titleSmall: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),

          // Body styles - Clean & Readable
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: AppColors.textSecondary,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
            color: AppColors.textTertiary,
          ),

          // Label styles - Semi-bold
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: AppColors.textPrimary,
          ),
          labelMedium: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
            color: AppColors.textSecondary,
          ),
          labelSmall: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
            color: AppColors.textTertiary,
          ),
        ),

        // AppBar Theme - Clean & Minimal
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.poppins(
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

        // Button Themes - 56px height, bold
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
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
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
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
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.25,
            ),
          ),
        ),

        // Card Theme - Soft shadows, rounded
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          margin: EdgeInsets.zero,
        ),

        // Input Decoration Theme - Modern fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md + 2,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
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
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
          thickness: 1,
          space: 1,
        ),

        // Bottom Sheet Theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primarySoft,
          labelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          side: BorderSide.none,
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
              riderName: args['riderName'] as String? ?? '',
              riderNumber: args['riderNumber'] as String? ?? '',
              photoPath: args['photoPath'] as String? ?? '',
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
              riderName: args['riderName'] as String? ?? '',
              riderNumber: args['riderNumber'] as String? ?? '',
              photoPath: args['photoPath'] as String? ?? '',
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
              riderName: args['riderName'] as String? ?? '',
              riderNumber: args['riderNumber'] as String? ?? '',
              photoPath: args['photoPath'] as String? ?? '',
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
              riderName: args['riderName'] as String? ?? '',
              riderNumber: args['riderNumber'] as String? ?? '',
              photoPath: args['photoPath'] as String? ?? '',
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
              riderName: args['riderName'] as String? ?? '',
              riderNumber: args['riderNumber'] as String? ?? '',
              photoPath: args['photoPath'] as String? ?? '',
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
