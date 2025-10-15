import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/pin_login_screen.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
          primary: Colors.black,
          secondary: Colors.grey.shade700,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            shadowColor: Colors.black26,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
        }
        return null;
      },
      routes: {
        PinLoginScreen.routeName: (_) => const PinLoginScreen(),
        ModeSelectionScreen.routeName: (_) => const ModeSelectionScreen(),
        JumpingScreen.routeName: (_) => const JumpingScreen(),
        MountainSportScreen.routeName: (_) => const MountainSportScreen(),
        TopScoreJumpingScreen.routeName: (_) => const TopScoreJumpingScreen(),
        NormalJumpingScreen.routeName: (_) => const NormalJumpingScreen(),
      },
    );
  }
}
