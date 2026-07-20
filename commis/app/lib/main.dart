// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/firestore_repository.dart';
import 'firebase_options.dart';
import 'ui/screens/agent_screen.dart';
import 'ui/screens/ingredients_list_screen.dart';
import 'ui/screens/job_edit_screen.dart';
import 'ui/screens/jobs_list_screen.dart';
import 'ui/screens/navigation_shell.dart';
import 'ui/screens/recipes_list_screen.dart';
import 'ui/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure basic GenUI logging
  configureLogging(
    logCallback: (level, msg) => debugPrint('GenUI $level: $msg'),
  );

  try {
    const bool useEmulators = bool.fromEnvironment(
      'USE_EMULATORS',
      defaultValue: kDebugMode,
    );

    if (useEmulators) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Sign in anonymously for Firebase AI Logic
    // await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  runApp(
    Provider<FirestoreRepository>(
      create: (context) => FirestoreRepository(),
      child: const MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/jobs',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/jobs',
              builder: (context, state) => const JobsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/recipes',
              builder: (context, state) => const RecipesListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ingredients',
              builder: (context, state) => const IngredientsListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/agent',
              builder: (context, state) => const AgentScreen(),
            ),
          ],
        ),
      ],
    ),
    // Full-screen job edit screen outside of bottom bar shell
    GoRoute(
      path: '/jobs/edit/:jobId',
      builder: (context, state) {
        final jobId = state.pathParameters['jobId']!;
        return JobEditScreen(jobId: jobId);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Commis Catering Assistant',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CommisColors.background,
        colorScheme: const ColorScheme.dark(
          primary: CommisColors.goldAccent,
          surface: CommisColors.surfaceLevel1,
          error: Colors.redAccent,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
