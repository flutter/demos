// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:commis/services/cost_service.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class CalculateCostFunction extends SynchronousClientFunction {
  const CalculateCostFunction();

  @override
  String get name => 'calculateCost';

  @override
  String get description =>
      'Calculates the cost for a certain quantity '
      'of an ingredient. Returns a formatted dollar string (i.e. \$4.50).';

  @override
  ClientFunctionReturnType get returnType => .string;

  @override
  Schema get argumentSchema => S.object(
    properties: {
      'ingredient_id': S.string(description: 'The ID of the ingredient.'),
      'quantity': S.number(description: 'The quantity of the ingredient.'),
    },
    required: ['ingredient_id', 'quantity'],
  );

  @override
  Object? executeSync(JsonMap args, ExecutionContext context) {
    final ingredientId = args['ingredient_id'].toString();
    final quantity = num.tryParse(args['quantity'].toString())?.toDouble();

    if (quantity == null || quantity < 1) {
      return '\$0.00';
    }

    final cost = CostService().fetchPrice(ingredientId, quantity);
    return '\$${cost.toStringAsFixed(2)}';
  }
}
