import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/create_gang_page.dart';
import 'pages/join_gang_page.dart';
import 'pages/gang_home_page.dart';
import 'pages/chat_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mantri',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A2634),
        scaffoldBackgroundColor: const Color(0xFFFEE5B1),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A2634),
          secondary: Color(0xFF203E5F),
          tertiary: Color(0xFFFFCC00),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF1A2634)),
          headlineMedium: TextStyle(color: Color(0xFF1A2634)),
          bodyLarge: TextStyle(color: Color(0xFF1A2634)),
          bodyMedium: TextStyle(color: Color(0xFF203E5F)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF203E5F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const HomePage(),
        '/create-gang': (context) => const CreateGangPage(),
        '/join-gang': (context) => const JoinGangPage(),
        '/gang-home': (context) => const GangHomePage(),
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        await ApiService.getCurrentUser();
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFEE5B1),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF203E5F)),
        ),
      );
    }

    if (_isAuthenticated) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
