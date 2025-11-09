import 'package:flutter/material.dart';
import 'package:projet_integration/screens/history_screen.dart';
import 'package:projet_integration/screens/login_screen.dart';
import 'package:projet_integration/screens/payment_refused.dart';
import 'package:projet_integration/screens/payment_screen.dart';
import 'package:projet_integration/screens/payment_success.dart';
import 'package:projet_integration/screens/signup_screen.dart';
import 'package:projet_integration/screens/voice_to_ai_screen.dart';
import 'package:projet_integration/screens/welcome_screen.dart';
import 'package:projet_integration/services/auth_guard.dart';
import 'package:projet_integration/theme/app_theme.dart';
import 'package:projet_integration/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
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
        '/welcome': (context) => const AuthGuard(child: WelcomeScreen()) ,
        '/voice': (context) => const AuthGuard(child: VoiceToAiScreen()) ,
        '/payment': (context) => const AuthGuard(child:PaymentScreen()),
        '/history': (context) => const AuthGuard(child:HistoryScreen()),
        '/success': (context) =>const PaymentSuccessPage(),
        '/cancel': (context) =>const PaymentRefusedPage(),
      },
    );
  }
}