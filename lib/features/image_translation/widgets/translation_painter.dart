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

      // Background box
      final bg = Paint()..color = Colors.white.withValues(alpha: 0.9);

      canvas.drawRect(rect, bg);

      // Dynamic font size based on box height
      double fontSize = rect.height * 0.6;

      final textPainter = TextPainter(
        text: TextSpan(
          text: overlay.translated,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 3,
      );

      textPainter.layout(maxWidth: rect.width);

      // If text is too big, shrink it
      while (textPainter.height > rect.height && fontSize > 6) {
        fontSize -= 1;
        textPainter.text = TextSpan(
          text: overlay.translated,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        );
        textPainter.layout(maxWidth: rect.width);
      }

      textPainter.paint(canvas, Offset(rect.left, rect.top));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
