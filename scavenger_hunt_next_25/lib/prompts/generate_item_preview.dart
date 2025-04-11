import '../models/scavenger_hunt.dart';
import 'base.dart';

class GenerateItemPreview extends ImagePrompt {
  final ScavengerHunt game;
  final ScavengerHuntItem item;

  GenerateItemPreview({required this.game, required this.item});

  @override
  String get prompt => [
    'Generate an abstract image for a scavenger hunt game (${game.title}) ',
    'that will help the user find a item.',
    '',
    'The image should be simple and minimalistic.',
    '',
    'Item name: ${item.name}',
    '',
    'Item description: ${item.description}',
  ].join('\n');
}
