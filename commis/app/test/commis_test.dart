// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:commis/data/models.dart';
import 'package:commis/services/cost_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CostService Tests', () {
    final costService = CostService();

    test('calculates correct cost for known ingredients', () {
      // Russet Potatoes are 0.50/lb
      expect(costService.fetchPrice('russet_potatoes', 2.0), closeTo(1.00, 0.001));
      // Unsalted Butter is 2.20/ea
      expect(costService.fetchPrice('unsalted_butter', 5.0), closeTo(11.00, 0.001));
    });

    test('returns 0.0 for unknown ingredients', () {
      expect(costService.fetchPrice('non_existent_ingredient', 10.0), 0.0);
    });
  });

  group('CateringJob Model Tests', () {
    test('parses from valid firestore map', () {
      final mockData = {
        'title': 'Test catering job',
        'address': '123 Test St',
        'guestCount': 100,
        'date': '2026-07-20T12:00:00.000',
        'recipeIds': ['recipe_1', 'recipe_2'],
        'latitude': 37.422,
        'longitude': -122.084,
      };

      final job = CateringJob.fromMap('job_test_id', mockData);

      expect(job.id, 'job_test_id');
      expect(job.title, 'Test catering job');
      expect(job.address, '123 Test St');
      expect(job.guestCount, 100);
      expect(job.date.year, 2026);
      expect(job.recipeIds, containsAll(['recipe_1', 'recipe_2']));
      expect(job.latitude, 37.422);
      expect(job.longitude, -122.084);
    });

    test('uses defaults for empty map fields', () {
      final job = CateringJob.fromMap('job_empty_id', {});

      expect(job.id, 'job_empty_id');
      expect(job.title, '');
      expect(job.address, '');
      expect(job.guestCount, 0);
      expect(job.recipeIds, isEmpty);
      expect(job.latitude, 0.0);
      expect(job.longitude, 0.0);
    });
  });
}
