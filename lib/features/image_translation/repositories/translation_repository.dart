import 'dart:io';
import 'package:flutter/foundation.dart';
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

    final rawItems = await ocrService.detectText(image);

    List<OCRItem> ocrItems;

    if (_isUI(rawItems)) {
      if (kDebugMode) {
        print("UI (no merge)");
      }
      ocrItems = rawItems;
    } else {
      if (kDebugMode) {
        print("PARAGRAPH (merge)");
      }
      final mergedLine = _mergeNearby(rawItems);
      ocrItems = _mergeParagraphs(mergedLine);
    }

    List<TextOverlay> overlays = [];

    for (final item in ocrItems) {
      final text = item.text.trim();

      if (text.isEmpty || text.length < 2) continue;

      final translated = await translationService.translate(
        text: text,
        source: source,
        target: target,
      );

      final v = item.vertices;

      final rect = Rect.fromLTRB(
        (v[0]["x"] ?? 0).toDouble(),
        (v[0]["y"] ?? 0).toDouble(),
        (v[2]["x"] ?? 0).toDouble(),
        (v[2]["y"] ?? 0).toDouble(),
      );

      overlays.add(
        TextOverlay(translated: translated, rect: rect, imageSize: imageSize),
      );
    }

    return overlays;
  }

  bool _isUI(List<OCRItem> items) {
    if (items.length > 20) return true;

    int smallBoxes = 0;

    for (var item in items) {
      double height =
          (item.vertices[2]["y"] ?? 0).toDouble() -
          (item.vertices[0]["y"] ?? 0).toDouble();

      if (height < 40) smallBoxes++;
    }

    return smallBoxes > items.length * 0.6;
  }

  List<OCRItem> _mergeNearby(List<OCRItem> items) {
    if (items.isEmpty) return [];

    items.sort((a, b) {
      double ay = (a.vertices[0]["y"] ?? 0).toDouble();
      double by = (b.vertices[0]["y"] ?? 0).toDouble();

      if ((ay - by).abs() > 10) return ay.compareTo(by);

      double ax = (a.vertices[0]["x"] ?? 0).toDouble();
      double bx = (b.vertices[0]["x"] ?? 0).toDouble();

      return ax.compareTo(bx);
    });

    List<OCRItem> merged = [];
    OCRItem current = items.first;

    for (int i = 1; i < items.length; i++) {
      final next = items[i];

      double currentTop = (current.vertices[0]["y"] ?? 0).toDouble();
      double nextTop = (next.vertices[0]["y"] ?? 0).toDouble();

      double currentHeight =
          (current.vertices[2]["y"] ?? 0).toDouble() - currentTop;

      double yThreshold = currentHeight * 0.5;

      bool sameLine = (nextTop - currentTop).abs() < yThreshold;

      double currentRight = (current.vertices[2]["x"] ?? 0).toDouble();
      double nextLeft = (next.vertices[0]["x"] ?? 0).toDouble();

      double gap = nextLeft - currentRight;

      bool closeEnough = gap < currentHeight * 2;

      if (sameLine && closeEnough) {
        current = OCRItem(
          text: "${current.text} ${next.text}",
          vertices: _mergeRect(current.vertices, next.vertices),
        );
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  List<OCRItem> _mergeParagraphs(List<OCRItem> items) {
    if (items.isEmpty) return [];

    List<OCRItem> merged = [];
    OCRItem current = items.first;

    for (int i = 1; i < items.length; i++) {
      final next = items[i];

      double currentBottom = (current.vertices[2]["y"] ?? 0).toDouble();
      double nextTop = (next.vertices[0]["y"] ?? 0).toDouble();

      double gap = nextTop - currentBottom;

      double height =
          currentBottom - (current.vertices[0]["y"] ?? 0).toDouble();

      if (gap < height * 1.2) {
        current = OCRItem(
          text: "${current.text}\n${next.text}",
          vertices: _mergeRect(current.vertices, next.vertices),
        );
      } else {
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }

  List<dynamic> _mergeRect(List v1, List v2) {
    double left = (v1[0]["x"] ?? 0).toDouble();
    double top = (v1[0]["y"] ?? 0).toDouble();
    double right = (v1[2]["x"] ?? 0).toDouble();
    double bottom = (v1[2]["y"] ?? 0).toDouble();

    double left2 = (v2[0]["x"] ?? 0).toDouble();
    double top2 = (v2[0]["y"] ?? 0).toDouble();
    double right2 = (v2[2]["x"] ?? 0).toDouble();
    double bottom2 = (v2[2]["y"] ?? 0).toDouble();

    return [
      {"x": left < left2 ? left : left2, "y": top < top2 ? top : top2},
      {"x": right > right2 ? right : right2, "y": top < top2 ? top : top2},
      {
        "x": right > right2 ? right : right2,
        "y": bottom > bottom2 ? bottom : bottom2,
      },
      {
        "x": left < left2 ? left : left2,
        "y": bottom > bottom2 ? bottom : bottom2,
      },
    ];
  }

  Future<Size> _getImageSize(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = await decodeImageFromList(bytes);

    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}
