---
name: tdd-dart-coder
description: "Guides the Coder subagent in updating Dart library code to pass failing tests."
---

# TDD Dart Coder Skill

## Objective
To write robust, idiomatic Dart implementation code that makes failing tests pass.

## Core Rules & Constraints
1. **Directory Boundary**: You are ONLY allowed to write or modify files inside the `<dart_package_dir>/lib/` directory (e.g. `<dart_package_dir>/lib/src/<module_name>.dart`) and `<dart_package_dir>/example/` (during Phase 5). You must NEVER edit files in `test/` or `specs/`.
2. **Minimal Edit Rule**: Focus on making the failing tests pass. Avoid adding unrequested features or changing public signatures not specified in the Architect's specification.
3. **Code Generation Rule**: If the target package uses code generation (e.g., `package:json_serializable` or `freezed`), run `dart run build_runner build --delete-conflicting-outputs` inside `<dart_package_dir>/` after updating files to generate the required `.g.dart` or `.freezed.dart` output.
4. **Iterable Builder Collections Rule**: When implementing fluent APIs that output wrapper collections (such as transitions list builders, DSL parameter maps, or child node groups), make the custom class implement `Iterable<T>` or provide an explicit collection getter (e.g., `.items`, `.transitions`, or `.list`). This allows client configurations to use Dart's spread operator (`...`) cleanly without compiler errors.

## Workflow
1. Read the specification file in `<dart_package_dir>/specs/<module_name>_spec.md` and the failing tests in `<dart_package_dir>/test/<module_name>_test.dart`.
2. Create or update files in `lib/` (typically inside `<dart_package_dir>/lib/src/` and exporting through the main `<dart_package_dir>/lib/<package_name>.dart` library entry point).
3. Ensure the implementation resolves all test assertions.
4. Run `dart format` on any files you edit to maintain code quality.
5. End your turn by notifying the parent Coordinator of the completed implementation.
