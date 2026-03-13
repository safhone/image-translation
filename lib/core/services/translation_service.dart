import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  late final OnDeviceTranslator _translator;

  Future<void> init() async {
    final modelManager = OnDeviceTranslatorModelManager();

    // Download models if not available
    await modelManager.downloadModel('zh');
    await modelManager.downloadModel('en');

    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.chinese,
      targetLanguage: TranslateLanguage.english,
    );
  }

  Future<String> translate(String text) async {
    return await _translator.translateText(text);
  }

  void dispose() {
    _translator.close();
  }
}
