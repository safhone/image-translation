import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:imagetranslation/core/config/app_config.dart';

class OCRItem {
  final String text;
  final List<dynamic> vertices;

  OCRItem({required this.text, required this.vertices});
}

class OCRService {
  final String apiKey = AppConfig.googleApiKey;

  Future<List<OCRItem>> detectText(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse("https://vision.googleapis.com/v1/images:annotate?key=$apiKey"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "requests": [
          {
            "image": {"content": base64Image},
            "features": [
              {"type": "DOCUMENT_TEXT_DETECTION"},
            ],
          },
        ],
      }),
    );

    final data = jsonDecode(response.body);

    final pages = data["responses"][0]["fullTextAnnotation"]["pages"] ?? [];

    List<OCRItem> items = [];

    for (var page in pages) {
      for (var block in page["blocks"]) {
        for (var paragraph in block["paragraphs"]) {
          String text = "";

          for (var word in paragraph["words"]) {
            for (var symbol in word["symbols"]) {
              text += symbol["text"];
            }
            text += " ";
          }

          final vertices = paragraph["boundingBox"]["vertices"];

          items.add(OCRItem(text: text.trim(), vertices: vertices));
        }
      }
    }

    return items;
  }
}
