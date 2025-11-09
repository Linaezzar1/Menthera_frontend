import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For Flutter web, Uri.base contains the full URL including query params
    final uri = Uri.base;
    final sessionId = uri.queryParameters['session_id'];

    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 88),
              SizedBox(height: 24),
              Text('Paiement réussi !',
                  style: GoogleFonts.orbitron(
                      fontSize: 28, color: Colors.green[900], fontWeight: FontWeight.bold)),
              SizedBox(height: 18),
              if (sessionId != null)
                ...[
                  Text('Session Stripe: $sessionId',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  SizedBox(height: 8),
                ],
              Text('Votre abonnement premium est activé.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/welcome'),
                child: Text('Retour à l\'accueil'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
