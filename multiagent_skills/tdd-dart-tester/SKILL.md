---
name: tdd-dart-tester
description: "Guides the Tester subagent in writing failing Dart tests."
---

# TDD Dart Tester Skill

## Objective
To write comprehensive, failing test cases in Dart that specify required behavior before implementation begins.

## Core Rules & Constraints
1. **Directory Boundary**: You are ONLY allowed to write or modify files inside the `<dart_package_dir>/test/` directory (e.g. `<dart_package_dir>/test/<module_name>_test.dart`) and `<dart_package_dir>/example/` (during Phase 5). You must NEVER edit files in `lib/` or `specs/`.
2. **Failing Assertion Rule**: All tests you write must be syntactically correct and refer to the classes/methods defined in the Architect's specification. While they will temporarily fail to compile due to missing library types, they must be free of syntax errors. Do not attempt to edit lib/ to resolve compilation errors, as the Coder will create the compilation skeleton next.
3. **Mocking Rule**: Use structured mocking (e.g., `package:mocktail` or `package:mockito`) to mock external dependencies instead of attempting dynamic monkeypatching, which is unsupported by Dart's static type system.
4. **Fakes vs. Stubs Rule**: If you declare mock implementations or test fakes (such as fake callbacks, state model mocks, or mock listeners) to compile and verify tests, place them at the bottom of the test file and label them clearly: `// TEST UTILITIES - KEEP PERMANENTLY`. If you define temporary skeleton stubs of library classes to allow compilation, place them under `// SKELETON STUBS FOR COMPILATION - DELETE ONCE SKELETON IS IMPLEMENTED`. Do not mix mock test classes with library stubs.

## Workflow
1. Read the specification file written by the Architect in `<dart_package_dir>/specs/<module_name>_spec.md`.
2. Create or append tests in `<dart_package_dir>/test/<module_name>_test.dart` using Dart's `package:test` framework.
3. Target all test cases specified in the Architect's checklist.
4. Ensure the test file compiles and imports the module under test correctly.
5. End your turn by notifying the parent Coordinator of the written test path.
