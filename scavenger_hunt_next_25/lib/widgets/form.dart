import 'package:flutter/material.dart';

import '../prompts/generate_game.dart';
import '../models/scavenger_hunt.dart';

class ScavengerHuntForm extends StatefulWidget {
  const ScavengerHuntForm({super.key, required this.onUpdate});

  final ValueChanged<ScavengerHunt> onUpdate;

  @override
  State<ScavengerHuntForm> createState() => _ScavengerHuntFormState();
}

class _ScavengerHuntFormState extends State<ScavengerHuntForm> {
  final loading = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  final _data = <String, Object?>{};

  static const String _themeKey = 'theme';
  static const String _locationKey = 'location';
  static const String _itemsKey = 'items';

  void Function(String? value) _save(String key) {
    return (value) {
      _data[key] = value;
    };
  }

  String? Function(String? value) _validate(String key) {
    return (value) {
      if ([_themeKey, _locationKey].contains(key)) {
        if (!value.notNull) return 'Cannot be empty';
      }
      return null;
    };
  }

  void _generate() async {
    try {
      loading.value = true;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        final prompt = GenerateGame(
          theme: _data[_themeKey] as String,
          location: _data[_locationKey] as String,
          items: _data[_itemsKey] as String?,
        );
        final res = await prompt();
        widget.onUpdate(res);
      }
    } finally {
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 32,
                        children: [
                          Text('Game Details', style: Theme.of(context).textTheme.headlineSmall),
                          TextFormField(
                            decoration: InputDecoration(label: Text('What type of theme?')),
                            onSaved: _save(_themeKey),
                            validator: _validate(_themeKey),
                          ),
                          TextFormField(
                            decoration: InputDecoration(label: Text('Where will the game be played?')),
                            onSaved: _save(_locationKey),
                            validator: _validate(_locationKey),
                          ),
                          TextFormField(
                            decoration: InputDecoration(label: Text('Any specific items to include?')),
                            onSaved: _save(_itemsKey),
                            validator: _validate(_itemsKey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: loading,
                  builder: (context, loading, child) {
                    return FloatingActionButton.extended(
                      onPressed: loading ? null : _generate,
                      label: Text('Generate Game'),
                      icon: loading ? CircularProgressIndicator.adaptive() : const Icon(Icons.auto_awesome),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on String? {
  bool get notNull => this != null && this!.trim().isNotEmpty;
}
