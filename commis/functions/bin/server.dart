// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:commis_functions/src/content_generator.dart';
import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:firebase_functions/firebase_functions.dart';

void main() {
  final adminApp = FirebaseApp.initializeApp();
  final firestore = adminApp.firestore();

  runFunctions((firebase) {
    // NOTE: Firestore triggers (like onDocumentWritten) are currently experimental
    // in the Dart Cloud Functions SDK and are only supported when running within the
    // Firebase Emulator Suite.
    // ignore: experimental_member_use
    firebase.firestore.onDocumentWritten(
      (event) async {
        final apiKey = StringParam(
            'GEMINI_API_KEY',
            ParamOptions(
              defaultValue: '',
              label: 'Gemini API Key',
              description:
                  'API key to use when accessing the Gemini Developer API',
            )).value();

        final jobId = event.params['jobId'];
        final jobData = event.data?.after?.data();

        if (jobData == null) {
          print('Could not find post-write job data.');
          return;
        }

        final jobBuffer = StringBuffer();

        jobBuffer.writeln('jobId: $jobId');
        jobBuffer.writeln('address: ${jobData['address']}');
        jobBuffer.writeln('title: ${jobData['title']}');
        jobBuffer.writeln('guests: ${jobData['guestCount']}');
        jobBuffer.writeln('recipes: ${jobData['recipeIds']}');

        try {
          final date = DateTime.parse(jobData['date'].toString());
          final now = DateTime.now();
          final days = DateTime(date.year, date.month, date.day)
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
          jobBuffer.writeln('daysUntilEvent: $days');
        } catch (e) {
          print('Error calculating daysUntilEvent: $e');
          return;
        }

        print(jobBuffer.toString());

        try {
          final generator = ContentGenerator(apiKey);
          final message = await generator.generateFeed(jobData.toString());

          if (message == noUiSentinel) {
            await firestore.collection('feed').doc(jobId).delete();
            print('No UI generated; deleting feed for $jobId.');
            return;
          }

          await firestore.collection('feed').doc(jobId).set({
            'message': message,
          });

          print('Wrote feed for $jobId.');
        } catch (e) {
          print('Error generating UI: $e');
          return;
        }
      },
      document: 'jobs/{jobId}',
    );
  });
}
