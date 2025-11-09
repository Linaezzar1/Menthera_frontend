import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentRefusedPage extends StatelessWidget {
  const PaymentRefusedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 88),
              SizedBox(height: 24),
              Text('Paiement refusé',
                  style: GoogleFonts.orbitron(fontSize: 28, color: Colors.red[900], fontWeight: FontWeight.bold)),
              SizedBox(height: 18),
              Text('Votre paiement n\'a pas été validé. Réessayez ou choisissez un autre moyen.', style: TextStyle(fontSize: 16)),
              SizedBox(height: 28),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/welcome'),
                child: Text('Retour'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
