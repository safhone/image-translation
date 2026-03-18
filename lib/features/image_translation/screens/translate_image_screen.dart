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

              if (value == "km_en") {
                await controller.changeLanguage("km", "en");
              }

              if (value == "km_zh") {
                await controller.changeLanguage("km", "zh");
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "zh_en", child: Text("Chinese → English")),

              PopupMenuItem(value: "en_zh", child: Text("English → Chinese")),

              PopupMenuItem(value: "zh_km", child: Text("Chinese → Khmer")),

              PopupMenuItem(value: "en_km", child: Text("English → Khmer")),

              PopupMenuItem(value: "km_en", child: Text("Khmer → English")),

              PopupMenuItem(value: "km_zh", child: Text("Khmer → Chinese")),
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
      body: Stack(
        children: [
          Center(
            child: controller.image == null
                ? const Text("Pick an image")
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: controller.overlays.isEmpty
                            ? Image.file(controller.image!)
                            : AspectRatio(
                                aspectRatio:
                                    controller.overlays.first.imageSize.width /
                                    controller.overlays.first.imageSize.height,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        controller.image!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: TranslationPainter(
                                          controller.overlays,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
          ),
          if (controller.loading)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
