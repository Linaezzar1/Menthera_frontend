import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart'; // Pour AppConstants

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appGradient,
        ),
        child: Center(
          child: Container(
            width: 350,
            height: 650,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.09),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius * 1.8),
              border: Border.all(
                color: Colors.white.withOpacity(0.17),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Column(
                    children: [
                      Text(
                        'Meet the',
                        style: GoogleFonts.poppins(
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Menthera!',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.23),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: const Text(
                          'Need our help now?',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Image.asset(
                        AppConstants.robotAsset,
                        height: 200,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 38.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/voice');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius + 10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                        const SizedBox(width: 16),
                        Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
