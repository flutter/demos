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

import 'package:flutter/material.dart';
import 'dart:developer' as dev;
import '../../shared/ui/app_frame.dart';
import '../../shared/ui/app_spacing.dart';
import './models/attachment.dart';
import './firebaseai_multimodal_service.dart';
import './ui_components/ui_components.dart';
import 'utilities/file_picker_utility.dart';

class MultimodalDemo extends StatefulWidget {
  const MultimodalDemo({super.key});

  @override
  State<MultimodalDemo> createState() => _MultimodalDemoState();
}

class _MultimodalDemoState extends State<MultimodalDemo> {
  // Service for interacting with the Gemini API.
  final _multimodalService = MultimodalService();

  // UI State
  bool _loading = false;
  TextEditingController promptController = TextEditingController(
    text: 'Please analyze this file and explain it to me like I\'m 5.',
  );
  Attachment? _attachment;
  ExpansibleController promptTileController = ExpansibleController();
  String? outputText;

  void _pickFile() async {
    final newAttachment = await FilePickerService().pickFile(context);
    if (newAttachment != null) {
      setState(() {
        _attachment = newAttachment;
      });
    }
  }

  void askGemini() async {
    setState(() {
      _loading = true;
    });

    var attachment = _attachment;
    var prompt = promptController.text.trim();

    if (attachment == null || prompt.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    promptTileController.collapse();

    try {
      outputText = await _multimodalService.generateContent(prompt, attachment);
    } catch (e) {
      dev.log(e.toString());
      outputText = 'Oops, sorry there was an error processing that file.';
      promptTileController.expand();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: AppFrame(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s8,
              0,
              AppSpacing.s8,
              AppSpacing.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox.square(dimension: AppSpacing.s16),
                FilePromptInput(
                  promptController: promptController,
                  tileController: promptTileController,
                  loading: _loading,
                  attachment: _attachment,
                  askGemini: askGemini,
                  onPickFilePressed: _pickFile,
                  onAttachmentChanged: (attachment) {
                    setState(() {
                      _attachment = attachment;
                    });
                  },
                ),
                OutputDisplay(loading: _loading, outputText: outputText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
