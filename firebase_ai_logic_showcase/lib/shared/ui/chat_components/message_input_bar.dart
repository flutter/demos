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
import '../../../shared/ui/app_spacing.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController textController;
  final bool loading;
  final void Function(String) sendMessage;
  final VoidCallback onPickImagePressed;

  const MessageInputBar({
    super.key,
    required this.textController,
    required this.loading,
    required this.sendMessage,
    required this.onPickImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.outline.withAlpha(125),
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0,
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: onPickImagePressed,
                  icon: const Icon(Icons.image),
                ),
                const SizedBox.square(dimension: AppSpacing.s8),
                Expanded(
                  child: TextField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: textController,
                    minLines: 2,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0),
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppSpacing.s8),
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                    ),
                  ),
                ),
                const SizedBox.square(dimension: AppSpacing.s16),
                IconButton.filled(
                  onPressed: !loading
                      ? () => sendMessage(textController.text)
                      : null,
                  icon: const Icon(Icons.arrow_upward_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
