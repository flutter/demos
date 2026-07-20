// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:provider/provider.dart';

import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../theme.dart';

// --- Extension Types ---

extension type IngredientLineItemData.fromMap(JsonMap json) {
  String get ingredientId => json['ingredientId'] as String;
}

// --- GenUI Catalog Item ---

final ingredientLineCatalogItem = CatalogItem(
  name: 'IngredientLine',
  dataSchema: S.object(
    description:
        'Displays a single ingredient with its name, description, unit, cost, and image.',
    properties: {
      'ingredientId': S.string(
        description: 'The unique ID of the ingredient to display.',
      ),
    },
    required: ['ingredientId'],
  ),
  widgetBuilder: (itemContext) {
    final data = IngredientLineItemData.fromMap(itemContext.data as JsonMap);
    return SurfaceIngredientLoader(ingredientId: data.ingredientId);
  },
);

// --- Custom Loader Widget ---

class SurfaceIngredientLoader extends StatelessWidget {
  final String ingredientId;

  const SurfaceIngredientLoader({required this.ingredientId, super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FirestoreRepository>();

    return StreamBuilder<Ingredient?>(
      stream: repository.watchIngredient(ingredientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(color: CommisColors.goldAccent),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Error loading ingredient: ${snapshot.error}',
                style: GoogleFonts.sourceSans3(color: Colors.redAccent),
              ),
            ),
          );
        }

        final ingredient = snapshot.data;
        if (ingredient == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Ingredient "$ingredientId" not found.',
                style: GoogleFonts.sourceSans3(
                  color: CommisColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return IngredientLine(ingredient: ingredient);
      },
    );
  }
}

// --- Mini Ingredient Card Widget ---

class IngredientLine extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientLine({required this.ingredient, super.key});

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/ingredients/200/${ingredient.id}.png';

    return Card(
      color: CommisColors.surfaceLevel1,
      elevation: 0.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Ingredient image thumbnail
            Container(
              width: 60.0,
              height: 60.0,
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
                          Icons.kitchen,
                          color: CommisColors.goldAccentDim,
                          size: 22.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Right: Name, Description, Unit, and Cost column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: GoogleFonts.outfit(
                      color: CommisColors.textPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    ingredient.description,
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                      fontSize: 13.0,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Unit: ${ingredient.unit}',
                        style: GoogleFonts.sourceSans3(
                          color: CommisColors.textSecondary,
                          fontSize: 12.0,
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
