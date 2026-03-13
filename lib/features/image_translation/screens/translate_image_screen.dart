import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../controllers/translation_controller.dart';
import '../widgets/translation_painter.dart';

class TranslateImageScreen extends StatelessWidget {
  const TranslateImageScreen({super.key});

  Future<File?> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;

    return File(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TranslationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Translation"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (value) async {
              final controller = context.read<TranslationController>();

              if (value == "zh_en") {
                await controller.changeLanguage("zh", "en");
              }

              if (value == "en_zh") {
                await controller.changeLanguage("en", "zh");
              }

              if (value == "zh_km") {
                await controller.changeLanguage("zh", "km");
              }

              if (value == "en_km") {
                await controller.changeLanguage("en", "km");
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "zh_en", child: Text("Chinese → English")),

              PopupMenuItem(value: "en_zh", child: Text("English → Chinese")),

              PopupMenuItem(value: "zh_km", child: Text("Chinese → Khmer")),

              PopupMenuItem(value: "en_km", child: Text("English → Khmer")),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = context.read<TranslationController>();

          final file = await pickImage();

          if (file != null) {
            controller.translateImage(file);
          }
        },
        child: const Icon(Icons.image),
      ),
      body: Center(
        child: controller.image == null
            ? const Text("Pick an image")
            : LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: controller.overlays.isNotEmpty
                          ? controller.overlays.first.imageSize.width
                          : constraints.maxWidth,
                      height: controller.overlays.isNotEmpty
                          ? controller.overlays.first.imageSize.height
                          : constraints.maxHeight,
                      child: Stack(
                        children: [
                          Image.file(controller.image!, fit: BoxFit.fill),

                          CustomPaint(
                            size: Size(
                              controller.overlays.isNotEmpty
                                  ? controller.overlays.first.imageSize.width
                                  : constraints.maxWidth,
                              controller.overlays.isNotEmpty
                                  ? controller.overlays.first.imageSize.height
                                  : constraints.maxHeight,
                            ),
                            painter: TranslationPainter(controller.overlays),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
