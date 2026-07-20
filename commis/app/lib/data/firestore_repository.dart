// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirestoreRepository {
  final FirebaseFirestore _firestore;

  FirestoreRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // --- Catering Jobs ---

  /// Stream all catering jobs sorted by date
  Stream<List<CateringJob>> watchJobs() {
    return _firestore
        .collection('jobs')
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CateringJob.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Fetch all catering jobs once (useful for tool calls/prompts)
  Future<List<CateringJob>> getJobs() async {
    final snapshot = await _firestore
        .collection('jobs')
        .orderBy('date', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => CateringJob.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Stream a single catering job by ID
  Stream<CateringJob?> watchJob(String id) {
    return _firestore.collection('jobs').doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || !doc.exists) return null;
      return CateringJob.fromMap(id, data);
    });
  }

  /// Get a single catering job by ID once
  Future<CateringJob?> getJob(String id) async {
    final doc = await _firestore.collection('jobs').doc(id).get();
    final data = doc.data();
    if (data == null || !doc.exists) return null;
    return CateringJob.fromMap(id, data);
  }

  /// Update or save a catering job
  Future<void> updateJob(CateringJob job) async {
    await _firestore.collection('jobs').doc(job.id).set(job.toMap());
  }

  // --- Recipes ---

  /// Stream all recipes
  Stream<List<Recipe>> watchRecipes() {
    return _firestore
        .collection('recipes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Recipe.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream a single recipe by ID
  Stream<Recipe?> watchRecipe(String id) {
    return _firestore.collection('recipes').doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || !doc.exists) return null;
      return Recipe.fromMap(id, data);
    });
  }

  /// Fetch all recipes once
  Future<List<Recipe>> getRecipes() async {
    final snapshot = await _firestore.collection('recipes').get();
    return snapshot.docs
        .map((doc) => Recipe.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get a single recipe by ID once
  Future<Recipe?> getRecipe(String id) async {
    final doc = await _firestore.collection('recipes').doc(id).get();
    final data = doc.data();
    if (data == null || !doc.exists) return null;
    return Recipe.fromMap(id, data);
  }

  /// Fetch recipes associated with a given job ID
  Future<List<Recipe>> getRecipesForJob(String jobId) async {
    final job = await getJob(jobId);
    if (job == null || job.recipeIds.isEmpty) return const [];
    final recipes = await getRecipes();
    return recipes.where((r) => job.recipeIds.contains(r.id)).toList();
  }

  // --- Ingredients ---

  /// Stream all ingredients
  Stream<List<Ingredient>> watchIngredients() {
    return _firestore
        .collection('ingredients')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Ingredient.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Stream a single ingredient by ID
  Stream<Ingredient?> watchIngredient(String id) {
    return _firestore.collection('ingredients').doc(id).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || !doc.exists) return null;
      return Ingredient.fromMap(id, data);
    });
  }

  /// Fetch all ingredients once
  Future<List<Ingredient>> getIngredients() async {
    final snapshot = await _firestore.collection('ingredients').get();
    return snapshot.docs
        .map((doc) => Ingredient.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Fetch ingredients used in a recipe
  Future<List<Ingredient>> getIngredientsForRecipe(String recipeId) async {
    final recipes = await getRecipes();
    final recipe = recipes.cast<Recipe?>().firstWhere(
      (r) => r?.id == recipeId,
      orElse: () => null,
    );
    if (recipe == null || recipe.ingredients.isEmpty) return const [];

    final ingredientIds = recipe.ingredients.map((ri) => ri.itemId).toSet();
    final ingredients = await getIngredients();
    return ingredients.where((ii) => ingredientIds.contains(ii.id)).toList();
  }

  /// Fetch the message from the feed collection for a given JobId
  Future<String?> getFeedMessage(String jobId) async {
    final doc = await _firestore.collection('feed').doc(jobId).get();
    if (!doc.exists) return null;
    return doc.data()?['message'] as String?;
  }
}
