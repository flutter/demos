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
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import './message_widget.dart';

class MessageBubble extends StatelessWidget {
  final MessageData message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromUser = message.fromUser ?? false;
    return ListTile(
      minVerticalPadding: 4,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      contentPadding: isFromUser
          ? EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 8)
          : EdgeInsets.only(left: 8, top: 8, right: 16, bottom: 8),
      leading: (!isFromUser)
          ? CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Image.asset('assets/gemini-logo.png'),
            )
          : null,
      title: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFromUser
              ? Theme.of(context).colorScheme.surfaceBright
              : Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            if (message.text != null)
              Align(
                alignment: Alignment.centerLeft,
                child: MarkdownBody(data: message.text!),
              ),
            if (message.image != null)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: ClipRSuperellipse(
                  borderRadius: BorderRadius.circular(16),
                  child: message.image!,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY().scaleXY();
  }
}
