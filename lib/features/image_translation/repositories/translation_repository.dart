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

    List<TextOverlay> overlays = [];

    for (var block in result.blocks) {
      for (var line in block.lines) {
        final translated = await translationService.translate(
          text: line.text,
          source: source,
          target: target,
        );

        overlays.add(
          TextOverlay(
            translated: translated,
            rect: line.boundingBox,
            imageSize: imageSize,
          ),
        );
      }
    }

    return overlays;
  }

  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();

    final decoded = await decodeImageFromList(bytes);

    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
