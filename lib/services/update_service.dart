import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AppUpdate {
  final int version;
  final String downloadUrl;

  const AppUpdate({required this.version, required this.downloadUrl});
}

class UpdateService {
  static const _channel = MethodChannel('larecocha/updates');

  static const _repository = 'joserico3563-oss/challenge_us';

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<AppUpdate?> check() async {
    if (!supported) return null;

    try {
      final installed = await _channel.invokeMethod<int>('versionCode');

      if (installed == null) return null;

      final response = await http
          .get(
            Uri.parse(
              'https://api.github.com/repos/$_repository/releases/latest',
            ),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final tag = data['tag_name'] as String? ?? '';
      final match = RegExp(r'^apk-(\d+)$').firstMatch(tag);

      if (match == null) return null;

      final version = int.parse(match.group(1)!);

      if (version <= installed) return null;

      final assets = data['assets'] as List<dynamic>? ?? [];

      for (final asset in assets) {
        if (asset['name'] != 'La_Recocha.apk') continue;

        final url = asset['browser_download_url'] as String?;

        if (url == null) continue;

        final expected =
            'https://github.com/$_repository/releases/download/$tag/La_Recocha.apk';

        if (url != expected) continue;

        return AppUpdate(version: version, downloadUrl: url);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> download(AppUpdate update) async {
    if (!supported) return false;

    try {
      return await _channel.invokeMethod<bool>('downloadUpdate', {
            'url': update.downloadUrl,
            'version': update.version,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }
}
