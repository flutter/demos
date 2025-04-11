import '../models/scavenger_hunt.dart';
import 'base.dart';

class GenerateGameToast extends Prompt<String> {
  final ScavengerHunt game;
  final ScavengerHuntItem item;
  final Set<ScavengerHuntItem> completed;

  GenerateGameToast({required this.game, required this.item, required this.completed});

  @override
  String parse(String value) => value;

  @override
  String get systemPrompt => [
    'You are a scavenger hunt agent that gets called when the ',
    'user completes an item by discovering it. ',
    'You can generate a short fact, congratulate ',
    'the user on the item, or if nothing to add just ',
    'respond with something like ',
    '"Nice job, you have X items left."',
  ].join('\n');

  @override
  String get prompt => [
    'There are ${game.items.length - completed.length} items left to find. Use that number if needed.',
    '',
    'The user just found the item:',
    (item.name),
    '',
    'With the description:',
    (item.description),
  ].join('\n');
}
