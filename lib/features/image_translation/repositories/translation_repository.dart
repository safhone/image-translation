import 'dart:io';
import 'package:flutter/material.dart';

import 'package:imagetranslation/core/services/ocr_service.dart';
import 'package:imagetranslation/core/services/translation_service.dart';
import 'package:imagetranslation/model/text_overlay.dart';

class TranslationRepository {
  final OCRService ocrService;
  final TranslationService translationService;

  TranslationRepository(this.ocrService, this.translationService);

  Future<List<TextOverlay>> processImage(File image) async {
    print("===== START OCR PROCESS =====");

    final imageSize = await _getImageSize(image);

    final result = await ocrService.detectText(image);

    print("Detected blocks: ${result.blocks.length}");

    List<Future<TextOverlay>> tasks = [];

    for (var block in result.blocks) {
      for (var line in block.lines) {
        // Debug OCR output
        print("OCR TEXT: ${line.text}");

        tasks.add(_translateLine(line.text, line.boundingBox, imageSize));
      }
    }

    return await Future.wait(tasks);
  }

  Future<TextOverlay> _translateLine(
    String text,
    Rect rect,
    Size imageSize,
  ) async {
    print("Translating: $text");

    final translated = await translationService.translate(text);

    print("Translated result: $translated");

    return TextOverlay(
      translated: translated,
      rect: rect,
      imageSize: imageSize,
    );
  }

  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();

    final decoded = await decodeImageFromList(bytes);

    print("Image size: ${decoded.width} x ${decoded.height}");

    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
