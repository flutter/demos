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

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../shared/ui/app_spacing.dart';

class AttachmentPreview extends StatelessWidget {
  final Uint8List? attachment;

  const AttachmentPreview({super.key, this.attachment});

  @override
  Widget build(BuildContext context) {
    return attachment != null
        ? Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s16),
                child: Container(
                  height: 95,
                  width: 95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.s8),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: MemoryImage(attachment!),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container();
  }
}
