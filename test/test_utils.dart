// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

String _packagePathCache;

String getPackagePath() {
  if (_packagePathCache == null) {
    // Getting the location of this file – via reflection
    var currentFilePath = (reflect(getPackagePath) as ClosureMirror)
        .function
        .location
        .sourceUri
        .path;

    _packagePathCache = p.normalize(p.join(p.dirname(currentFilePath), '..'));
  }
  return _packagePathCache;
}

Matcher throwsInvalidGenerationSourceError(messageMatcher, todoMatcher) =>
    throwsA(allOf(
        new isInstanceOf<InvalidGenerationSourceError>(),
        new FeatureMatcher<InvalidGenerationSourceError>(
            'todo', (e) => e.todo, todoMatcher),
        new FeatureMatcher<InvalidGenerationSourceError>(
            'message', (e) => e.message, messageMatcher)));

// TODO(kevmoo) add this to pkg/matcher – is nice!
class FeatureMatcher<T> extends CustomMatcher {
  final dynamic Function(T value) _feature;

  FeatureMatcher(String name, this._feature, matcher)
      : super("`$name`", "`$name`", matcher);

  featureValueOf(covariant T actual) => _feature(actual);
}

/// Returns all of the declarations in [unit], including [unit] as the first
/// item.
Iterable<Element> getElementsFromLibraryElement(LibraryElement unit) sync* {
  yield unit;
  for (var cu in unit.units) {
    for (var compUnitMember in cu.unit.declarations) {
      yield* _getElements(compUnitMember);
    }
  }
}

Iterable<Element> _getElements(CompilationUnitMember member) {
  if (member is TopLevelVariableDeclaration) {
    return member.variables.variables
        .map(resolutionMap.elementDeclaredByVariableDeclaration);
  }
  var element = resolutionMap.elementDeclaredByDeclaration(member);

  if (element == null) {
    print([member, member.runtimeType, member.element]);
    throw new Exception('Could not find any elements for the provided unit.');
  }

  return [element];
}