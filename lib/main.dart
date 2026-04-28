import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/subscription_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SubProvider(),
      child: const SubTrackerApp(),
    ),
  );
}

class SubTrackerApp extends StatelessWidget {
  const SubTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SubTracker Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19), 
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme), 
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}