import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/scavenger_hunt.dart';
import '../prompts/generate_game_toast.dart';
import '../prompts/generate_item_preview.dart';

class ScavengerHuntGame extends StatefulWidget {
  const ScavengerHuntGame({super.key, required this.game});

  final ScavengerHunt game;

  @override
  State<ScavengerHuntGame> createState() => _ScavengerHuntGameState();
}

class _ScavengerHuntGameState extends State<ScavengerHuntGame> {
  final _completed = ValueNotifier(<ScavengerHuntItem, bool>{});
  final _progress = ValueNotifier(0.0);
  final _selected = ValueNotifier<ScavengerHuntItem?>(null);
  final _hintPreview = ValueNotifier<({bool loading, Object? error, Uint8List? image})>((
    loading: false,
    image: null,
    error: null,
  ));

  bool _isCompleted(ScavengerHuntItem item) {
    final data = _completed.value;
    return data[item] ?? false;
  }

  void _setCompletion(BuildContext context, ScavengerHuntItem item, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final data = _completed.value;
    data[item] ??= false;
    data[item] = value;
    _completed.value = Map.from(data);
    final length = widget.game.items.length;
    final count = data.values.where((e) => e).length;
    _progress.value = count / length;
    if (value) {
      final prompt = GenerateGameToast(
        game: widget.game,
        item: item,
        completed: _completed.value.entries.where((e) => e.value).map((e) => e.key).toSet(),
      );
      final message = await prompt();
      if (message.isNotEmpty) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  void _reset() {
    _completed.value = Map.from({});
    _progress.value = 0;
    _selected.value = null;
  }

  Future<void> _hint(BuildContext context, ScavengerHuntItem item) async {
    _hintPreview.value = (loading: true, image: null, error: null);
    try {
      final prompt = GenerateItemPreview(game: widget.game, item: item);
      final images = await prompt();
      if (images.isEmpty) throw ErrorGeneratingHint();
      final image = images[0];
      _hintPreview.value = (loading: false, image: image.bytesBase64Encoded, error: null);
    } catch (e) {
      _hintPreview.value = (loading: false, image: null, error: e);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    const previewHeight = 400.0;
    return ValueListenableBuilder(
      valueListenable: _selected,
      builder: (context, selected, child) {
        return Column(
          children: [
            ListTile(
              title: Text('Title'),
              subtitle: Text(widget.game.title),
              trailing: IconButton(tooltip: 'Reset the game', onPressed: _reset, icon: const Icon(Icons.restart_alt)),
            ),
            ValueListenableBuilder(
              valueListenable: _progress,
              builder: (context, progress, child) {
                return LinearProgressIndicator(value: progress);
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _completed,
                      builder: (context, child) {
                        return ListView.builder(
                          padding: selected != null ? const EdgeInsets.only(bottom: previewHeight) : null,
                          itemCount: widget.game.items.length,
                          itemBuilder: (context, index) {
                            final item = widget.game.items[index];
                            final isSelected = item == selected;
                            return ListTile(
                              selected: isSelected,
                              title: Text(item.name),
                              trailing: Switch.adaptive(
                                value: _isCompleted(item),
                                onChanged: (value) => _setCompletion(context, item, value),
                              ),
                              leading: IconButton(
                                tooltip: '${_selected.value == item ? 'Hide' : 'Show'} hint',
                                icon: Icon(_selected.value == item ? Icons.help : Icons.help_outline),
                                onPressed: () {
                                  _selected.value = isSelected ? null : item;
                                  if (!isSelected) _hint(context, item).ignore();
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  if (selected != null) ...[
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      height: previewHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Description'),
                                subtitle: Text(selected.description),
                                trailing: IconButton(
                                  tooltip: 'Close hint',
                                  icon: const Icon(Icons.close),
                                  onPressed: () => _selected.value = null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: ValueListenableBuilder(
                                  valueListenable: _hintPreview,
                                  builder: (context, preview, child) {
                                    if (preview.image != null) {
                                      return Image.memory(preview.image!);
                                    }
                                    if (preview.error != null) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text('Error generating preview'),
                                            const SizedBox(height: 8),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                _hint(context, selected).ignore();
                                              },
                                              label: const Text('Retry'),
                                              icon: const Icon(Icons.refresh),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return Center(child: CircularProgressIndicator.adaptive());
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ErrorGeneratingHint extends Error {}
