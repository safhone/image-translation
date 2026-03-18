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

    for (final overlay in overlays) {
      final rect = Rect.fromLTRB(
        overlay.rect.left * scaleX,
        overlay.rect.top * scaleY,
        overlay.rect.right * scaleX,
        overlay.rect.bottom * scaleY,
      );

      final expandedRect = rect.inflate(6);

      if (expandedRect.width <= 2 ||
          expandedRect.height <= 2 ||
          !expandedRect.width.isFinite ||
          !expandedRect.height.isFinite) {
        debugPrint("expandedRect: $expandedRect");
        continue;
      }

      _drawTextBox(canvas, expandedRect, overlay.translated);
    }
  }

  void _drawTextBox(Canvas canvas, Rect rect, String text) {
    if (text.trim().isEmpty) return;

    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    final paint = Paint()..color = Colors.white.withValues(alpha: 0.9);

    canvas.drawShadow(
      Path()..addRRect(rRect),
      Colors.black.withValues(alpha: 0.2),
      4,
      false,
    );

    canvas.drawRRect(rRect, paint);

    final paddedRect = Rect.fromLTRB(
      rect.left + 4,
      rect.top + 4,
      rect.right - 4,
      rect.bottom - 4,
    );

    if (paddedRect.width <= 2 ||
        paddedRect.height <= 2 ||
        !paddedRect.width.isFinite ||
        !paddedRect.height.isFinite) {
      debugPrint("paddedRect: $paddedRect");
      return;
    }

    final safeWidth = paddedRect.width.isFinite && paddedRect.width > 0
        ? paddedRect.width
        : 10;

    double minFont = 8;
    double maxFont = paddedRect.height.clamp(10, 40);
    double best = minFont;

    while ((maxFont - minFont) > 1) {
      double mid = (maxFont + minFont) / 2;

      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black,
            fontSize: mid,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      tp.layout(maxWidth: safeWidth.toDouble());

      if (tp.height <= paddedRect.height) {
        best = mid;
        minFont = mid;
      } else {
        maxFont = mid;
      }
    }

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black,
          fontSize: best,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    painter.layout(maxWidth: safeWidth.toDouble());

    final offset = Offset(
      paddedRect.left + (paddedRect.width - painter.width) / 2,
      paddedRect.top + (paddedRect.height - painter.height) / 2,
    );

    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
