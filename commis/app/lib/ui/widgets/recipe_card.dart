// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models.dart';
import '../theme.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final List<Ingredient> allIngredients;

  final bool isEven;

  const RecipeCard({
    required this.recipe,
    required this.allIngredients,
    this.isEven = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/recipes/200/${recipe.id}.png';
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Image on the left, Name and Description on the right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Recipe image thumbnail
                Container(
                  width: 72.0,
                  height: 72.0,
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
                              size: 26.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Right: Name & Description column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.name,
                        style: GoogleFonts.outfit(
                          color: CommisColors.textPrimary,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        recipe.description,
                        style: GoogleFonts.sourceSans3(
                          color: CommisColors.textSecondary,
                          fontSize: 14.0,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(color: CommisColors.borderLowContrast, height: 1.0),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INGREDIENTS',
                  style: GoogleFonts.outfit(
                    color: CommisColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Per 10 Guests',
                  style: GoogleFonts.jetBrainsMono(
                    color: CommisColors.goldAccentDim,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            if (recipe.ingredients.isEmpty)
              Text(
                'No ingredients defined',
                style: GoogleFonts.sourceSans3(
                  color: CommisColors.textSecondary.withAlpha(153),
                  fontSize: 13.0,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recipe.ingredients.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 6.0),
                itemBuilder: (context, index) {
                  final ing = recipe.ingredients[index];
                  // Look up ingredient name and unit
                  final match = allIngredients
                      .cast<Ingredient?>()
                      .firstWhere(
                        (i) => i?.id == ing.itemId,
                        orElse: () => null,
                      );
                  final name = match?.name ?? ing.itemId;
                  final unit = match?.unit ?? '';

                  return Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 5.0,
                        color: CommisColors.goldAccent,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.sourceSans3(
                            color: CommisColors.textPrimary,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Text(
                        '${ing.amountPer10People.toStringAsFixed(ing.amountPer10People == ing.amountPer10People.toInt() ? 0 : 2)} $unit',
                        style: GoogleFonts.jetBrainsMono(
                          color: CommisColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
