import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage; // ✅ Variable pour stocker l'erreur

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // ✅ Réinitialiser l'erreur
      });

      try {
        await AuthService.login(_emailController.text, _passwordController.text);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connexion réussie !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushReplacementNamed(context, '/welcome');
      } catch (e) {
        // ✅ GESTION AMÉLIORÉE DES ERREURS
        String errorMsg = 'Une erreur est survenue';

        if (e.toString().contains('403')) {
          errorMsg = '⛔ Votre compte a été suspendu. Contactez l\'administrateur.';
        } else if (e.toString().contains('401')) {
          errorMsg = '🔒 Email ou mot de passe incorrect.';
        } else if (e.toString().contains('suspendu')) {
          errorMsg = '⛔ Votre compte a été suspendu. Contactez l\'administrateur.';
        } else if (e.toString().contains('Network')) {
          errorMsg = '📡 Erreur de connexion. Vérifiez votre internet.';
        } else {
          errorMsg = e.toString().replaceAll('Exception: ', '');
        }

        setState(() => _errorMessage = errorMsg);

        // ✅ SNACKBAR ÉLÉGANTE EN COMPLÉMENT
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
            fontSize: clavierOuvert ? 20 : 26,
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
          'Votre espace de connexion sécurisé',
          style: GoogleFonts.poppins(
            fontSize: clavierOuvert ? 10 : 12,
            color: Colors.white.withOpacity(0.87),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: clavierOuvert ? 14 : 22),

        // ✅ AFFICHAGE ÉLÉGANT DE L'ERREUR
        if (_errorMessage != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade700.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.red.shade300.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade100, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 18),
                  onPressed: () => setState(() => _errorMessage = null),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],

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
              SizedBox(height: 8),
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
              SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Color(0xFF6B5FA8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleSignIn,
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Se connecter',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pas de compte ? ',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.85)),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: Text(
                'S\'inscrire',
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
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
