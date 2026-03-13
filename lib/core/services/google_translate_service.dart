import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleTranslateService {
  final String apiKey = "YOUR_GOOGLE_API_KEY";

  Future<String> translateToKhmer(String text) async {
    final response = await http.post(
      Uri.parse("https://translation.googleapis.com/language/translate/v2"),
      body: {"q": text, "target": "km", "key": apiKey},
    );

    final data = jsonDecode(response.body);

    return data["data"]["translations"][0]["translatedText"];
  }
}
