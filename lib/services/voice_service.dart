import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class VoiceService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  static Future<Map<String, dynamic>?> analyzeVoice(
      String audioPath,
      double duration, {
        int? sessionMlId,
      }) async {
    try {
      final token = AuthService.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ Pas de token - Utilisateur non connecté');
        return {
          'response': 'Veuillez vous connecter pour utiliser cette fonctionnalité',
          'emotion': 'neutral',
          'questions': [],
        };
      }

      final uri = Uri.parse('$baseUrl/api/v1/voice/sessions/voice');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('audio', audioPath));
      request.fields['duration'] = duration.toString();

      // Ajoute session_ml_id uniquement si fourni (après la 1ère séance)
      if (sessionMlId != null) {
        request.fields['session_ml_id'] = sessionMlId.toString();
      }

      print('📤 Envoi vers: $uri');
      print('📁 Fichier: $audioPath');
      print('⏱️  Durée: ${duration}s');
      print('🔑 Token: ${token.substring(0, 20)}...');
      if (sessionMlId != null) print('🆔 session_ml_id: $sessionMlId');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout - Le serveur ne répond pas');
        },
      );

      print('📡 Status code: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        final response = await http.Response.fromStream(streamedResponse);
        final data = jsonDecode(response.body);

        print('✅ Réponse complète: $data');

        final responseData = data['data'] ?? data;

        return {
          'response': responseData['therapist_response'] ??
              responseData['assistant_reply'] ??
              responseData['response'] ??
              'Réponse non disponible',
          'emotion': responseData['emotion'] ?? 'neutral',
          'text': responseData['transcription'] ?? '',
          'questions': responseData['questions'] ?? responseData['next_questions'] ?? [],
          'session_id': responseData['session_id'] ?? responseData['session_ml_id'],
          'danger': responseData['danger_analysis'],
          'confidence': responseData['confidence'],
        };
      } else if (streamedResponse.statusCode == 401) {
        print('❌ Token invalide ou expiré');
        return {
          'response': 'Session expirée, veuillez vous reconnecter',
          'emotion': 'neutral',
          'questions': [],
        };
      } else if (streamedResponse.statusCode == 404) {
        print('❌ Route non trouvée');
        return {
          'response': 'Service vocal temporairement indisponible',
          'emotion': 'neutral',
          'questions': [],
        };
      } else {
        final response = await http.Response.fromStream(streamedResponse);
        print('❌ Erreur ${streamedResponse.statusCode}: ${response.body}');

        return {
          'response': 'Erreur du serveur (${streamedResponse.statusCode})',
          'emotion': 'neutral',
          'questions': [],
        };
      }
    } catch (e) {
      print('❌ Exception dans analyzeVoice: $e');
      return {
        'response': 'Erreur de connexion au serveur',
        'emotion': 'neutral',
        'questions': [],
      };
    }
  }
}
