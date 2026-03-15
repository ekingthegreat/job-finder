import 'package:flutter/material.dart';
// 1. Updated import to point to the new auth folder
import 'package:enricoso/auth/landingpage.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Optional: hides the debug banner
      title: 'Job Seeker App',
      theme: ThemeData(
        primaryColor: const Color(0xFFB30000),
        primaryColorDark: const Color(0xFF8A0000),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFB30000),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB30000),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
      ),
      // 2. Changed home from JobListingPage to LoginPage
      home: const LandingPage(), 
    );
  }
}