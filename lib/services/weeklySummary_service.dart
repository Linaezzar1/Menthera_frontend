import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';
import 'package:projet_integration/services/user_service.dart';

class WeeklySummaryService {
  static const String baseUrl = 'http://172.16.27.16:5000/api/v1/weekly-summary';

  /// Récupérer le résumé de la semaine précédente pour l'utilisateur connecté
  static Future<Map<String, dynamic>?> getPreviousWeekSummaryCurrentUser() async {
    try {
      final token = AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Aucun token - utilisateur non connecté');
        return null;
      }
      // 1. Récupère le userId du profil
      final user = await UserService.getProfile();
      final userId = user?['id'];
      print(user);
      if (userId == null) {
        print('Impossible de récupérer userId depuis UserService');
        return null;
      }
      print(userId);

      // 2. Appelle l'API avec ce userId
      final uri = Uri.parse('$baseUrl/previous/$userId');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
      print('WeeklySummary status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Erreur getPreviousWeekSummaryCurrentUser: $e');
      return null;
    }
  }

  static Future<bool> endSession(int sessionMlId) async {
    try {
      final token = AuthService.getAccessToken();
      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse('$baseUrl/api/v1/chat/sessions/$sessionMlId/complete');
      final resp = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      print('❌ Exception endSession: $e');
      return false;
    }
  }

}
