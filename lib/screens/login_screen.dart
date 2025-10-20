import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart'; // Assuming constants.dart defines borderRadius

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary.withOpacity(0.8), // Deep purple
              AppTheme.accent.withOpacity(0.5),  // Lighter purple transition
            ],
          ),
        ),
        child: Stack(
          children: [
            // Placeholder for 3D character illustration (replace with actual asset)
            Positioned(
              top: 20,
              left: 20,
              child: Image.asset(
                'assets/images/robot1.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: 350,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.5),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ).animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 1.0, end: 0.0, curve: Curves.easeOut),
                      const SizedBox(height: 8),
                      Text(
                        'welcome back we missed you!',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ).animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 1.0, end: 0.0),
                      const SizedBox(height: 30),
                      _InputField(label: 'Username')
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 400.ms)
                          .slideX(begin: -20.0, end: 0.0),
                      const SizedBox(height: 15),
                      _InputField(label: 'Password', obscure: true)
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 600.ms)
                          .slideX(begin: 20.0, end: 0.0),
                      const SizedBox(height: 20), // Adjusted spacing after removing Forgot Password
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius + 10),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/welcome');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius + 10),
                            ),
                          ),
                          child: Text(
                            'Sign in',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ).animate()
                            .fadeIn(duration: 500.ms, delay: 800.ms)
                            .scaleXY(begin: 0.9, end: 1.0),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'or continue with',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SocialButton(icon: Icons.g_mobiledata),
                          _SocialButton(icon: Icons.facebook),
                        ],
                      ).animate()
                          .fadeIn(duration: 500.ms, delay: 1000.ms)
                          .scaleXY(begin: 0.95, end: 1.0),
                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup'); // Navigate to SignupScreen
                        },
                        child: Text(
                          'Don’t have an account? Sign up',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate()
                          .fadeIn(duration: 500.ms, delay: 1200.ms)
                          .scaleXY(begin: 0.95, end: 1.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final bool obscure;

  const _InputField({required this.label, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: label == 'Username' ? const Icon(Icons.person, color: Colors.white70) : const Icon(Icons.lock, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;

  const _SocialButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Icon(icon, color: Colors.white70, size: 24),
      ),
    );
  }
}