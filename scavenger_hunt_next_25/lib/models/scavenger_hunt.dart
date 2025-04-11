import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class ScavengerHunt {
  static Schema schema = Schema.object(
    properties: {'title': Schema.string(nullable: false), 'items': Schema.array(items: ScavengerHuntItem.schema)},
  );

  ScavengerHunt({required this.title, required this.items});

  final String title;
  final List<ScavengerHuntItem> items;

  factory ScavengerHunt.fromJson(String value) {
    final data = jsonDecode(value) as Map;
    final title = data['title'] as String;
    final items = (data['items'] as List).map(jsonEncode).map(ScavengerHuntItem.fromJson).toList();
    return ScavengerHunt(title: title, items: items);
  }
}

class ScavengerHuntItem {
  static Schema schema = Schema.object(
    properties: {'name': Schema.string(nullable: false), 'description': Schema.string(nullable: false)},
  );

  ScavengerHuntItem({required this.name, required this.description});

  final String name;
  final String description;

  factory ScavengerHuntItem.fromJson(String value) {
    final data = jsonDecode(value) as Map;
    return ScavengerHuntItem(name: data['name'] as String, description: data['description'] as String);
  }
}
