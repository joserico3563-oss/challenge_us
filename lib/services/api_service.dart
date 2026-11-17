import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/challenge_model.dart';
import '../models/bonche_model.dart';

class ApiService {
  static const String baseUrl = "https://challengeus-api.onrender.com";

  static Future<UserModel> login(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login').replace(queryParameters: {'email': email}),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Error al iniciar sesión: ${utf8.decode(response.bodyBytes)}');
    }
  }

  static Future<List<ChallengeModel>> getChallengesToday() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/challenges/today'),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((model) => ChallengeModel.fromJson(model)).toList();
    } else {
      throw Exception('Error al cargar los retos');
    }
  }

  static Future<Map<String, dynamic>> submitEvidence({
    required String retoId,
    required String usuarioId,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/evidences'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "reto_id": retoId,
        "usuario_id": usuarioId,
        "image_url": imageUrl,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['detail'] ?? 'Error al enviar evidencia');
    }
  }

  static Future<Map<String, dynamic>> createBonche({
    required String name,
    required String description,
    required String leaderId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bonches'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "leader_id": leaderId,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Error al crear el bonche');
    }
  }

  static Future<Map<String, dynamic>> joinBonche({
    required String inviteCode,
    required String usuarioId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/bonches/join'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "invite_code": inviteCode,
        "usuario_id": usuarioId,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['detail'] ?? 'Error al unirse al bonche');
    }
  }

  static Future<List<BoncheModel>> getUserBonches(String usuarioId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bonches/user/$usuarioId'),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((model) => BoncheModel.fromJson(model)).toList();
    } else {
      throw Exception('Error al cargar los bonches del usuario');
    }
  }

    static Future<Map<String, dynamic>> updateBonche({
    required String boncheId,
    required String userId,
    required String name,
    required int challengesPerDay,
    required int windowMinutes,
    required List<String> times,
    required int tzOffset,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/bonches/$boncheId/config'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "name": name,
        "challenges_per_day": challengesPerDay,
        "window_minutes": windowMinutes,
        "times": times,
        "tz_offset": tzOffset,
      }),
    ).timeout(const Duration(seconds: 60));

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return body as Map<String, dynamic>;
    }
    final detail = body is Map ? body['detail'] : null;
    throw Exception(detail is String ? detail : 'Error al guardar la configuración');
  }

  static Future<List<ChallengeModel>> getBoncheChallenges(String boncheId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/bonches/$boncheId/challenges/today'),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((model) => ChallengeModel.fromJson(model)).toList();
    } else {
      throw Exception('Error al cargar los retos del bonche');
    }
  }

  static Future<List<UserModel>> getRanking() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ranking'),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
      return list.map((model) => UserModel.fromJson(model)).toList();
    } else {
      throw Exception('Error al cargar el ranking');
    }
  }
}
