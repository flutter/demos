// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../theme.dart';
import '../widgets/ingredient_card.dart';

class IngredientsListScreen extends StatelessWidget {
  const IngredientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FirestoreRepository>();

    return Scaffold(
      backgroundColor: CommisColors.background,
      appBar: AppBar(
        backgroundColor: CommisColors.surfaceLevel1,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Text(
          'INGREDIENTS CHECKLIST',
          style: GoogleFonts.outfit(
            color: CommisColors.textPrimary,
            fontSize: 22.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: CommisColors.borderLowContrast, height: 1.0),
        ),
      ),
      body: StreamBuilder<List<Ingredient>>(
        stream: repository.watchIngredients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: CommisColors.goldAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading ingredients: ${snapshot.error}',
                style: GoogleFonts.sourceSans3(color: Colors.redAccent),
              ),
            );
          }

          final items = snapshot.data ?? const <Ingredient>[];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 64.0,
                      color: CommisColors.textSecondary,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No Ingredients Found',
                      style: GoogleFonts.outfit(
                        color: CommisColors.textPrimary,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Ensure the Firestore emulator is running and you have seeded the database using seed_ingredients.dart.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.sourceSans3(
                        color: CommisColors.textSecondary,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return IngredientCard(item: items[index], isEven: index.isEven);
            },
          );
        },
      ),
    );
  }
}
