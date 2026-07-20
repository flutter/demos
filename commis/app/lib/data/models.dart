import 'package:cloud_firestore/cloud_firestore.dart';

// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Defines database models serializable to and from Firestore.
// These models represent the core data schemas stored in the backend database.

class CateringJob {
  final String id;
  final String title;
  final String address;
  final int guestCount;
  final DateTime date;
  final List<String> recipeIds;
  final double latitude;
  final double longitude;

  const CateringJob({
    required this.id,
    required this.title,
    required this.address,
    required this.guestCount,
    required this.date,
    required this.recipeIds,
    required this.latitude,
    required this.longitude,
  });

  factory CateringJob.fromMap(String id, Map<String, dynamic> map) {
    return CateringJob(
      id: id,
      title: map['title'] as String? ?? '',
      address: map['address'] as String? ?? '',
      guestCount: map['guestCount'] as int? ?? 0,
      date: _parseDateTime(map['date']),
      recipeIds:
          (map['recipeIds'] as List?)?.map((x) => x as String).toList() ??
          const [],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'guestCount': guestCount,
      'date': Timestamp.fromDate(date),
      'recipeIds': recipeIds,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

DateTime _parseDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  return DateTime.now();
}

class Ingredient {
  final String id;
  final String name;
  final String description;
  final String unit;

  const Ingredient({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
  });

  factory Ingredient.fromMap(String id, Map<String, dynamic> map) {
    return Ingredient(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'unit': unit};
  }
}

class InventoryStock {
  final String itemId;
  final double count;

  const InventoryStock({required this.itemId, required this.count});

  factory InventoryStock.fromMap(Map<String, dynamic> map) {
    return InventoryStock(
      itemId: map['itemId'] as String? ?? '',
      count: (map['count'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'itemId': itemId, 'count': count};
  }
}

class Inventory {
  final String id;
  final List<InventoryStock> items;

  const Inventory({required this.id, required this.items});

  factory Inventory.fromMap(String id, Map<String, dynamic> map) {
    final itemsList = map['items'] as List?;
    return Inventory(
      id: id,
      items:
          itemsList
              ?.map(
                (x) =>
                    InventoryStock.fromMap(Map<String, dynamic>.from(x as Map)),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {'items': items.map((x) => x.toMap()).toList()};
  }
}

class RecipeIngredient {
  final String itemId;
  final double amountPer10People;

  const RecipeIngredient({
    required this.itemId,
    required this.amountPer10People,
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      itemId: map['itemId'] as String? ?? '',
      amountPer10People: (map['amountPer10People'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'itemId': itemId, 'amountPer10People': amountPer10People};
  }
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<RecipeIngredient> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    final ingredientsList = map['ingredients'] as List?;
    return Recipe(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      ingredients:
          ingredientsList
              ?.map(
                (x) => RecipeIngredient.fromMap(
                  Map<String, dynamic>.from(x as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((x) => x.toMap()).toList(),
    };
  }
}
