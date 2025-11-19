// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:developer';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/app_state.dart';
import '../shared/firebaseai_imagen_service.dart';
import './models/models.dart';

/// A service that handles all communication with the Firebase AI Gemini API
/// for the Chat Demo.
///
/// This service demonstrates how to use the `startChat()` method on a
/// `GenerativeModel` to create a persistent conversation. The `ChatSession`
/// object automatically handles the conversation history, making it easy to
/// build multi-turn chat experiences.
///
/// For more information, see the official documentation:
/// https://firebase.google.com/docs/ai-logic/chat?api=dev
class ChatService {
  final WidgetRef _ref;
  GeminiModel? _gemini;

  ChatService(this._ref, [this._gemini]);

  late ChatSession _chat;

  void init() {
    var gemini = _gemini ?? geminiModels.selectedModel;
    _chat = gemini.model.startChat();
  }

  void changeModel(String modelName) {
    _gemini = geminiModels.selectModel(modelName);
    init();
  }

  Future<ChatResponse> sendMessage(Content message) async {
    try {
      var response = await _chat.sendMessage(message);

      if (response.functionCalls.isNotEmpty) {
        return _handleFunctionCall(response.functionCalls);
      } else {
        if (response.inlineDataParts.isNotEmpty) {
          final imageBytes = response.inlineDataParts.first.bytes;
          var image = Image.memory(imageBytes);
          return ChatResponse(text: response.text, image: image);
        }

        return ChatResponse(text: response.text);
      }
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  Future<ChatResponse> _handleFunctionCall(
    Iterable<FunctionCall> functionCalls,
  ) async {
    var functionCall = functionCalls.first;
    log("Gemini made a function call: ${functionCall.name}");

    switch (functionCall.name) {
      case 'SetAppColor':
        final response = await _handleSetAppColor(functionCall);
        return ChatResponse(text: response.text);
      case 'GenerateImage':
        return await _handleGenerateImage(functionCall);
      default:
        final response = await _chat.sendMessage(
          Content.text(
            'Function Call name was not found! Please try another function call.',
          ),
        );
        return ChatResponse(text: response.text);
    }
  }

  Future<GenerateContentResponse> _handleSetAppColor(
    FunctionCall functionCall,
  ) async {
    log('Set app color!');
    int red = functionCall.args['red']! as int;
    int green = functionCall.args['green']! as int;
    int blue = functionCall.args['blue']! as int;
    var newSeedColor = Color.fromRGBO(red, green, blue, 1);
    var executedFunctionCall = _ref
        .read(appStateProvider)
        .setAppColor(newSeedColor);
    return await _chat.sendMessage(Content.text(executedFunctionCall));
  }

  Future<ChatResponse> _handleGenerateImage(FunctionCall functionCall) async {
    log('Generate image!');
    String description = functionCall.args['description']! as String;
    var imageBytes = await ImageGenerationService().generateImage(description);
    var response = await _chat.sendMessage(
      Content.text(
        'Successfully generated an image of $description! Please send back a message to include with the image.',
      ),
    );
    var responseImage = Image.memory(imageBytes);
    return ChatResponse(text: response.text, image: responseImage);
  }
}
