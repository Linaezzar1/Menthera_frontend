import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  String _plan = 'mensuel';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement en cours...')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInsets = MediaQuery.of(context).viewInsets.bottom; // clavier
    final bottomSafe = MediaQuery.of(context).padding.bottom;       // safe area

    return Scaffold(
      backgroundColor: Colors.transparent, // le gradient peint tout
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity, // couvre tout le viewport
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0D0221), Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF4A2C6D)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      16,
                      20,
                      16 + bottomSafe + (bottomInsets > 0 ? bottomInsets : 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        _buildPlans(),
                        const SizedBox(height: 16),
                        _buildCardForm(),
                        const SizedBox(height: 20),
                        _buildSummary(),
                        const SizedBox(height: 16),
                        _buildPayButton(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text('Paiement', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        const Spacer(),
        IconButton(
          tooltip: 'Historique',
          onPressed: () => Navigator.pushNamed(context, '/history'),
          icon: const Icon(Icons.history_rounded, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPlans() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choisissez votre offre', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _planChip('mensuel', 'Mensuel', '9.99 € / mois'),
              _planChip('annuel', 'Annuel', '79.99 € / an'),
              _planChip('pro', 'Pro', '14.99 € / mois'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planChip(String value, String title, String subtitle) {
    final bool selected = _plan == value;
    return InkWell(
      onTap: () => setState(() => _plan = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: selected
                ? const [Color(0xFF00D4FF), Color(0xFFFF6EC7)]
                : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.03)],
          ),
          border: Border.all(color: selected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.15)),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF6B5FF8).withOpacity(0.4), blurRadius: 18)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _input(
            label: 'Nom sur la carte',
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null || v.trim().isEmpty ? 'Obligatoire' : null,
          ),
          const SizedBox(height: 12),
          _input(
            label: 'Numéro de carte',
            controller: _numberCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            hint: '4242 4242 4242 4242',
            validator: (v) => v == null || v.replaceAll(' ', '').length < 16 ? 'Numéro invalide' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _input(
                  label: 'Expiration (MM/AA)',
                  controller: _expiryCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  hint: '12/27',
                  validator: (v) => v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v) ? 'Invalide' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _input(
                  label: 'CVV',
                  controller: _cvvCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  hint: '123',
                  obscureText: true,
                  validator: (v) => v == null || v.length < 3 ? 'Invalide' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input({
    required String label,
    String? hint,
    bool obscureText = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: Color(0xFF00D4FF)),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final price = _plan == 'annuel' ? 79.99 : _plan == 'pro' ? 14.99 : 9.99;
    final label = _plan == 'annuel' ? 'Annuel' : _plan == 'pro' ? 'Pro' : 'Mensuel';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Offre $label', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('${price.toStringAsFixed(2)} €', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B5FF8),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      onPressed: _submit,
      child: Text('Payer maintenant', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }
}
