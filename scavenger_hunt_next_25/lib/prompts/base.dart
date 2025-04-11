import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/foundation.dart';

abstract class Prompt<R> {
  String? get systemPrompt => null;

  Schema? get schema => null;

  String get prompt;

  String get modelName => 'gemini-2.0-flash';

  GenerativeModel get model => FirebaseVertexAI.instance.generativeModel(
    model: modelName,
    generationConfig: GenerationConfig(
      responseMimeType: schema != null ? 'application/json' : null,
      responseSchema: schema,
    ),
    systemInstruction: systemPrompt != null ? Content.text(systemPrompt!) : null,
  );

  R parse(String value);
  Future<R> call() async {
    final res = await model.generateContent([Content.text(prompt)]);
    final str = res.text ?? '';
    debugPrint(str);
    return parse(str);
  }
}

abstract class ImagePrompt {
  int get length => 1;

  String get prompt;

  String get modelName => 'imagen-3.0-generate-002';

  ImagenModel get model => FirebaseVertexAI.instance.imagenModel(
    model: modelName,
    generationConfig: ImagenGenerationConfig(numberOfImages: length),
  );

  Future<List<ImagenInlineImage>> call() async {
    final res = await model.generateImages(prompt);
    return res.images;
  }
}
