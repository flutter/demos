// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:commis/ui/catalog/client_functions.dart';
import 'package:commis/ui/catalog/simple_card.dart';
import 'package:genui/genui.dart';

import 'catering_job.dart';
import 'ingredient_line.dart';
import 'navigation_card.dart';
import 'recipe_line.dart';

// --- The Commis Catalog ---

final commisCatalog =
    Catalog(
      [
        cateringJobItem,
        recipeLineCatalogItem,
        ingredientLineCatalogItem,
        navigationCardCatalogItem,
        simpleCardCatalogItem,
      ],
      functions: [CalculateCostFunction()],
      catalogId: 'commis_catalog',
    ).copyWith(
      newItems: [
        BasicCatalogItems.column,
        BasicCatalogItems.text,
        BasicCatalogItems.button,
        BasicCatalogItems.row,
        BasicCatalogItems.divider,
      ],
    );
