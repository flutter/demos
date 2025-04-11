import 'package:firebase_vertexai/firebase_vertexai.dart';

import '../models/scavenger_hunt.dart';
import 'base.dart';

class GenerateGame extends Prompt<ScavengerHunt> {
  final String theme;
  final String location;
  final String? items;

  GenerateGame({required this.theme, required this.location, this.items});

  @override
  Schema get schema => ScavengerHunt.schema;

  @override
  ScavengerHunt parse(String value) => ScavengerHunt.fromJson(value);

  @override
  String systemPrompt = 'You are a scavenger hunt game creator. The game should be fun and easy to play.';

  @override
  String get prompt => [
    'The game should be centered around the following theme:',
    theme,
    '',
    'Create a game suitable to be played at the following location:',
    location,
    '',
    if (items != null && items!.trim().isNotEmpty) ...['Make sure to include the following items:', items!],
  ].join('\n');
}
