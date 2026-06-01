import "dart:io";

import "package:platform_ocr/platform_ocr.dart" as native_ocr;
import "package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart";

import "../../domain/repositories/ocr_repository.dart";

class OcrRepositoryImpl implements OcrRepository {
  @override
  Future<String> extractTextFromImage(String imagePath) async {
    if (Platform.isWindows) {
      final result = await native_ocr.recognizeText(
        native_ocr.OcrSource.file(File(imagePath)),
      );
      return result.text;
    }

    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } finally {
      await textRecognizer.close();
    }
  }
}
