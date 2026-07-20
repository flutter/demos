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
import '../widgets/job_card.dart';

extension type CateringJobItemData.fromMap(JsonMap json) {
  String get jobId => json['jobId'] as String;
}

final cateringJobItem = CatalogItem(
  name: 'CateringJob',
  dataSchema: S.object(
    description:
        'Displays a single catering job card with its date, guest count, and associated recipes.',
    properties: {
      'jobId': S.string(
        description: 'The unique ID of the catering job to display.',
      ),
    },
    required: ['jobId'],
  ),
  widgetBuilder: (itemContext) {
    final data = CateringJobItemData.fromMap(itemContext.data as JsonMap);
    return SurfaceJobCardLoader(jobId: data.jobId);
  },
);

class SurfaceJobCardLoader extends StatelessWidget {
  final String jobId;

  const SurfaceJobCardLoader({required this.jobId, super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<FirestoreRepository>();

    return StreamBuilder<List<Recipe>>(
      stream: repository.watchRecipes(),
      builder: (context, recipesSnapshot) {
        if (recipesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: CircularProgressIndicator(color: CommisColors.goldAccent),
            ),
          );
        }

        if (recipesSnapshot.hasError) {
          return Center(
            child: Text(
              'Error loading recipes: ${recipesSnapshot.error}',
              style: GoogleFonts.sourceSans3(color: Colors.redAccent),
            ),
          );
        }

        final recipes = recipesSnapshot.data ?? const <Recipe>[];

        return StreamBuilder<CateringJob?>(
          stream: repository.watchJob(jobId),
          builder: (context, jobSnapshot) {
            if (jobSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CircularProgressIndicator(
                    color: CommisColors.goldAccent,
                  ),
                ),
              );
            }

            if (jobSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading job: ${jobSnapshot.error}',
                  style: GoogleFonts.sourceSans3(color: Colors.redAccent),
                ),
              );
            }

            final job = jobSnapshot.data;
            if (job == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Job "$jobId" not found.',
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                    ),
                  ),
                ),
              );
            }

            return JobCard(job: job, allRecipes: recipes);
          },
        );
      },
    );
  }
}
