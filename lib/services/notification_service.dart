import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      read: json['read'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NotificationService {
  // même style que VoiceService
  static const String baseUrl = 'http://172.16.27.16:5000';

  static Future<Map<String, String>> _buildHeaders() async {
    final token = AuthService.getAccessToken(); // même méthode que pour la voix

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<List<NotificationItem>> list({
    int page = 1,
    int limit = 50,
  }) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/notifications');

    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('Erreur chargement notifications: ${resp.statusCode}');
    }

    final jsonBody = json.decode(resp.body);
    final data = jsonBody['data'] ?? jsonBody;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return items;
  }

  static Future<int> unreadCount() async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/notifications/unread-count');

    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('Erreur unread-count: ${resp.statusCode}');
    }

    final jsonBody = json.decode(resp.body);
    final data = jsonBody['data'] ?? jsonBody;
    return (data['unread'] as num?)?.toInt() ?? 0;
  }

  static Future<void> markRead(String id) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/notifications/$id/read');

    final resp = await http.post(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('Erreur markRead: ${resp.statusCode}');
    }
  }

  static Future<void> markAllRead() async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/notifications/mark-all-read');

    final resp = await http.post(uri, headers: headers);

    if (resp.statusCode != 200) {
      throw Exception('Erreur markAllRead: ${resp.statusCode}');
    }
  }
}
