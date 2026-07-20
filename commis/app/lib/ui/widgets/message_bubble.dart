// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isUser
              ? CommisColors.goldAccent.withAlpha(50)
              : CommisColors.surfaceLevel1,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: Radius.circular(isUser ? 16.0 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16.0),
          ),
          border: Border.all(
            color: isUser
                ? CommisColors.goldAccent.withAlpha(100)
                : CommisColors.borderLowContrast,
          ),
        ),
        child: MarkdownBody(
          data: text,
          // styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
          //   p: GoogleFonts.sourceSans3(
          //     color: CommisColors.textPrimary,
          //     fontSize: 15.0,
          //     height: 1.4,
          //   ),
          //   strong: GoogleFonts.sourceSans3(
          //     color: CommisColors.textPrimary,
          //     fontWeight: FontWeight.bold,
          //     fontSize: 15.0,
          //   ),
          //   h1: GoogleFonts.outfit(
          //     color: CommisColors.textPrimary,
          //     fontWeight: FontWeight.bold,
          //     fontSize: 20.0,
          //   ),
          //   h2: GoogleFonts.outfit(
          //     color: CommisColors.textPrimary,
          //     fontWeight: FontWeight.bold,
          //     fontSize: 18.0,
          //   ),
          //   h3: GoogleFonts.outfit(
          //     color: CommisColors.textPrimary,
          //     fontWeight: FontWeight.bold,
          //     fontSize: 16.0,
          //   ),
          //   listBullet: GoogleFonts.sourceSans3(
          //     color: CommisColors.textPrimary,
          //     fontSize: 15.0,
          //   ),
          //   code: GoogleFonts.jetBrainsMono(
          //     color: CommisColors.goldAccentDim,
          //     backgroundColor: Colors.transparent,
          //     fontSize: 13.0,
          //   ),
          //   codeblockDecoration: BoxDecoration(
          //     color: CommisColors.surfaceLevel2,
          //     borderRadius: BorderRadius.circular(8.0),
          //     border: Border.all(color: CommisColors.borderLowContrast),
          //   ),
          // ),
        ),
      ),
    );
  }
}
