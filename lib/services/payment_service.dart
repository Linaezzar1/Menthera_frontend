import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class PaymentService {
  static Future<Map<String, dynamic>> continuePayment(String plan) async {
    final token = AuthService.getAccessToken();
    if (token == null) throw Exception("Token manquant, veuillez vous reconnecter.");

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.18:5000/api/v1/billing/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'plan': plan}),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        data = {'error': 'Réponse serveur mal formée.'};
      }

      // RETURN STATUS + DATA no matter what
      return {
        'status': response.statusCode,
        'data': data,
      };
    } catch (e) {
      // Only throw pure network errors here
      return {
        'status': null,
        'data': {
          'error': "Impossible de se connecter au serveur. Vérifiez votre connexion internet."
        }
      };
    }
  }
}