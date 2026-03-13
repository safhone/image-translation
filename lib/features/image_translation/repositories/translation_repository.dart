import 'dart:io';
import 'package:flutter/material.dart';
import 'package:imagetranslation/core/services/ocr_service.dart';
import 'package:imagetranslation/core/services/translation_service.dart';
import 'package:imagetranslation/model/text_overlay.dart';

class TranslationRepository {
  final OCRService ocrService;
  final TranslationService translationService;

  TranslationRepository(this.ocrService, this.translationService);

  Future<List<TextOverlay>> processImage(
    File image,
    String source,
    String target,
  ) async {
    final imageSize = await _getImageSize(image);

    final result = await ocrService.detectText(image);

    List<String> texts = [];
    List<Rect> rects = [];

    for (var block in result.blocks) {
      for (var line in block.lines) {
        texts.add(line.text);
        rects.add(line.boundingBox);
      }
    }

    final translatedTexts = await translationService.translateBatch(
      texts,
      source,
      target,
    );

    List<TextOverlay> overlays = [];

    for (int i = 0; i < translatedTexts.length; i++) {
      overlays.add(
        TextOverlay(
          translated: translatedTexts[i],
          rect: rects[i],
          imageSize: imageSize,
        ),
      );
    }

    return overlays;
  }

  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();

    final decoded = await decodeImageFromList(bytes);

    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
