import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projet_integration/services/auth_service.dart';

class WeeklyChallengeModel {
  final String id;
  final String title;
  final String description;
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isActive;
  final List<ChallengeQuestion> questions;
  final int? userScore;
  final List<int>? userAnswers;
  final bool userDone;
  final List<Participant> participants;

  WeeklyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.weekStart,
    required this.weekEnd,
    required this.isActive,
    required this.questions,
    this.userScore,
    this.userAnswers,
    required this.userDone,
    required this.participants,
  });

  factory WeeklyChallengeModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    final participants = (json['participants'] as List<dynamic>? ?? [])
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();
    Participant? current = currentUserId != null
        ? participants.firstWhere((p) => p.userId == currentUserId)
        : null;

    return WeeklyChallengeModel(
      id: json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      weekStart: DateTime.tryParse(json['weekStart'] ?? '') ?? DateTime.now(),
      weekEnd: DateTime.tryParse(json['weekEnd'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => ChallengeQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      participants: participants,
      userScore: current?.score,
      userAnswers: current?.answers,
      userDone: current != null,
    );
  }

  Participant? getParticipant(String userId) {
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }


}

class ChallengeQuestion {
  final String text;
  final List<String> choices;
  final int? correctIndex;

  ChallengeQuestion({
    required this.text,
    required this.choices,
    this.correctIndex,
  });

  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      text: json['text'] ?? '',
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((e) => e.toString()).toList(),
      correctIndex: json['correctIndex'] != null ? (json['correctIndex'] as num).toInt() : null,
    );
  }
}


class Participant {
  final String userId;
  final int score;
  final List<int> answers;

  Participant({
    required this.userId,
    required this.score,
    required this.answers,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['user'] ?? '',
      score: json['score'] ?? 0,
      answers: (json['answers'] as List<dynamic>? ?? []).map((e) => (e as num).toInt()).toList(),
    );
  }
}


class WeeklyChallengeService {
  static const String baseUrl = 'http://172.16.27.16:5000';

  static Future<Map<String, String>> _buildHeaders({bool auth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<List<WeeklyChallengeModel>> listChallenges() async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/challenges');
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Erreur listChallenges: ${resp.statusCode} - ${resp.body}');
    }
    final jsonBody = json.decode(resp.body);
    final data = jsonBody['data'] ?? jsonBody;
    return (data as List<dynamic>)
        .map((e) => WeeklyChallengeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<WeeklyChallengeModel> getChallenge(String id) async {
    final headers = await _buildHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/challenges/$id');
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode != 200) {
      throw Exception('Erreur getChallenge: ${resp.statusCode} - ${resp.body}');
    }
    final jsonBody = json.decode(resp.body);
    final data = jsonBody['data'] ?? jsonBody;
    return WeeklyChallengeModel.fromJson(data as Map<String, dynamic>);
  }

  static Future<Map<String, dynamic>> submitScore({
    required String challengeId,
    required List<int> answers,
  }) async {
    final headers = await _buildHeaders(auth: true);
    final uri = Uri.parse('$baseUrl/api/v1/challenges/$challengeId/submit');
    final body = json.encode({'answers': answers});
    final resp = await http.post(uri, headers: headers, body: body);
    if (resp.statusCode != 200) {
      throw Exception('Erreur submitScore: ${resp.statusCode} - ${resp.body}');
    }
    final jsonBody = json.decode(resp.body);
    final data = jsonBody['data'] ?? jsonBody;
    return data as Map<String, dynamic>;
  }
}

// HELPER pour semaine courante
bool isSameWeek(DateTime a, DateTime b) {
  final mondayA = a.subtract(Duration(days: a.weekday - 1));
  final mondayB = b.subtract(Duration(days: b.weekday - 1));
  return mondayA.year == mondayB.year &&
      mondayA.month == mondayB.month &&
      mondayA.day == mondayB.day;
}
