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

extension type RecipeLineItemData.fromMap(JsonMap json) {
  String get recipeId => json['recipeId'] as String;
}

// --- GenUI Catalog Item ---

final recipeLineCatalogItem = CatalogItem(
  name: 'RecipeLine',
  dataSchema: S.object(
    description:
        'Displays a single recipe with its name, description, and image.',
    properties: {
      'recipeId': S.string(
        description: 'The unique ID of the recipe to display.',
      ),
    },
    required: ['recipeId'],
  ),
  widgetBuilder: (itemContext) {
    final data = RecipeLineItemData.fromMap(itemContext.data as JsonMap);
    return SurfaceRecipeLoader(recipeId: data.recipeId);
  },
);

// --- Custom Loader Widget ---

class SurfaceRecipeLoader extends StatelessWidget {
  final String recipeId;

  const SurfaceRecipeLoader({required this.recipeId, super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FirestoreRepository>();

    return StreamBuilder<Recipe?>(
      stream: repository.watchRecipe(recipeId),
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
                'Error loading recipe: ${snapshot.error}',
                style: GoogleFonts.sourceSans3(color: Colors.redAccent),
              ),
            ),
          );
        }

        final recipe = snapshot.data;
        if (recipe == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Recipe "$recipeId" not found.',
                style: GoogleFonts.sourceSans3(
                  color: CommisColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return RecipeLine(recipe: recipe);
      },
    );
  }
}

// --- Mini Recipe Card Widget ---

class RecipeLine extends StatelessWidget {
  final Recipe recipe;

  const RecipeLine({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    final assetPath = 'assets/images/recipes/200/${recipe.id}.png';

    return Card(
      color: CommisColors.surfaceLevel1,
      elevation: 0.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Recipe image thumbnail
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
                          Icons.restaurant,
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
            // Right: Name & Description column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: GoogleFonts.outfit(
                      color: CommisColors.textPrimary,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    recipe.description,
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                      fontSize: 13.0,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
