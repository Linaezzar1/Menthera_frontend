import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.1.18:5000/api/v1/user';

  /// Récupérer le profil utilisateur
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Aucun token - utilisateur non connecté');
        return null;
      }

      final uri = Uri.parse('$baseUrl/me');
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      print('Profil status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Erreur getProfile: $e');
      return null;
    }
  }

  /// Mettre à jour le profil utilisateur (nom, avatar)
  static Future<Map<String, dynamic>?> updateProfile({String? name, String? avatar}) async {
    try {
      final token = AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Aucun token - utilisateur non connecté');
        return null;
      }

      final uri = Uri.parse('$baseUrl/profile');
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (avatar != null) body['avatar'] = avatar;

      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('Update status: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Erreur updateProfile: $e');
      return null;
    }
  }

  /// Upload avatar
  static Future<String?> uploadAvatarToServer(String filePath, String accessToken) async {
    try {
      var uri = Uri.parse('$baseUrl/avatar');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(await http.MultipartFile.fromPath('avatar', filePath));

      var response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(respStr);
        return decoded['data']?['avatar']; // URL renvoyée par le backend
      } else {
        print('Upload failed: ${response.statusCode} - $respStr');
        return null;
      }
    } catch (e) {
      print('Upload exception: $e');
      return null;
    }
  }
  /// Changer le mot de passe
  static Future<String?> changePassword(String oldPassword, String newPassword) async {
    try {
      final token = AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Aucun token - utilisateur non connecté');
        return 'Vous devez être connecté';
      }

      final uri = Uri.parse('$baseUrl/change-password');
      final resp = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      print('Change password status: ${resp.statusCode}');
      if (resp.statusCode == 200) return null;
      if (resp.statusCode == 400) {
        final data = jsonDecode(resp.body);
        return data['message'] ?? 'Erreur.';
      }
      return 'Erreur serveur ${resp.statusCode}';
    } catch (e) {
      print('Erreur changePassword: $e');
      return 'Erreur serveur';
    }
  }
}
