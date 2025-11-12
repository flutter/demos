import 'package:firebase_ai/firebase_ai.dart';
import '../../../shared/function_calling/tools.dart';

var geminiModels = GeminiModels();

class GeminiModel {
  final String name;
  final String description;
  final GenerativeModel model;
  final String defaultPrompt;

  GeminiModel({
    required this.name,
    required this.description,
    required this.model,
    required this.defaultPrompt,
  });
}

class GeminiModels {
  String selectedModelName = 'gemini-2.5-flash-image';
  GeminiModel get selectedModel => models[selectedModelName]!;

  /// A map of Gemini models that can be used in the Chat Demo.
  Map<String, GeminiModel> models = {
    'gemini-2.5-flash': GeminiModel(
      name: 'gemini-2.5-flash',
      description:
          'Our thinking model that offers great, well-rounded capabilities. It\'s designed to offer a balance between price and performance.',
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
        tools: [
          Tool.functionDeclarations([setAppColorTool, generateImageTool]),
        ],
        generationConfig: GenerationConfig(
          responseModalities: [ResponseModalities.text],
        ),
      ),
      defaultPrompt: 'Hey Gemini! Can you set the app color to purple?',
    ),
    'gemini-2.5-flash-image': GeminiModel(
      name: 'gemini-2.5-flash-image',
      description:
          'Our standard Flash model upgraded for rapid creative workflows with image generation and conversational, multi-turn editing capabilities.',
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash-image',
        generationConfig: GenerationConfig(
          responseModalities: [
            ResponseModalities.text,
            ResponseModalities.image,
          ],
        ),
      ),
      defaultPrompt:
          'Hot air balloons rising over the San Francisco Bay at golden hour '
          'with a view of the Golden Gate Bridge. Make it anime style.',
    ),
    'gemini-2.5-pro': GeminiModel(
      name: 'gemini-2.5-pro',
      description:
          'Our state-of-the-art thinking model, capable of reasoning over complex problems in code, math, and STEM, as well as analyzing large datasets, codebases, and documents using long context.',
      model: FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-pro',
        tools: [
          Tool.functionDeclarations([setAppColorTool, generateImageTool]),
        ],
        generationConfig: GenerationConfig(
          responseModalities: [ResponseModalities.text],
        ),
      ),
      defaultPrompt: 'If you roll 2 dices, what are the odds that you roll "7" ?',
    ),
  };

  GeminiModel selectModel(String modelName) {
    if (models.containsKey(modelName)) {
      selectedModelName = modelName;
    } else {
      throw Exception('Model $modelName not found');
    }
    return selectedModel;
  }

  List<String> get modelNames => models.keys.toList();
  GeminiModel operator [](String name) => models[name]!;
}
