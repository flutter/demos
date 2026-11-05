import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: implementation_imports

import 'package:flutter/src/widgets/_window.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runWidget(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainWindowDelegate extends WindowControllerDelegate {
  @override
  void onWindowDestroyed() {
    super.onWindowDestroyed();
    ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}

class _MainAppState extends State<MainApp> {
  final controller = WindowController(
    size: const Size(800, 600),
    title: 'Main Window',
    delegate: _MainWindowDelegate(),
  );

  @override
  Widget build(BuildContext context) {
    final app = const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );

    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return WindowManager(
        initialWindows: [
          WindowEntry(
            controller: controller,
            builder: (context) {
              return app;
            },
          ),
        ],
      );
    } else {
      return app;
    }
  }
}
