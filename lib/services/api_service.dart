import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart' show XFile;

import 'package:http/http.dart' as http;

import '../models/bonche_model.dart';
import '../models/challenge_model.dart';
import '../models/cycle_models.dart';
import '../models/notification_models.dart';
import '../models/user_model.dart';

/// La sesión falta, venció o no es válida (HTTP 401).
class ApiAuthException implements Exception {
  const ApiAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Error de negocio devuelto por la API.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Resultado de un login o registro: el JWT y el usuario.
typedef ApiSession = ({String token, UserModel user});

/// Cliente HTTP único de la aplicación.
///
/// Guarda el JWT en memoria y lo adjunta automáticamente a las rutas privadas,
/// de modo que ningún servicio tenga que repetir la cabecera.
class ApiService {
  static String get baseUrl =>
      kIsWeb ? Uri.base.origin : "https://challengeus-api.onrender.com";

  static const Duration _timeout = Duration(seconds: 60);

  static String? _token;
  static bool _webSession = false;

  /// Se dispara cuando la API responde 401 y la sesión deja de ser válida.
  static void Function()? onUnauthorized;

  static bool get hasSession =>
      kIsWeb ? _webSession : _token != null && _token!.isNotEmpty;

  static set token(String? value) => _token = value;

  static void clearSession() {
    _token = null;
    _webSession = false;
  }

  static Future<void> logout() async {
    if (kIsWeb) {
      await _send(
        () => http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: _headers(json: true),
          body: '{}',
        ),
      );
    }
    clearSession();
  }

  static Future<UserModel?> restoreWebSession() async {
    if (!kIsWeb) return null;

    try {
      final user = await getMe();
      _webSession = true;
      return user;
    } on ApiAuthException {
      clearSession();
      return null;
    }
  }

  static Map<String, String> _headers({bool json = false}) {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    final current = _token;
    if (!kIsWeb && current != null && current.isNotEmpty) {
      headers['Authorization'] = 'Bearer $current';
    }
    return headers;
  }

  /// Ejecuta la petición y traduce la respuesta a datos o excepciones claras.
  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Revisa tu conexión.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No pudimos conectar con el servidor. Revisa tu internet.',
      );
    }

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode == 401) {
      clearSession();
      onUnauthorized?.call();
      throw ApiAuthException(
        _errorText(body) ?? 'Tu sesión venció. Inicia sesión de nuevo.',
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body.trim().isEmpty ? null : jsonDecode(body);
    }
    throw ApiException(
      _errorText(body) ?? 'No pudimos completar la solicitud.',
      statusCode: response.statusCode,
    );
  }

  // ------------------------------------------------------------- autenticación

  /// POST /api/auth/login — devuelve el JWT y el usuario.
  static Future<ApiSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: _headers(json: true),
        body: jsonEncode({"email": email.trim(), "password": password}),
      ),
    );
    return _sessionFrom(data, 'No pudimos iniciar sesión.');
  }

  /// POST /api/auth/register — crea la cuenta y devuelve el JWT.
  static Future<ApiSession> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cleanEmail = email.trim();
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: _headers(json: true),
        body: jsonEncode({
          "email": cleanEmail,
          "password": password,
          "display_name": displayName.trim(),
        }),
      ),
    );
    return _sessionFrom(data, 'No pudimos crear tu cuenta.');
  }

  static ApiSession _sessionFrom(dynamic data, String fallback) {
    if (data is! Map<String, dynamic>) throw ApiException(fallback);
    final token = (data['token'] ?? '').toString();
    final raw = data['user'] ?? data['usuario'];
    if ((!kIsWeb && token.isEmpty) || raw is! Map<String, dynamic>) {
      throw ApiException(fallback);
    }
    final user = UserModel.fromJson(raw);
    _token = kIsWeb ? null : token;
    _webSession = kIsWeb;
    return (token: kIsWeb ? '' : token, user: user);
  }

  // ---------------------------------------------------------------- retos

  /// GET /api/bonches/{id}/challenges/today — retos del bonche (privado).
  static Future<List<ChallengeModel>> getBoncheChallenges(
    String boncheId,
  ) async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/bonches/$boncheId/challenges/today'),
        headers: _headers(),
      ),
    );
    return _challengeList(data, 'Error al cargar los retos del bonche');
  }

  static List<ChallengeModel> _challengeList(dynamic data, String message) {
    if (data is! List) throw ApiException(message);
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) ChallengeModel.fromJson(item),
    ];
  }

  // --------------------------------------------------------------- evidencias

  /// POST /api/evidences — sube la fotografía real de la evidencia.
  ///
  /// El backend identifica al usuario por el JWT y resuelve el reto a partir
  /// del slot del bonche; aquí solo se envía el archivo y esa referencia.
  static Future<Map<String, dynamic>> uploadEvidence({
    required String boncheRetoId,
    required String filePath,
    Uint8List? photoBytes,
  }) async {
    final bytes = photoBytes ?? await XFile(filePath).readAsBytes();
    if (bytes.isEmpty) {
      throw const ApiException(
        'No encontramos la foto en el teléfono. Toma otra, por favor.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/evidences'),
    );
    request.headers.addAll(_headers());
    request.fields["bonche_reto_id"] = boncheRetoId;
    // El tipo real lo valida el servidor leyendo el archivo, no el cliente.
    request.files.add(
      http.MultipartFile.fromBytes("file", bytes, filename: "evidencia.jpg"),
    );

    final http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException(
        'La foto tardó demasiado en subir. Revisa tu conexión e inténtalo otra vez.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No pudimos conectar con el servidor. Revisa tu internet.',
      );
    }

    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode == 401) {
      clearSession();
      onUnauthorized?.call();
      throw ApiAuthException(
        _errorText(body) ?? 'Tu sesión venció. Inicia sesión de nuevo.',
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body.trim().isEmpty ? <String, dynamic>{} : jsonDecode(body);
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    }
    throw ApiException(
      _errorText(body) ?? 'No pudimos enviar tu evidencia.',
      statusCode: response.statusCode,
    );
  }

  // ------------------------------------------------- ciclo: votos y resultados

  /// GET /api/me — perfil al día. El servidor cierra aquí los retos vencidos.
  static Future<UserModel> getMe() async {
    final data = await _send(
      () => http.get(Uri.parse('$baseUrl/api/me'), headers: _headers()),
    );
    return UserModel.fromJson(_map(data, 'No pudimos actualizar tu perfil.'));
  }

  /// GET /api/bonches/{id}/challenges/status — estado propio de cada reto.
  static Future<List<ChallengeProgress>> getChallengeStatuses(
    String boncheId,
  ) async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/bonches/$boncheId/challenges/status'),
        headers: _headers(),
      ),
    );
    if (data is! List) return const <ChallengeProgress>[];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) ChallengeProgress.fromJson(item),
    ];
  }

  /// GET /api/votes/pending — evidencias de compañeros por calificar.
  static Future<List<PendingEvidence>> getPendingVotes() async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/votes/pending'),
        headers: _headers(),
      ),
    );
    final items = _map(
      data,
      'No pudimos cargar las evidencias por calificar.',
    )['items'];
    if (items is! List) return const <PendingEvidence>[];
    return [
      for (final item in items)
        if (item is Map<String, dynamic>) PendingEvidence.fromJson(item),
    ];
  }

  /// POST /api/votes — un voto por evidencia; no se puede cambiar.
  static Future<void> castVote({
    required String evidenceId,
    required bool approve,
  }) async {
    await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/votes'),
        headers: _headers(json: true),
        body: jsonEncode({"evidence_id": evidenceId, "approve": approve}),
      ),
    );
  }

  /// GET /api/rewards/unseen — resultados que el usuario aún no ha visto.
  static Future<List<RewardNotice>> getUnseenRewards() async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/rewards/unseen'),
        headers: _headers(),
      ),
    );
    if (data is! List) return const <RewardNotice>[];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) RewardNotice.fromJson(item),
    ];
  }

  /// POST /api/rewards/seen — marca resultados como vistos.
  static Future<void> markRewardsSeen(List<String> ids) async {
    if (ids.isEmpty) return;
    await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/rewards/seen'),
        headers: _headers(json: true),
        body: jsonEncode({"ids": ids}),
      ),
    );
  }

  // ---------------------------------------------------------- notificaciones

  /// GET /api/notifications — centro de notificaciones (el servidor sincroniza).
  static Future<NotificationInbox> getNotifications() async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: _headers(),
      ),
    );
    return NotificationInbox.fromJson(
      _map(data, 'No pudimos cargar tus notificaciones.'),
    );
  }

  /// POST /api/notifications/read — marca notificaciones concretas como leídas.
  static Future<void> markNotificationsRead(List<String> ids) async {
    if (ids.isEmpty) return;
    await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/notifications/read'),
        headers: _headers(json: true),
        body: jsonEncode({"ids": ids}),
      ),
    );
  }

  /// POST /api/notifications/read-all — marca todas como leídas.
  static Future<void> markAllNotificationsRead() async {
    await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/notifications/read-all'),
        headers: _headers(json: true),
        body: jsonEncode({}),
      ),
    );
  }

  // ------------------------------------------------------------------- tienda

  /// GET /api/store/items
  static Future<List<StoreItemModel>> getStoreItems() async {
    final data = await _send(
      () =>
          http.get(Uri.parse('$baseUrl/api/store/items'), headers: _headers()),
    );
    if (data is! List) return const <StoreItemModel>[];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) StoreItemModel.fromJson(item),
    ];
  }

  /// GET /api/inventory
  static Future<List<InventoryEntry>> getInventory() async {
    final data = await _send(
      () => http.get(Uri.parse('$baseUrl/api/inventory'), headers: _headers()),
    );
    if (data is! List) return const <InventoryEntry>[];
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) InventoryEntry.fromJson(item),
    ];
  }

  /// POST /api/store/purchase — el servidor descuenta las monedas.
  static Future<PurchaseReceipt> purchaseItem({
    required String itemId,
    required String requestId,
  }) async {
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/store/purchase'),
        headers: _headers(json: true),
        body: jsonEncode({"item_id": itemId, "request_id": requestId}),
      ),
    );
    return PurchaseReceipt.fromJson(
      _map(data, 'No pudimos completar la compra.'),
    );
  }

  // ----------------------------------------------------------------- bonches

  static Future<Map<String, dynamic>> createBonche({
    required String name,
    required String description,
    required String leaderId,
  }) async {
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/bonches'),
        headers: _headers(json: true),
        body: jsonEncode({
          "name": name,
          "description": description,
          "leader_id": leaderId,
        }),
      ),
    );
    return _map(data, 'Error al crear el bonche');
  }

  static Future<Map<String, dynamic>> joinBonche({
    required String inviteCode,
    required String usuarioId,
  }) async {
    final data = await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/bonches/join'),
        headers: _headers(json: true),
        body: jsonEncode({"invite_code": inviteCode, "usuario_id": usuarioId}),
      ),
    );
    return _map(data, 'Error al unirse al bonche');
  }

  static Future<List<BoncheModel>> getUserBonches(String usuarioId) async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/bonches/user/$usuarioId'),
        headers: _headers(),
      ),
    );
    if (data is! List) throw const ApiException('Error al cargar tus bonches');
    return [
      for (final item in data)
        if (item is Map<String, dynamic>) BoncheModel.fromJson(item),
    ];
  }

  static Future<void> leaveBonche(String boncheId) async {
    await _send(
      () => http.post(
        Uri.parse('$baseUrl/api/bonches/$boncheId/leave'),
        headers: _headers(json: true),
        body: '{}',
      ),
    );
  }

  static Future<void> deleteBonche(String boncheId) async {
    await _send(
      () => http.delete(
        Uri.parse('$baseUrl/api/bonches/$boncheId'),
        headers: _headers(),
      ),
    );
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
    final data = await _send(
      () => http.put(
        Uri.parse('$baseUrl/api/bonches/$boncheId/config'),
        headers: _headers(json: true),
        body: jsonEncode({
          "user_id": userId,
          "name": name,
          "challenges_per_day": challengesPerDay,
          "window_minutes": windowMinutes,
          "times": times,
          "tz_offset": tzOffset,
        }),
      ),
    );
    return _map(data, 'Error al guardar la configuración');
  }

  // ----------------------------------------------------------------- ranking

  // ----------------------------------------------------------------- interno

  /// GET /api/bonches/{id}/ranking?period=weekly|monthly (privado).
  static Future<Map<String, dynamic>> getBoncheRanking(
    String boncheId,
    String period,
  ) async {
    final data = await _send(
      () => http.get(
        Uri.parse('$baseUrl/api/bonches/$boncheId/ranking?period=$period'),
        headers: _headers(),
      ),
    );
    return _map(data, 'No pudimos cargar el ranking.');
  }

  static Map<String, dynamic> _map(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) return data;
    throw ApiException(fallback);
  }

  /// Texto legible de una respuesta de error (`detail` de FastAPI incluido).
  static String? _errorText(String body) {
    final raw = body.trim();
    if (raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is Map) {
        final detail = data['detail'];
        if (detail is String && detail.trim().isNotEmpty) return detail.trim();
        if (detail is List) {
          for (final item in detail) {
            if (item is Map) {
              final msg = item['msg'];
              if (msg is String && msg.trim().isNotEmpty) return msg.trim();
            }
          }
        }
        final message = data['message'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty)
          return message.trim();
      }
    } catch (_) {
      // Respuesta que no es JSON: se usa tal cual si es corta.
    }
    return raw.length <= 200 ? raw : null;
  }
}
