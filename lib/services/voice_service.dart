import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class VoiceService {
  static const String baseUrl = 'http://192.168.1.70:5000';

  static Future<Map<String, dynamic>?> analyzeVoice(
      String audioPath,
      double duration
      ) async {
    try {
      // Récupère le token depuis AuthService
      final token = AuthService.getAccessToken();

      if (token == null || token.isEmpty) {
        print('❌ Pas de token - Utilisateur non connecté');
        return {
          'response': 'Veuillez vous connecter pour utiliser cette fonctionnalité',
          'emotion': 'neutral',
          'questions': [],
        };
      }

      // Route correcte
      final uri = Uri.parse('$baseUrl/api/v1/voice/sessions/voice');
      final request = http.MultipartRequest('POST', uri);

      // Ajoute le token dans les headers
      request.headers['Authorization'] = 'Bearer $token';

      // Ajoute le fichier audio
      request.files.add(
          await http.MultipartFile.fromPath('audio', audioPath)
      );

      // Ajoute la durée
      request.fields['duration'] = duration.toString();

      print('📤 Envoi vers: $uri');
      print('📁 Fichier: $audioPath');
      print('⏱️  Durée: ${duration}s');
      print('🔑 Token: ${token.substring(0, 20)}...');

      // Envoie la requête avec timeout
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

        // ✅ CORRECTION : Utilise les bons champs selon la réponse Python
        // Python renvoie : { success, session_id, emotion, transcription, therapist_response, questions, ... }

        // Gère les 2 structures possibles (avec ou sans data wrapper)
        final responseData = data['data'] ?? data;

        return {
          // ✅ Le champ principal : therapist_response
          'response': responseData['therapist_response'] ??
              responseData['assistant_reply'] ??
              responseData['response'] ??
              'Réponse non disponible',

          // Émotion détectée
          'emotion': responseData['emotion'] ?? 'neutral',

          // Transcription de ce que tu as dit
          'text': responseData['transcription'] ?? '',

          // Questions de suivi
          'questions': responseData['questions'] ??
              responseData['next_questions'] ??
              [],

          // ID de session
          'session_id': responseData['session_id'] ??
              responseData['session_db_id'],

          // Niveau de danger
          'danger': responseData['danger_analysis'],

          // Confiance de la détection d'émotion
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
