import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/user_service.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({Key? key}) : super(key: key);

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    final res = await UserService.changePassword(_oldCtrl.text, _newCtrl.text);
    setState(() => _loading = false);
    if (res == null) {
      setState(() => _success = "Mot de passe changé avec succès !");
      // Optionnel : Navigator.pop(context);
    } else {
      setState(() => _error = res);
    }
  }

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Changer le mot de passe",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          _buildGradientBackground(),
          _buildFloatingOrbs(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Changer le mot de passe",
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.20, end: 0),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: _oldCtrl,
                        obscureText: true,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: "Ancien mot de passe",
                          labelStyle: GoogleFonts.poppins(color: Colors.white70),
                          fillColor: Colors.white.withOpacity(0.09),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Veuillez entrer votre ancien mot de passe" : null,
                      ).animate().slideY(begin: 0.20, end: 0).fadeIn(duration: 600.ms),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newCtrl,
                        obscureText: true,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: "Nouveau mot de passe",
                          labelStyle: GoogleFonts.poppins(color: Colors.white70),
                          fillColor: Colors.white.withOpacity(0.09),
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (val) => val != null && val.length >= 6 ? null : "6 caractères minimum",
                      ).animate().slideY(begin: 0.15, end: 0).fadeIn(duration: 500.ms),
                      const SizedBox(height: 18),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(_error!, style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 14)),
                        ),
                      if (_success != null)
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(_success!, style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 14)),
                        ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _loading
                            ? const CircularProgressIndicator(color: Color(0xFF6B5FF8))
                            : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B5FF8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 6,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            ),
                            icon: const Icon(Icons.lock_outline, color: Colors.white),
                            label: Text("Valider", style: GoogleFonts.orbitron(fontSize: 16, color: Colors.white)),
                            onPressed: _onSave,
                          ).animate().fadeIn(duration: 820.ms).slideY(begin: 0.18, end: 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF1A0B2E), Color(0xFF3D2C5C), Color(0xFF5B4FB3), Color(0xFF7B68C8)],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        Positioned(
          top: 67,
          right: -33,
          child: Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFFFF6EC7).withOpacity(0.29), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(duration: 4000.ms, begin: 0, end: 28, curve: Curves.easeInOut)
              .scale(duration: 2500.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.11, 1.13)),
        ),
        Positioned(
          bottom: 50,
          left: -44,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF6B5FF8).withOpacity(0.17), Colors.transparent],
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveX(duration: 3200.ms, begin: 0, end: 17, curve: Curves.easeInOut)
              .scale(duration: 2333.ms, begin: const Offset(1.0, 1.0), end: const Offset(1.09, 1.13)),
        ),
      ],
    );
  }
}
