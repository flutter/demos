// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../theme.dart';

// --- Extension Types ---

extension type NavigationCardItemData.fromMap(JsonMap json) {
  String get title => json['title'] as String;
  String get address => json['address'] as String;
  double get latitude => (json['latitude'] as num).toDouble();
  double get longitude => (json['longitude'] as num).toDouble();
}

// --- GenUI Catalog Item ---

final navigationCardCatalogItem = CatalogItem(
  name: 'NavigationCard',
  dataSchema: S.object(
    description:
        'Displays a navigation card showing job location, title, and a Google Map widget.',
    properties: {
      'title': S.string(description: 'Title of the job.'),
      'address': S.string(description: 'Address of the job.'),
      'latitude': S.number(description: 'Latitude of the job location.'),
      'longitude': S.number(description: 'Longitude of the job location.'),
    },
    required: ['title', 'address', 'latitude', 'longitude'],
  ),
  widgetBuilder: (itemContext) {
    final data = NavigationCardItemData.fromMap(itemContext.data as JsonMap);
    return NavigationCard(data: data);
  },
);

// --- Navigation Card Widget ---

class NavigationCard extends StatelessWidget {
  final NavigationCardItemData data;

  const NavigationCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final position = LatLng(data.latitude, data.longitude);

    return Card(
      color: CommisColors.surfaceLevel1,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: GoogleFonts.outfit(
                color: CommisColors.textPrimary,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16.0,
                  color: CommisColors.goldAccent,
                ),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    data.address,
                    style: GoogleFonts.sourceSans3(
                      color: CommisColors.textSecondary,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              height: 180.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: CommisColors.borderLowContrast,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: position,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('job_location'),
                      position: position,
                    ),
                  },
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
