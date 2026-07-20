// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import '../theme.dart';

class SurfaceCard extends StatelessWidget {
  final SurfaceContext surfaceContext;

  const SurfaceCard({
    super.key,
    required this.surfaceContext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Card(
        color: CommisColors.surfaceLevel1,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(
            color: CommisColors.borderLowContrast,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Surface(
            surfaceContext: surfaceContext,
          ),
        ),
      ),
    );
  }
}
