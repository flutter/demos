// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models.dart';
import '../theme.dart';

class JobCard extends StatelessWidget {
  final CateringJob job;
  final List<Recipe> allRecipes;

  final bool isEven;

  const JobCard({
    required this.job,
    required this.allRecipes,
    this.isEven = false,
    super.key,
  });

  String _formatDate(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = isEven
        ? Color.alphaBlend(
            Colors.white.withAlpha(12),
            CommisColors.surfaceLevel1,
          )
        : CommisColors.surfaceLevel1;

    // Find names of associated recipes
    final associatedRecipes = job.recipeIds.map((id) {
      final match = allRecipes.cast<Recipe?>().firstWhere(
        (r) => r?.id == id,
        orElse: () => null,
      );
      return match?.name ?? id;
    }).toList();

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: GoogleFonts.outfit(
                    color: CommisColors.textPrimary,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6.0),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14.0,
                      color: CommisColors.goldAccent,
                    ),
                    const SizedBox(width: 6.0),
                    Text(
                      _formatDate(job.date),
                      style: GoogleFonts.jetBrainsMono(
                        color: CommisColors.goldAccent,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16.0,
                  color: CommisColors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    job.address,
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 16.0,
                  color: CommisColors.textSecondary,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${job.guestCount} guests',
                  style: GoogleFonts.sourceSans3(
                    color: CommisColors.textSecondary,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Divider(color: CommisColors.borderLowContrast, height: 1.0),
            const SizedBox(height: 16.0),
            Text(
              'MENU ITEMS',
              style: GoogleFonts.outfit(
                color: CommisColors.textSecondary,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10.0),
            if (associatedRecipes.isEmpty)
              Text(
                'No recipes assigned yet',
                style: GoogleFonts.sourceSans3(
                  color: CommisColors.textSecondary.withAlpha(153),
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: associatedRecipes.map((name) {
                  return Chip(
                    backgroundColor: CommisColors.surfaceLevel2,
                    labelStyle: GoogleFonts.sourceSans3(
                      color: CommisColors.textPrimary,
                      fontSize: 13.0,
                    ),
                    side: const BorderSide(
                      color: CommisColors.borderLowContrast,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    label: Text(name),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/jobs/edit/${job.id}');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: CommisColors.goldAccent,
                  foregroundColor: CommisColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16.0),
                label: Text(
                  'Edit Job',
                  style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
