// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';

void main() async {
  // Initialize the Firebase Admin App
  final String projectId =
      Platform.environment['GOOGLE_CLOUD_PROJECT'] ?? 'YOUR_PROJECT_ID';
  final adminApp = FirebaseApp.initializeApp(
    options: AppOptions(
      projectId: projectId,
    ),
  );
  final firestore = adminApp.firestore();

  final List<Map<String, dynamic>> recipes = [
    {
      'id': 'classic_tomato_basil_penne',
      'name': 'Classic Tomato Basil Penne',
      'description':
          'Penne pasta tossed in a rustic tomato sauce made from ripe Roma tomatoes, garlic, extra virgin olive oil, and finished with fresh basil and grated Parmigiano-Reggiano.',
      'ingredients': [
        {'itemId': 'penne_pasta', 'amountPer10People': 2.0},
        {'itemId': 'roma_tomatoes', 'amountPer10People': 3.0},
        {'itemId': 'fresh_basil', 'amountPer10People': 2.0},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.15},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.15},
        {'itemId': 'parmesan_cheese', 'amountPer10People': 0.25},
      ],
    },
    {
      'id': 'pan_seared_salmon',
      'name': 'Pan-Seared Atlantic Salmon',
      'description':
          'Crispy skin-on Atlantic salmon fillet pan-seared and drizzled with a bright lemon, garlic, and fresh parsley oil.',
      'ingredients': [
        {'itemId': 'salmon_fillets', 'amountPer10People': 4.0},
        {'itemId': 'fresh_lemons', 'amountPer10People': 5.0},
        {'itemId': 'fresh_parsley', 'amountPer10People': 1.0},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.1},
        {'itemId': 'kosher_salt', 'amountPer10People': 0.05},
        {'itemId': 'black_peppercorns', 'amountPer10People': 0.02},
      ],
    },
    {
      'id': 'garlic_herb_roasted_potatoes',
      'name': 'Garlic Herb Roasted Potatoes',
      'description':
          'Crispy, oven-roasted Russet potato wedges seasoned with minced garlic, crushed rosemary, thyme, and extra virgin olive oil.',
      'ingredients': [
        {'itemId': 'russet_potatoes', 'amountPer10People': 5.0},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.15},
        {'itemId': 'dried_rosemary', 'amountPer10People': 0.05},
        {'itemId': 'dried_thyme', 'amountPer10People': 0.05},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.15},
        {'itemId': 'kosher_salt', 'amountPer10People': 0.05},
      ],
    },
    {
      'id': 'classic_caesar_salad',
      'name': 'Catering-Style Caesar Salad',
      'description':
          'Crisp romaine hearts tossed in a house-made creamy Caesar dressing with grated parmesan cheese and garlic.',
      'ingredients': [
        {'itemId': 'parmesan_cheese', 'amountPer10People': 0.3},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.1},
        {'itemId': 'fresh_lemons', 'amountPer10People': 3.0},
        {'itemId': 'mayonnaise', 'amountPer10People': 0.5},
        {'itemId': 'dijon_mustard', 'amountPer10People': 0.05},
        {'itemId': 'black_peppercorns', 'amountPer10People': 0.02},
      ],
    },
    {
      'id': 'pork_carnitas_tacos',
      'name': 'Slow-Roasted Pulled Pork Carnitas',
      'description':
          'Tender, slow-cooked pork shoulder shredded and crisped, served with corn tortillas, fresh limes, chopped red onions, and cilantro.',
      'ingredients': [
        {'itemId': 'pork_shoulder', 'amountPer10People': 4.5},
        {'itemId': 'yellow_onions', 'amountPer10People': 1.0},
        {'itemId': 'onion_red', 'amountPer10People': 0.5},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.2},
        {'itemId': 'fresh_limes', 'amountPer10People': 6.0},
        {'itemId': 'fresh_cilantro', 'amountPer10People': 2.0},
        {'itemId': 'ground_cumin', 'amountPer10People': 0.05},
        {'itemId': 'dried_oregano', 'amountPer10People': 0.05},
        {'itemId': 'corn_tortillas', 'amountPer10People': 1.0},
      ],
    },
    {
      'id': 'wild_mushroom_risotto',
      'name': 'Wild Mushroom Risotto',
      'description':
          'Creamy risotto made with earthy Cremini mushrooms, caramelized yellow onions, garlic, and finished with unsalted butter and shaved parmesan.',
      'ingredients': [
        {'itemId': 'cremini_mushrooms', 'amountPer10People': 1.5},
        {'itemId': 'jasmine_rice', 'amountPer10People': 2.0},
        {'itemId': 'yellow_onions', 'amountPer10People': 0.75},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.1},
        {'itemId': 'unsalted_butter', 'amountPer10People': 0.25},
        {'itemId': 'parmesan_cheese', 'amountPer10People': 0.3},
        {'itemId': 'vegetable_stock', 'amountPer10People': 0.75},
      ],
    },
    {
      'id': 'garlic_shrimp_scampi',
      'name': 'Spicy Garlic Shrimp Scampi',
      'description':
          'Jumbo shrimp sautéed in a rich garlic butter sauce with fresh lemon juice, parsley, and a pinch of red pepper flakes.',
      'ingredients': [
        {'itemId': 'jumbo_shrimp', 'amountPer10People': 3.0},
        {'itemId': 'garlic_bulbs', 'amountPer10People': 0.25},
        {'itemId': 'unsalted_butter', 'amountPer10People': 0.5},
        {'itemId': 'fresh_lemons', 'amountPer10People': 4.0},
        {'itemId': 'fresh_parsley', 'amountPer10People': 1.0},
        {'itemId': 'crushed_red_pepper', 'amountPer10People': 0.02},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.1},
      ],
    },
    {
      'id': 'caprese_skewers',
      'name': 'Balsamic Caprese Skewers',
      'description':
          'Bite-sized fresh mozzarella balls and sweet Roma tomatoes skewered with fresh basil leaves and drizzled with extra virgin olive oil and balsamic vinegar.',
      'ingredients': [
        {'itemId': 'mozzarella_logs', 'amountPer10People': 1.0},
        {'itemId': 'roma_tomatoes', 'amountPer10People': 1.5},
        {'itemId': 'fresh_basil', 'amountPer10People': 1.5},
        {'itemId': 'balsamic_vinegar', 'amountPer10People': 0.25},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.15},
      ],
    },
    {
      'id': 'arugula_goat_cheese_salad',
      'name': 'Arugula & Goat Cheese Salad',
      'description':
          'Peppery wild arugula salad with crumbled goat cheese, thin Fuji apple slices, and dressed with a honey-balsamic vinaigrette.',
      'ingredients': [
        {'itemId': 'wild_arugula', 'amountPer10People': 0.75},
        {'itemId': 'goat_cheese_logs', 'amountPer10People': 4.0},
        {'itemId': 'fuji_apples', 'amountPer10People': 1.5},
        {'itemId': 'balsamic_vinegar', 'amountPer10People': 0.2},
        {'itemId': 'olive_oil_extra_virgin', 'amountPer10People': 0.3},
        {'itemId': 'wildflower_honey', 'amountPer10People': 0.1},
      ],
    },
    {
      'id': 'strawberry_shortcake',
      'name': 'Fresh Strawberry Shortcake',
      'description':
          'Tender buttermilk shortcake layered with sweet sliced fresh strawberries and fresh vanilla-infused heavy whipped cream.',
      'ingredients': [
        {'itemId': 'fresh_strawberries', 'amountPer10People': 3.0},
        {'itemId': 'heavy_whipping_cream', 'amountPer10People': 0.5},
        {'itemId': 'all_purpose_flour', 'amountPer10People': 1.5},
        {'itemId': 'granulated_sugar', 'amountPer10People': 0.75},
        {'itemId': 'unsalted_butter', 'amountPer10People': 0.3},
        {'itemId': 'vanilla_extract', 'amountPer10People': 0.05},
      ],
    },
  ];

  print('Seeding ${recipes.length} recipes...');
  final batch = firestore.batch();
  final collection = firestore.collection('recipes');

  for (final recipe in recipes) {
    final docId = recipe['id'] as String;
    final docRef = collection.doc(docId);
    batch.set(docRef, {
      'name': recipe['name'],
      'description': recipe['description'],
      'ingredients': recipe['ingredients'],
    });
  }

  await batch.commit();
  print('Successfully seeded ${recipes.length} recipes in Firestore!');
}
