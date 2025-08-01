import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/create_gang_page.dart';
import 'pages/join_gang_page.dart';
import 'pages/gang_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gang App',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A2634),
        scaffoldBackgroundColor: const Color(0xFFFEE5B1),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A2634),
          secondary: Color(0xFF203E5F),
          tertiary: Color(0xFFFFCC00),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF1A2634)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFCC00),
            foregroundColor: const Color(0xFF1A2634),
          ),
        ),
      ),
      home: const HomePage(),
      routes: {
        '/create-gang': (context) => const CreateGangPage(),
        '/join-gang': (context) => const JoinGangPage(),
        '/gang-home': (context) => const GangHomePage(),
      },
    );
  }
}
