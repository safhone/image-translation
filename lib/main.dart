import 'package:flutter/material.dart';
import 'package:imagetranslation/features/image_translation/controllers/translation_controller.dart';
import 'package:imagetranslation/features/image_translation/repositories/translation_repository.dart';
import 'package:imagetranslation/features/image_translation/screens/translate_image_screen.dart';
import 'package:provider/provider.dart';

import 'core/services/ocr_service.dart';
import 'core/services/translation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final translationService = TranslationService();

  await translationService.init();

  final repository = TranslationRepository(OCRService(), translationService);

  runApp(MyApp(repository));
}

class MyApp extends StatelessWidget {
  final TranslationRepository repository;

  const MyApp(this.repository, {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranslationController(repository),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TranslateImageScreen(),
      ),
    );
  }
}
