import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Student Task Tracker - Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF3B00FF), // Neon Indigo
          scaffoldBackgroundColor: const Color(0xFF1A1A2E), // Dark Neon Gray
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.indigo,
            accentColor: const Color(0xFFFF2E63), // Neon Coral
            backgroundColor: const Color(0xFF1A1A2E),
          ).copyWith(
            surface: Colors.white.withOpacity(0.1), // Frosted Neon White
            onSurface: Colors.white70,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.copyWith(
              headlineSmall: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              bodyMedium: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white60,
              ),
              titleLarge: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            color: Colors.white.withOpacity(0.1), // Frosted Neon White
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF3B00FF), // Neon Indigo
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              elevation: 2,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A4E69)), // Neon Gray
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A4E69)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B00FF), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF2E63), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF4A4E69), // Neon Gray
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white70,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}