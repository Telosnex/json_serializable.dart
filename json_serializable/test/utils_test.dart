// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('vm')

import 'package:test/test.dart';

import 'package:json_serializable/src/utils.dart';

const _items = {
  'simple': 'simple',
  'twoWords': 'two-words',
  'FirstBig': 'first-big'
};

void main() {
  group('kebab', () {
    for (final entry in _items.entries) {
      test('"${entry.key}"', () {
        expect(kebabCase(entry.key), entry.value);
      });
    }
  });

  group('snake', () {
    for (final entry in _items.entries) {
      test('"${entry.key}"', () {
        expect(snakeCase(entry.key), entry.value.replaceAll('-', '_'));
      });
    }
  });
}