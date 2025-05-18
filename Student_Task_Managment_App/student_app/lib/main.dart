import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://rzrqemfkixqlthlwinqf.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6cnFlbWZraXhxbHRobHdpbnFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0MDU4OTcsImV4cCI6MjA2Mjk4MTg5N30.oMwdBr8vX7Vja7oSfg_SqLIn45yXigQAJaP7lYkv8ak',
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
          accentColor: AppColors.accent,
          backgroundColor: AppColors.background,
        ).copyWith(
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.copyWith(
            headlineSmall: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            bodyMedium: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
            titleLarge: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}