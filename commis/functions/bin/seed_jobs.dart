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

  final List<Map<String, dynamic>> jobs = [
    {
      'id': 'job_fluttercon_bash',
      'title': 'Post-Fluttercon Bash',
      'address': '777 E Princeton St, Orlando, FL 32803',
      'guestCount': 250,
      'date': DateTime(2026, 7, 18),
      'recipeIds': [
        'classic_tomato_basil_penne',
        'garlic_shrimp_scampi',
        'classic_caesar_salad',
        'caprese_skewers',
      ],
      'latitude': 28.572105,
      'longitude': -81.366258,
    },
    {
      'id': 'job_movie_night',
      'title': 'Movie Night',
      'address': '7010 Lake Nona Blvd, Orlando, FL 32827',
      'guestCount': 30,
      'date': DateTime(2026, 7, 26),
      'recipeIds': [
        'pork_carnitas_tacos',
        'arugula_goat_cheese_salad',
        'strawberry_shortcake',
      ],
      'latitude': 28.375549,
      'longitude': -81.273934,
    },
    {
      'id': 'job_andrew_bday',
      'title': "Andrew's B-Day Party",
      'address': '445 S Magnolia Ave, Orlando, FL 32801',
      'guestCount': 80,
      'date': DateTime(2026, 11, 10),
      'recipeIds': [
        'pan_seared_salmon',
        'garlic_herb_roasted_potatoes',
        'wild_mushroom_risotto',
        'strawberry_shortcake',
        'caprese_skewers',
      ],
      'latitude': 28.539824,
      'longitude': -81.377138,
    },
  ];

  print('Seeding ${jobs.length} catering jobs...');
  final batch = firestore.batch();
  final collection = firestore.collection('jobs');

  for (final job in jobs) {
    final docId = job['id'] as String;
    final docRef = collection.doc(docId);
    batch.set(docRef, {
      'title': job['title'],
      'address': job['address'],
      'guestCount': job['guestCount'],
      'date': job['date'],
      'recipeIds': job['recipeIds'],
      'latitude': job['latitude'],
      'longitude': job['longitude'],
    });
  }

  await batch.commit();
  print('Successfully seeded ${jobs.length} catering jobs in Firestore!');
}
