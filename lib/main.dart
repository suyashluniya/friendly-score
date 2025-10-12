import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/jumping_screen.dart';
import 'screens/top_score_screen.dart';
import 'screens/normal_jumping_screen.dart';
import 'screens/mountain_sport_screen.dart';

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
      initialRoute: ModeSelectionScreen.routeName,
      routes: {
        ModeSelectionScreen.routeName: (_) => const ModeSelectionScreen(),
        JumpingScreen.routeName: (_) => const JumpingScreen(),
        MountainSportScreen.routeName: (_) => const MountainSportScreen(),
        TopScoreJumpingScreen.routeName: (_) => const TopScoreJumpingScreen(),
        NormalJumpingScreen.routeName: (_) => const NormalJumpingScreen(),
      },
    );
  }
}
