import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.1.18:5000/api/v1/auth';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static String? _accessToken;
  static String? _email;
  static String? _refreshToken;

  static String? getAccessToken() => _accessToken;
  static String? getRefreshToken() => _refreshToken;
  static String? getEmail() => _email;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  static Future<Map<String, dynamic>> signup(
      String email, String username, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': username,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, data['data']['accessToken']);
      await prefs.setString(_refreshTokenKey, data['data']['refreshToken']);
      _accessToken = data['data']['accessToken'];
      _email = email;
      return data['data'];
    } else {
      throw Exception('Échec de l\'inscription: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, data['data']['accessToken']);
      await prefs.setString(_refreshTokenKey, data['data']['refreshToken']);
      _accessToken = data['data']['accessToken'];
      _email = email;
      return data['data'];
    } else {
      throw Exception('Échec de la connexion: ${response.body}');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _accessToken = null;
    _email = null;
  }

  static Future<void> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, data['data']['accessToken']);
      await prefs.setString(_refreshTokenKey, data['data']['refreshToken']);
      _accessToken = data['data']['accessToken'];
    } else {
      throw Exception('Échec du rafraîchissement du token: ${response.body}');
    }
  }
}
