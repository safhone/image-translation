import 'package:flutter/material.dart';
import 'package:imagetranslation/model/text_overlay.dart';

class TranslationPainter extends CustomPainter {
  final List<TextOverlay> overlays;

  TranslationPainter(this.overlays);

  @override
  void paint(Canvas canvas, Size size) {
    if (overlays.isEmpty) return;

    final imageSize = overlays.first.imageSize;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (var overlay in overlays) {
      final rect = Rect.fromLTRB(
        overlay.rect.left * scaleX,
        overlay.rect.top * scaleY,
        overlay.rect.right * scaleX,
        overlay.rect.bottom * scaleY,
      );

      /// ignore extremely small OCR boxes
      if (rect.width < 20 || rect.height < 10) continue;

      /// background
      final bg = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawRect(rect, bg);

      /// start with large font
      double fontSize = rect.height;

      TextPainter textPainter;

      while (true) {
        textPainter = TextPainter(
          text: TextSpan(
            text: overlay.translated,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              height: 1.2,
            ),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          maxLines: null,
        );

        textPainter.layout(maxWidth: rect.width);

        /// stop when text fits
        if (textPainter.height <= rect.height || fontSize < 10) {
          break;
        }

        fontSize -= 1;
      }

      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
