import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imagetranslation/model/text_overlay.dart';

import '../repositories/translation_repository.dart';

class TranslationController extends ChangeNotifier {
  final TranslationRepository repository;

  TranslationController(this.repository);

  File? image;

  List<TextOverlay> overlays = [];

  bool loading = false;

  Future<void> translateImage(File file) async {
    image = file;

    loading = true;
    notifyListeners();

    overlays = await repository.processImage(file);

    loading = false;
    notifyListeners();
  }
}
