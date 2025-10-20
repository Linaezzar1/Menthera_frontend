import 'package:flutter/material.dart';
import 'package:projet_integration/screens/login_screen.dart';
import 'package:projet_integration/screens/signup_screen.dart';
import 'package:projet_integration/screens/voice_to_ai_screen.dart';
import 'package:projet_integration/screens/welcome_screen.dart';
import 'package:projet_integration/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Psychologist App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/voice': (context) => const VoiceToAiScreen(),
      },
    );
  }
}