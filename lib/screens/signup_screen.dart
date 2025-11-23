import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart'; // pour AppConstants.apiBaseUrl

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService.signup(
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
          _confirmPasswordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie !')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Boutons sociaux (même logique que sur LoginScreen)
  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: _SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            onTap: () async {
              final url = Uri.parse('http://192.168.1.18:5000/api/v1/auth/google');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impossible d’ouvrir Google')),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _SocialButton(
            icon: Icons.facebook_rounded,
            label: 'Facebook',
            onTap: () async {
              final url = Uri.parse('${AppConstants.apiBaseUrl}/api/v1/auth/facebook');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Impossible d’ouvrir Facebook')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final bool clavierOuvert = viewInsets > 0;

    Widget mainContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Image.asset(
            'assets/images/mentheraLogo1.png',
            height: clavierOuvert ? size.height * 0.09 : size.height * 0.13,
            width: clavierOuvert ? size.height * 0.09 : size.height * 0.13,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: clavierOuvert ? 5 : 8),
        Text(
          'Menthera',
          style: GoogleFonts.cinzel(
            fontSize: clavierOuvert ? 18 : 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: clavierOuvert ? 1 : 2),
        Text(
          'Votre accompagnement psychologique',
          style: GoogleFonts.poppins(
            fontSize: clavierOuvert ? 10 : 12,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.87),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: clavierOuvert ? 6 : 10),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                hint: 'votre@email.com',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email invalide';
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                obscureText: false,
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _usernameController,
                label: 'Nom d\'utilisateur',
                icon: Icons.person_outline,
                hint: 'Choisissez un pseudo',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un nom d\'utilisateur';
                  if (value.length < 3) return 'Minimum 3 caractères';
                  return null;
                },
                obscureText: false,
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _passwordController,
                label: 'Mot de passe',
                icon: Icons.lock_outline,
                hint: 'Minimum 8 caractères',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                  if (value.length < 8) return 'Minimum 8 caractères';
                  return null;
                },
                obscureText: !_isPasswordVisible,
                suffix: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              const SizedBox(height: 8),
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirmer mot de passe',
                icon: Icons.lock_outline,
                hint: 'Confirmez votre mot de passe',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez confirmer votre mot de passe';
                  if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
                obscureText: !_isConfirmPasswordVisible,
                suffix: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () => setState(
                        () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: const Color(0xFF6B5FA8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Créer mon compte',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: clavierOuvert ? 8 : 12),
        _buildSocialButtons(),
        SizedBox(height: clavierOuvert ? 4 : 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Déjà un compte ? ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                'Se connecter',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5B4FB3),
              Color(0xFF7B68C8),
              Color(0xFF9B8FDB),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: clavierOuvert
                ? SingleChildScrollView(child: mainContent)
                : mainContent,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    required bool obscureText,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.13),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 19),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
