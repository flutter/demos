---
name: tdd-dart-workflow
description: "Rules, constraints, boundaries, and best practices for the multi-agent Python to Dart porting workflow."
---

# Python to Dart Porting Implementation Rules

These rules govern the development, design, and TDD workflow of porting a Python library to Dart. All agents running in this workspace must adhere strictly to these guidelines.

---

## 1. Multi-Agent TDD Workflow

Development proceeds in structured TDD cycles coordinated by the parent agent:

### Phase 0: Discovery & Architecture Blueprinting
* **Objective**: The Architect maps Python paradigms to Dart and produces `<dart_package_dir>/specs/architecture_blueprint.md`.
* **Gate**: The User must explicitly approve the blueprint before TDD cycles begin.

### Phase 1: Design Specification
* **Objective**: The Architect writes a targeted spec sheet under `<dart_package_dir>/specs/` (e.g. `<dart_package_dir>/specs/<module_name>_spec.md`) describing the interfaces, types, behaviors, and expected test cases for a single module.

### Phase 2: Write Failing Tests & Skeleton (Red Phase)
* **Step 2a (Tester)**: Writes unit tests in `<dart_package_dir>/test/` based on the spec (compilation errors targeting missing classes are expected here).
  * **Rule (Test Fakes vs Stubs)**: Label fakes/mocks kept permanently inside the test file as `// TEST UTILITIES - KEEP PERMANENTLY`. Label temporary stub classes that will be moved to `lib/` as `// SKELETON STUBS FOR COMPILATION - DELETE ONCE SKELETON IS IMPLEMENTED`.
* **Step 2b (Coder)**: Creates a skeleton (stub implementation) in `<dart_package_dir>/lib/src/` defining all required classes, constructors, methods, and properties, but returning dummy values or throwing `UnimplementedError()`.
* **Verification**: The Coordinator runs `dart test` and verifies the test compiles successfully and fails on execution due to `UnimplementedError` or assertion failure, NOT syntax or import errors.
  * **Clean Up**: Once the Coder implements the skeleton, the Coordinator removes the compilation stubs from the test file while preserving the permanent test utilities.

### Phase 3: Implement & Make Pass (Green Phase)
* **Objective**: The Coder reads the spec and test, and updates the library implementation in `<dart_package_dir>/lib/` to make all tests pass.
* **Verification**: The Coordinator runs `dart test` and verifies the tests pass successfully.

### Phase 4: Commit & Record
* **Objective**: The Coordinator stages and commits both the new test and the code.

### Phase 5 & 6: Integration & Documentation
* Port Python examples to `<dart_package_dir>/example/` (Treated as Integration Tests) and create the developer-facing skill documentation in `<dart_package_dir>/skills/`.

---

## 2. Agent Constraints & Boundaries

To preserve strict roles, agents are restricted to write to specific directories:

| Agent Role | Allowed Read Path | Allowed Write Path | Forbidden Actions |
|---|---|---|---|
| **Coordinator (Parent)** | Anywhere | Anywhere | Direct code modifications (delegates to Coder/Tester instead) |
| **Architect** | Anywhere | `<dart_package_dir>/specs/`, `skills/` | Cannot write to `<dart_package_dir>/lib/`, `<dart_package_dir>/test/`, or `<dart_package_dir>/example/` |
| **Tester** | Anywhere | `<dart_package_dir>/test/`, `<dart_package_dir>/example/` | Cannot write to `<dart_package_dir>/lib/` or `<dart_package_dir>/specs/` |
| **Coder** | Anywhere | `<dart_package_dir>/lib/`, `<dart_package_dir>/example/` | Cannot write to `<dart_package_dir>/test/` or `<dart_package_dir>/specs/` |

*Note: The Coordinator is the only agent allowed to execute Git operations or run arbitrary tests in the shell.*

---

## 3. Git Commit Rules

- **Execution**: Only the Coordinator agent (or the user) runs Git commands. Subagents have no Git permissions.
- **Timing**: Commits are made only when a TDD cycle is successfully completed (tests are Green) or a refactoring pass is verified. No commits of broken code.
- **Formatting**: Must adhere to the `git-commit-workflow` rules:
  - Capitalize the first word.
  - Keep under 60 characters.
  - Pithy, paratactic descriptions (e.g., `Add AgentConfig properties, write unit tests`).

---

## 4. Dart Best Practices

- **Strict Types**: Always use explicit type annotations for public APIs (no raw `dynamic` unless required by external JSON parsing). Avoid `dynamic` collections (use generics or shared interface classes).
- **Asynchrony**: Use Dart `Future` for async values and `Stream` for streaming data (e.g. async event stream).
- **Unit Testing**: Use `package:test` for writing tests. Place tests in `<dart_package_dir>/test/` mirroring the structure of `<dart_package_dir>/lib/src/`.
- **Formatting & Analysis**: Run `dart format .` and `dart analyze` inside `<dart_package_dir>/` before verifying implementations.
- **Code Generation**: Use `package:json_serializable` or `freezed` via `build_runner` for serialization. Avoid writing custom JSON parser logic unless necessary.
- **Mocking**: Use structured mocking libraries like `package:mocktail` or `package:mockito` instead of patching dynamic properties.
- **Abstract Interface Pattern**: Instead of dynamic property/method checks (`hasattr`), use Dart `abstract interface class` definitions, or explicit callback delegates to achieve same results type-safely.
- **Iterable Custom Builders**: If a custom builder class represents a list or collection of items that Python would unpack/spread, make the class implement `Iterable<T>` (forwarding its iterator to the underlying list) or expose an explicit collection getter (e.g. `.transitions`, `.items`) so that Dart's spread operator (`...`) can be used cleanly in configurations.
