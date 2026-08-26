// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:android_toast_demo/gen/android/content/_package.dart';
import 'package:android_toast_demo/gen/android/widget/_package.dart';
import 'package:android_toast_demo/gen/java/lang/_package.dart';
import 'package:flutter/material.dart';
import 'package:jni/jni.dart';
import 'package:jni_flutter/jni_flutter.dart';

var context = androidApplicationContext.as(Context.type);

/// Display DateTime retrieved from Dart
void showToast() {
  final message = 'The time is now ${DateTime.now()}';

// Corresponds  to this second signature
// public static Toast makeText (Context context,
//              CharSequence text,
//                int duration)
// First one uses R namespace resources
  Toast.makeText$1(
    context,
    message.toJString().as(CharSequence.type),
    Toast.LENGTH_LONG,
  )!.show();
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Show Time'),
              onPressed: () => showToast(),
            ),
          ],
        ),
      ),
    );
  }
}
