import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  bool _isLoggingOut = false;
  bool _isVerifyingPayment = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentSuccess();
  }

  // Vérifier si on revient d'un paiement réussi
  Future<void> _checkPaymentSuccess() async {
    final uri = Uri.base;
    final paymentSuccess = uri.queryParameters['payment_success'];
    final sessionId = uri.queryParameters['session_id'];

    if (paymentSuccess == 'true' && sessionId != null) {
      setState(() {
        _isVerifyingPayment = true;
      });

      await _verifyPaymentWithBackend(sessionId);

      setState(() {
        _isVerifyingPayment = false;
      });
    }
  }

  // Vérifier le paiement avec le backend
  Future<void> _verifyPaymentWithBackend(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/v1/billing/verify-session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'session_id': sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _showSuccessSnackBar();
        } else {
          _showErrorSnackBar('Erreur de vérification du paiement');
        }
      } else {
        _showErrorSnackBar('Impossible de vérifier le paiement');
      }
    } catch (e) {
      print('Erreur vérification: $e');
      _showErrorSnackBar('Erreur de connexion');
    }
  }

  void _showSuccessSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paiement réussi !',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Votre abonnement premium est activé',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00D4FF),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6EC7),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Gérer la déconnexion
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutDialog(context),
    );

    if (shouldLogout == true) {
      setState(() {
        _isLoggingOut = true;
      });

      try {
        await AuthService.logout();
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Erreur de déconnexion: $e'),
                ],
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
        }
      }
    }
  }

  // Dialog de confirmation de déconnexion
  Widget _buildLogoutDialog(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A0B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6EC7), Color(0xFF6B5FF8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Déconnexion',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6EC7), Color(0xFF6B5FF8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Déconnexion',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bouton de déconnexion
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6EC7).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6EC7), Color(0xFF6B5FF8)],
                      ).createShader(bounds),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Déconnexion',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms, delay: 1400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildLogoutButton(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
            // Overlay de vérification de paiement
            if (_isVerifyingPayment)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0B2E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF00D4FF),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Vérification du paiement...',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Overlay de déconnexion
            if (_isLoggingOut)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A0B2E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFFFF6EC7),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Déconnexion...',
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
          // 🟣 Le point-clé: FittedBox
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Start Your Journey',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
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
