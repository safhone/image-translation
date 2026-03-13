import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  Future<RecognizedText> detectText(File image) async {
    final inputImage = InputImage.fromFile(image);

    final recognizer = TextRecognizer(script: TextRecognitionScript.chinese);

    final result = await recognizer.processImage(inputImage);

    recognizer.close();

    return result;
  }
}
