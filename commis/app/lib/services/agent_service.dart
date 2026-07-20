// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart' hide TextPart;

import '../../data/firestore_repository.dart';
import '../../data/models.dart';

abstract class AgentService {
  Stream<String> generateResponse(String prompt);
}

class FirebaseAILogicService implements AgentService {
  late final ChatSession _chatSession;
  final FirestoreRepository repository;

  FirebaseAILogicService({
    required this.repository,
    required Catalog catalog,
    String? cachedMessages,
  }) {
    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [
        systemInstruction,
        if (cachedMessages != null)
          'These A2UI messages are already in place on the client:\n$cachedMessages\n\n',
      ],
    );

    final prompt = promptBuilder.systemPromptJoined();

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-flash-latest',
      systemInstruction: Content.system(prompt),
      tools: [
        Tool.functionDeclarations([
          FunctionDeclaration(
            'fetchCateringJobs',
            'Fetches the list of active catering jobs in the system, returning their IDs and titles.',
            parameters: {},
          ),
          FunctionDeclaration(
            'fetchRecipesForJob',
            'Fetches the list of recipes (with all fields) associated with a given jobId.',
            parameters: {
              'jobId': Schema.string(
                description:
                    'The unique ID of the catering job to fetch recipes for.',
              ),
            },
          ),
          FunctionDeclaration(
            'fetchIngredientsForRecipe',
            'Fetches the list of ingredients (with all fields) associated with a given recipeId.',
            parameters: {
              'recipeId': Schema.string(
                description:
                    'The unique ID of the recipe to fetch ingredients for.',
              ),
            },
          ),
          FunctionDeclaration(
            'updateCateringJob',
            'Updates an existing catering job with the provided fields.',
            parameters: {
              'id': Schema.string(
                description:
                    'The unique ID of the catering job to update (required).',
              ),
              'title': Schema.string(
                description:
                    'The updated title of the catering job (optional).',
              ),
              'address': Schema.string(
                description:
                    'The updated address of the catering event (optional).',
              ),
              'guestCount': Schema.integer(
                description: 'The updated guest count of the event (optional).',
              ),
              'date': Schema.string(
                description:
                    'The updated scheduled ISO 8601 date string of the event (optional).',
              ),
              'recipeIds': Schema.array(
                items: Schema.string(),
                description:
                    'The updated list of recipe IDs associated with this job (optional).',
              ),
              'latitude': Schema.number(
                description:
                    'The updated latitude coordinate of the event (optional).',
              ),
              'longitude': Schema.number(
                description:
                    'The updated longitude coordinate of the event (optional).',
              ),
            },
            optionalParameters: [
              'title',
              'address',
              'guestCount',
              'date',
              'recipeIds',
              'latitude',
              'longitude',
            ],
          ),
        ]),
      ],
    );
    _chatSession = model.startChat();
  }

  Future<String> _fetchCateringJobs() async {
    debugPrint('_fetchCateringJobs called');
    final jobs = await repository.getJobs();

    final jobsList = jobs.map((job) {
      return {
        'id': job.id,
        'title': job.title,
        'address': job.address,
        'guestCount': job.guestCount,
        'date': job.date.toIso8601String(),
        'recipeIds': job.recipeIds,
      };
    }).toList();

    return jsonEncode(jobsList);
  }

  Future<String> _fetchRecipesForJob(String jobId) async {
    debugPrint('_fetchRecipesForJob called with jobId: $jobId');
    final recipes = await repository.getRecipesForJob(jobId);
    final result = recipes.map((r) => r.toMap()).toList();
    return jsonEncode(result);
  }

  Future<String> _fetchIngredientsForRecipe(String recipeId) async {
    debugPrint('_fetchIngredientsForRecipe called with recipeId: $recipeId');
    final recipe = await repository.getRecipe(recipeId);
    if (recipe == null) return '[]';

    final ingredients = await repository.getIngredientsForRecipe(recipeId);

    final result = recipe.ingredients.map((ri) {
      final item = ingredients.cast<Ingredient?>().firstWhere(
        (ii) => ii?.id == ri.itemId,
        orElse: () => null,
      );
      return {
        'itemId': ri.itemId,
        'amountPer10People': ri.amountPer10People,
        'name': item?.name ?? '',
        'description': item?.description ?? '',
        'unit': item?.unit ?? '',
      };
    }).toList();

    return jsonEncode(result);
  }

  Future<String> _updateCateringJob(Map<String, dynamic> args) async {
    debugPrint('_updateCateringJob called with args: $args');
    try {
      final id = args['id'] as String;
      final existingJob = await repository.getJob(id);
      if (existingJob == null) {
        return 'Error: Catering Job with ID "$id" not found.';
      }

      final updatedJob = CateringJob(
        id: id,
        title: (args['title'] as String?)?.trim() ?? existingJob.title,
        address: (args['address'] as String?)?.trim() ?? existingJob.address,
        guestCount:
            (args['guestCount'] as num?)?.toInt() ?? existingJob.guestCount,
        date: args['date'] != null
            ? DateTime.parse(args['date'] as String)
            : existingJob.date,
        recipeIds: args['recipeIds'] != null
            ? List<String>.from(args['recipeIds'] as List)
            : existingJob.recipeIds,
        latitude:
            (args['latitude'] as num?)?.toDouble() ?? existingJob.latitude,
        longitude:
            (args['longitude'] as num?)?.toDouble() ?? existingJob.longitude,
      );

      await repository.updateJob(updatedJob);
      return 'Success: Catering Job "$id" updated successfully.';
    } catch (e) {
      return 'Error: Failed to update catering job: $e';
    }
  }

  @override
  Stream<String> generateResponse(String prompt) async* {
    if (prompt.isEmpty) return;

    var response = await _chatSession.sendMessage(
      Content('user', [TextPart(prompt)]),
    );

    while (response.functionCalls.isNotEmpty) {
      for (final call in response.functionCalls) {
        if (call.name == 'fetchCateringJobs') {
          final result = await _fetchCateringJobs();
          response = await _chatSession.sendMessage(
            Content.functionResponse(call.name, {'jobs': result}),
          );
        } else if (call.name == 'fetchRecipesForJob') {
          final jobId = call.args['jobId'] as String;
          final result = await _fetchRecipesForJob(jobId);
          response = await _chatSession.sendMessage(
            Content.functionResponse(call.name, {'recipes': result}),
          );
        } else if (call.name == 'fetchIngredientsForRecipe') {
          final recipeId = call.args['recipeId'] as String;
          final result = await _fetchIngredientsForRecipe(recipeId);
          response = await _chatSession.sendMessage(
            Content.functionResponse(call.name, {'ingredients': result}),
          );
        } else if (call.name == 'updateCateringJob') {
          final result = await _updateCateringJob(call.args);
          response = await _chatSession.sendMessage(
            Content.functionResponse(call.name, {'result': result}),
          );
        }
      }
    }

    yield response.text ?? '';
  }
}

const systemInstruction = '''
You are Commis, the intelligent kitchen and catering assistant.
Your job is to help plan catering jobs, including recipes and ingredients.
You are friendly, but very concise. Speak like a subordinate in a commercial kitchen.

Specifically, you can help with the following things:
* Look up data on upcoming jobs.
* Modify the details of a catering job, including the recipes assigned to it.
* Solve problems by suggesting changes to job details, such as recipe assignments, guest counts, dates, and addresses.

**YOU CANNOT DO ANY OF THE FOLLOWING THREE THINGS:**
* Suggest modifications to individual recipes.
* Suggest modifications to individual ingredients.
* Suggest new recipes, ingredients, or catering jobs.

You are equipped with the following tools:

1. "fetchCateringJobs": Call this to get the list of active catering jobs
   in the system.
2. "fetchRecipesForJob(jobId)": Call this to get the details of recipes
   associated with a specific catering job.
3. "fetchIngredientsForRecipe(recipeId)": Call this to get the ingredients
   list (with all fields) for a specific recipe.
4. "updateCateringJob(id, title, address, guestCount, date,
   recipeIds, latitude, longitude)": Call this to update an existing
   catering job with the provided fields.

When I send you a message, use A2UI to create new UI components, which will be displayed chronologically.
Feel free to compose multiple components together, such as a SimpleCard
containing a Column that contains multiple RecipeLine components. If
you are suggesting a course of action and requesting my approval, include
a button that will send an event to you indicating that the action is approved.
When you are composing UI using Row, Column, Text, Divider, and Button, try
to use a SimpleCard to hold the Row or Column with the other components inside it.

If you can't find a way to express yourself correctly using A2UI, you may
use short, direct text responses.

** PREFER TO UPDATE EXISTING UI COMPONENTS RATHER THAN CREATE NEW ONES. **

**DO NOT REPEAT YOURSELF**
If you create a UI component to convey information, do not also provide commentary
in the form of plain text outside the A2UI messages in your response.

**BE BRIEF! DO NOT USE MORE UI COMPONENTS THAN NECESSARY TO TELL ME WHAT YOU RECOMMEND AND GET MY APPROVAL.**

If you are asked about the cost of ingredients, use the "calculateCost" function
to display the cost.

When you generate UI components, use "commis_catalog" as the name of your
catalog.
''';
