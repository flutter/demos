import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class App extends StatefulWidget {
  const App({super.key, required this.seedColor});

  final Color seedColor;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final lightColorScheme = ColorScheme.fromSeed(seedColor: widget.seedColor, brightness: Brightness.light);
  late final lightTheme = ThemeData.light().copyWith(
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,
  );

  late final darkColorScheme = ColorScheme.fromSeed(seedColor: widget.seedColor, brightness: Brightness.dark);
  late final darkTheme = ThemeData.dark().copyWith(
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
  );

  final themeMode = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: child,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
        );
      },
      child: Home(changeTheme: (value) => themeMode.value = value),
    );
  }
}
