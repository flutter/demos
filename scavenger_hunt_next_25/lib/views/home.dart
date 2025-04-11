import 'package:flutter/material.dart';

import '../models/scavenger_hunt.dart';
import '../widgets/form.dart';
import '../widgets/game.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.changeTheme});

  final ValueChanged<ThemeMode> changeTheme;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _game = ValueNotifier<ScavengerHunt?>(null);

  @override
  void initState() {
    super.initState();
    _game.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _restart() {
    _game.value = null;
  }

  void _setGame(ScavengerHunt? value) {
    _game.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Gemini Scavenger Hunt'),
            actions: [
              IconButton(onPressed: _game.value == null ? null : _restart, icon: Icon(Icons.restore)),
              PopupMenuButton(
                icon: Icon(Icons.brightness_auto),
                onSelected: widget.changeTheme,
                itemBuilder: (context) {
                  return ThemeMode.values.map((e) => PopupMenuItem(value: e, child: Text(e.name))).toList();
                },
              ),
            ],
          ),
          SliverFillRemaining(
            child: () {
              if (_game.value == null) {
                return ScavengerHuntForm(onUpdate: _setGame);
              } else {
                return ScavengerHuntGame(game: _game.value!);
              }
            }(),
          ),
        ],
      ),
    );
  }
}
