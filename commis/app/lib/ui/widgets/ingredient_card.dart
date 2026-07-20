// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models.dart';
import '../theme.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient item;

  final bool isEven;

  const IngredientCard({required this.item, this.isEven = false, super.key});

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/ingredients/200/${item.id}.png';
    final cardColor = isEven
        ? Color.alphaBlend(
            Colors.white.withAlpha(12),
            CommisColors.surfaceLevel1,
          )
        : CommisColors.surfaceLevel1;

    return Card(
      color: cardColor,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(
          color: CommisColors.borderLowContrast,
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image Asset with Fallback
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: CommisColors.borderLowContrast),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.0),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: CommisColors.surfaceLevel2,
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: CommisColors.goldAccentDim,
                          size: 28.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.outfit(
                      color: CommisColors.textPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.description,
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: CommisColors.surfaceLevel2,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'Unit: ${item.unit}',
                          style: GoogleFonts.sourceSans3(
                            color: CommisColors.textSecondary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
