// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'flutter_firebase_ai_demo.dart';
import './firebase_options.dart';
import 'shared/app_state.dart';

void main() async {
  FirebaseOptions options = DefaultFirebaseOptions.currentPlatform;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColor = ref.watch(appStateProvider).appColor;
    return MaterialApp(
      title: 'Flutter AI Playground',
      home: DemoHomeScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: appColor,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        ).copyWith(surface: appColor),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey.shade900,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey.shade400,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
