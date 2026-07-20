// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:commis/ui/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';

void main() {
  test('Generate prompt and save to a file.', () {
    final promptBuilder = PromptBuilder.chat(
      catalog: commisCatalog,
      systemPromptFragments: [],
    );

    File(
      'catalog_prompt.txt',
    ).writeAsStringSync(promptBuilder.systemPromptJoined());
  });
}
