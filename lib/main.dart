import 'package:flutter/material.dart';
import 'package:enricoso/features/job_seeker/job_seeker_shell/joblisting.dart';
import 'package:enricoso/auth/login.dart';
import 'package:enricoso/auth/registration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enricoso Job Finder',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define your routes
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/jobs': (context) => const JobListingPage(),
      },
      // Fallback for any undefined routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LoginPage(),
        );
      },
    );
  }
}