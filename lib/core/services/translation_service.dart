import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:imagetranslation/core/config/app_config.dart';

class TranslationService {
  OnDeviceTranslator? _translator;

  String? _currentSource;
  String? _currentTarget;

  final String _apiKey = AppConfig.googleApiKey;

  final Map<String, String> _cache = {};

  Future<String> translate({
    required String text,
    required String source,
    required String target,
  }) async {
    if (kDebugMode) {
      print("---- TRANSLATE START ----");
      print("TEXT: $text");
      print("SOURCE: $source → TARGET: $target");
    }

    if (text.trim().isEmpty) return "";

    final key = "$source|$target|$text";

    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    try {
      String result;

      if (source == "km") {
        result = await _translateAPI(text, source, target);
      } else {
        await _initMLKit(source, target);
        result = await _translator!.translateText(text);
      }

      _cache[key] = result;

      if (kDebugMode) {
        print("TRANSLATED: $result");
        print("---- TRANSLATE END ----");
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print("Translation error: $e");
      }

      return text;
    }
  }

  Future<String> _translateAPI(
    String text,
    String source,
    String target,
  ) async {
    if (kDebugMode) {
      print("GOOGLE API REQUEST: $text");
    }

    final response = await http.post(
      Uri.parse(
        "https://translation.googleapis.com/language/translate/v2?key=$_apiKey",
      ),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({
        "q": text,
        "source": source,
        "target": target,
        "format": "text",
      }),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
      }
      final data = jsonDecode(response.body);
      return data["data"]["translations"][0]["translatedText"];
    } else {
      return text;
    }
  }

  Future<void> _initMLKit(String source, String target) async {
    if (_currentSource == source && _currentTarget == target) return;

    final manager = OnDeviceTranslatorModelManager();

    await manager.downloadModel(source);
    await manager.downloadModel(target);

    _translator?.close();

    _translator = OnDeviceTranslator(
      sourceLanguage: _map(source),
      targetLanguage: _map(target),
    );

    _currentSource = source;
    _currentTarget = target;
  }

  TranslateLanguage _map(String code) {
    switch (code) {
      case "en":
        return TranslateLanguage.english;
      case "zh":
        return TranslateLanguage.chinese;
      default:
        return TranslateLanguage.english;
    }
  }
}
