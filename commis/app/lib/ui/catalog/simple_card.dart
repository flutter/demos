// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../theme.dart';

final _schema = S.object(
  description:
      'A visual container (card) that groups a single child widget. Can be used with a Column as its child.',
  properties: {'child': A2uiSchemas.componentReference()},
  required: ['child'],
);

extension type _SimpleCardData.fromMap(JsonMap _json) {
  factory _SimpleCardData({required String child}) =>
      _SimpleCardData.fromMap({'child': child});

  String get child {
    final Object? val = _json['child'];
    if (val is String) return val;
    throw ArgumentError('Invalid child: $val');
  }
}

final simpleCardCatalogItem = CatalogItem(
  name: 'SimpleCard',
  dataSchema: _schema,
  widgetBuilder: (itemContext) {
    final simpleCardData = _SimpleCardData.fromMap(itemContext.data as JsonMap);
    return Card(
      color: CommisColors.surfaceLevel1,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(
          color: CommisColors.borderLowContrast,
          width: 1.0,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: itemContext.buildChild(simpleCardData.child),
      ),
    );
  },
);
