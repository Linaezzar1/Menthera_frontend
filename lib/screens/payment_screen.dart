import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _plan = 'monthly';
  bool _isLoading = false;
  String? _error;

  final Map<String, String> _planLabels = {
    'monthly': 'Mensuel',
    'quarterly': 'Pro',
    'yearly': 'Annuel',
  };

  final Map<String, double> _planPrices = {
    'monthly': 9.99,
    'quarterly': 14.99,
    'yearly': 79.99,
  };

  Future<void> _continuePayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = AuthService.getAccessToken();
      if (token == null) throw Exception("Token manquant, veuillez vous reconnecter.");

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/v1/billing/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'plan': _plan}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data']?['url'] != null) {
        await launchUrl(Uri.parse(data['data']['url']),
            mode: LaunchMode.externalApplication);
      } else {
        setState(() {
          _error = data['error'] ?? 'Erreur lors de la récupération du paiement.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0D0221), Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF4A2C6D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 32 + bottomPad),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.11),
                      blurRadius: 44,
                      spreadRadius: 2,
                    )
                  ],
                ),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            'Paiement',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Historique',
                          onPressed: () => Navigator.pushNamed(context, '/history'),
                          icon: const Icon(Icons.history_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPlans(),
                    const SizedBox(height: 18),
                    _buildSummary(),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5FF8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                        onPressed: _isLoading ? null : _continuePayment,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Continuer le paiement",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Choix de l'offre", style: GoogleFonts.spaceGrotesk(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _planLabels.entries.map(
                (entry) => _planChip(entry.key, entry.value, '${_planPrices[entry.key]} € / ${entry.key == "yearly" ? "an" : "mois"}'),
          ).toList(),
        ),
      ],
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
          border: Border.all(
            color: selected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.15),
          ),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF6B5FF8).withOpacity(0.4), blurRadius: 18)]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final price = _planPrices[_plan]!;
    final label = _planLabels[_plan]!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Offre $label', style: GoogleFonts.spaceGrotesk(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Text('${price.toStringAsFixed(2)} €', style: GoogleFonts.orbitron(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
