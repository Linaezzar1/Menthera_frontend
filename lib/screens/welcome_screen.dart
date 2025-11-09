import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF1A0B2E),
              const Color(0xFF3D2C5C),
              const Color(0xFF5B4FB3),
              const Color(0xFF7B68C8),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildStarryBackground(),
            _buildFloatingOrbs(),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.06),
                      _buildModernHeader(),
                      SizedBox(height: size.height * 0.05),
                      _buildHeroCard(context, size),
                      SizedBox(height: size.height * 0.04),
                      _buildFeatureCards(),
                      SizedBox(height: size.height * 0.04),
                      _buildCTAButton(context, size),
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 1200.ms, curve: Curves.easeInOut);
  }

  Widget _buildStarryBackground() {
    return Stack(
      children: List.generate(30, (index) {
        final random = math.Random(index);
        return Positioned(
          left: random.nextDouble() * 400,
          top: random.nextDouble() * 800,
          child: Container(
            width: random.nextDouble() * 3 + 1,
            height: random.nextDouble() * 3 + 1,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(random.nextDouble() * 0.8 + 0.2),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
              .fadeOut(duration: Duration(milliseconds: 1000 + random.nextInt(2000)))
              .then()
              .fadeIn(duration: Duration(milliseconds: 1000 + random.nextInt(2000))),
        );
      }),
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6EC7).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(duration: 6000.ms, begin: 0, end: 50, curve: Curves.easeInOut)
              .scale(duration: 4000.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2)),
        ),
        Positioned(
          bottom: 150,
          left: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B5FF8).withOpacity(0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(duration: 7000.ms, begin: 0, end: 60, curve: Curves.easeInOut)
              .scale(duration: 5000.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15)),
        ),
      ],
    );
  }

  Widget _buildModernHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6EC7),
                const Color(0xFF6B5FF8),
                const Color(0xFF00D4FF),
              ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0B2E),
              shape: BoxShape.circle,
            ),
            child: Hero(
              tag: 'app_character',
              child: Container(
                height: 130,
                width: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7B68C8).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Image.asset('assets/images/robot1.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ).animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFFFF6EC7),
              const Color(0xFF00D4FF),
            ],
          ).createShader(bounds),
          child: Text(
            'Menthera',
            style: GoogleFonts.orbitron(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ).animate()
            .fadeIn(duration: 1000.ms, delay: 300.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOut),
        const SizedBox(height: 12),
        Text(
          'AI-Powered Mental Wellness',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF00D4FF),
            letterSpacing: 2,
          ),
        ).animate()
            .fadeIn(duration: 1000.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, Size size) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5FF8).withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00D4FF),
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                            .fadeOut(duration: 800.ms)
                            .then()
                            .fadeIn(duration: 800.ms),
                        const SizedBox(width: 8),
                        Text(
                          'Available 24/7',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00D4FF),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Your Personal\nAI Psychologist',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Expérience unique d\'accompagnement psychologique intelligent avec analyse émotionnelle en temps réel',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms, delay: 700.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut)
        .shimmer(duration: 3000.ms, delay: 1500.ms, color: Colors.white.withOpacity(0.1));
  }

  Widget _buildFeatureCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ModernFeatureCard(
          icon: Icons.mic_rounded,
          title: 'Voice\nAnalysis',
          gradient: const [Color(0xFFFF6EC7), Color(0xFFFF8A9B)],
          delay: 900,
        ),
        _ModernFeatureCard(
          icon: Icons.psychology_outlined,
          title: 'Smart\nAI',
          gradient: const [Color(0xFF6B5FF8), Color(0xFF9B8FDB)],
          delay: 1000,
        ),
        _ModernFeatureCard(
          icon: Icons.favorite_border_rounded,
          title: 'Emotion\nTracking',
          gradient: const [Color(0xFF00D4FF), Color(0xFF4DD4FF)],
          delay: 1100,
        ),
      ],
    );
  }

  Widget _buildCTAButton(BuildContext context, Size size) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6EC7),
            Color(0xFF6B5FF8),
            Color(0xFF00D4FF),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5FF8).withOpacity(0.6),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/voice'),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 14),
                Text(
                  'Start Your Journey',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms, delay: 1200.ms)
        .slideY(begin: 0.4, end: 0, curve: Curves.easeOut)
        .then(delay: 1500.ms)
        .shimmer(duration: 2500.ms, color: Colors.white.withOpacity(0.5));
  }
}

class _ModernFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final int delay;

  const _ModernFeatureCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 700.ms, delay: Duration(milliseconds: delay))
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), curve: Curves.elasticOut);
  }
}
