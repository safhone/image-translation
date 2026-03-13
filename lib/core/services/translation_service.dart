import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;

  Future<void> initMLKit(String source, String target) async {
    final modelManager = OnDeviceTranslatorModelManager();

    await modelManager.downloadModel(source);
    await modelManager.downloadModel(target);

    TranslateLanguage src;
    TranslateLanguage tgt;

    if (source == "zh") {
      src = TranslateLanguage.chinese;
    } else {
      src = TranslateLanguage.english;
    }

    if (target == "zh") {
      tgt = TranslateLanguage.chinese;
    } else {
      tgt = TranslateLanguage.english;
    }

    _translator?.close();

    _translator = OnDeviceTranslator(sourceLanguage: src, targetLanguage: tgt);
  }

  Future<String> translate({
    required String text,
    required String source,
    required String target,
  }) async {
    /// Khmer → Google API
    if (source == "km" || target == "km") {
      return await _translateAPI(text, source, target);
    }

    /// Initialize correct translator
    await initMLKit(source, target);

    return await _translator!.translateText(text);
  }

  Future<String> _translateAPI(
    String text,
    String source,
    String target,
  ) async {
    const apiKey = "";

    final response = await http.post(
      Uri.parse(
        "https://translation.googleapis.com/language/translate/v2?key=$apiKey",
      ),
      body: {"q": text, "source": source, "target": target, "format": "text"},
    );

    final data = jsonDecode(response.body);

    return data["data"]["translations"][0]["translatedText"];
  }
}
