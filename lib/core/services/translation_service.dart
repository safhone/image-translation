import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  OnDeviceTranslator? _translator;

  Future<void> initMLKit(String source, String target) async {
    final modelManager = OnDeviceTranslatorModelManager();

    await modelManager.downloadModel(source);
    await modelManager.downloadModel(target);

    TranslateLanguage src = source == "zh"
        ? TranslateLanguage.chinese
        : TranslateLanguage.english;

    TranslateLanguage tgt = target == "zh"
        ? TranslateLanguage.chinese
        : TranslateLanguage.english;

    _translator?.close();

    _translator = OnDeviceTranslator(sourceLanguage: src, targetLanguage: tgt);
  }

  Future<List<String>> translateBatch(
    List<String> texts,
    String source,
    String target,
  ) async {
    /// Khmer translation → API
    if (source == "km" || target == "km") {
      return await _translateBatchAPI(texts, source, target);
    }

    /// MLKit offline
    await initMLKit(source, target);

    List<String> results = [];

    for (var text in texts) {
      final translated = await _translator!.translateText(text);
      results.add(translated);
    }

    return results;
  }

  Future<List<String>> _translateBatchAPI(
    List<String> texts,
    String source,
    String target,
  ) async {
    const apiKey = "AIzaSyCldJS5v_vKiqBEFVBDqYMA2Nxf7xthWyc";

    /// unique separator unlikely to appear in text
    const separator = "|||SEP|||";

    final joinedText = texts.join(separator);

    final response = await http.post(
      Uri.parse(
        "https://translation.googleapis.com/language/translate/v2?key=$apiKey",
      ),
      body: {
        "q": joinedText,
        "source": source,
        "target": target,
        "format": "text",
      },
    );

    final data = jsonDecode(response.body);

    final translated = data["data"]["translations"][0]["translatedText"];

    return translated.split(separator);
  }
}
