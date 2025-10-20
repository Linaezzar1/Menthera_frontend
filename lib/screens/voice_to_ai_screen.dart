import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class VoiceToAiScreen extends StatefulWidget {
  const VoiceToAiScreen({super.key});

  @override
  State<VoiceToAiScreen> createState() => _VoiceToAiScreenState();
}

class _VoiceToAiScreenState extends State<VoiceToAiScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.92,
      upperBound: 1.10,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppConstants.borderRadius * 1.7);
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 350,
          height: 650,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary.withOpacity(0.2),
                AppTheme.accent.withOpacity(0.1),
              ],
            ),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 20,
                left: 18,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ),
              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Voice Assessment',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Go ahead, I\'m listening...',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      height: 220,
                      width: 220,
                      child: Lottie.asset(
                        'assets/animations/voice_wave.json',
                        repeat: true,
                        animate: _isRecording,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.transparent,
                          child: Icon(Icons.graphic_eq, size: 150, color: AppTheme.accent.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Fluid organic shapes dance across the canvas, conveying a sense of harmony.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ScaleTransition(
                    scale: _pulseController,
                    child: GestureDetector(
                      onTap: () {}, // Placeholder for mic tap
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppTheme.accent, AppTheme.primary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}