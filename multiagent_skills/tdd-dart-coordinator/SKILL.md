---
name: tdd-dart-coordinator
description: "Orchestrates the 3-agent TDD workflow for Dart development by defining and invoking specialized subagents (Architect, Tester, Coder)."
---

# TDD Dart Coordinator Skill

## Objective
To serve as the orchestrator parent agent, coordinating the handoffs between the Architect, Tester, and Coder subagents, and executing shell verifications and git commits.

## Workflow

### 1. Setup Phase
At the start of the session, define the three specialized subagents using the `define_subagent` tool:

*   **`tdd-dart-architect`**:
    *   **Description**: "Analyzes the Python source code and designs API specifications under specs/."
    *   **Prompt**: Use the system prompt defined in `.agents/skills/tdd-dart-architect/SKILL.md`.
*   **`tdd-dart-tester`**:
    *   **Description**: "Writes failing Dart unit tests under test/ based on Architect specifications."
    *   **Prompt**: Use the system prompt defined in `.agents/skills/tdd-dart-tester/SKILL.md`.
*   **`tdd-dart-coder`**:
    *   **Description**: "Implements Dart library code under lib/ to pass unit tests."
    *   **Prompt**: Use the system prompt defined in `.agents/skills/tdd-dart-coder/SKILL.md`.

### 2. Orchestration Loop (Per Roadmap Step)

For each step in the implementation roadmap:

#### Phase 1: Specification
1. Invoke the Architect subagent:
   `invoke_subagent(TypeName="tdd-dart-architect", Role="Architect", Prompt="Design the specification for <Roadmap Item> based on <python_package_dir>/<module_path>. Write it to <dart_package_dir>/specs/<module_name>_spec.md.")`
2. Wait for the Architect to write the specification and report back.

#### Phase 2: Write Failing Tests & Skeleton (Red Phase)
1. Invoke the Tester subagent to write tests:
   `invoke_subagent(TypeName="tdd-dart-tester", Role="Tester", Prompt="Read <dart_package_dir>/specs/<module_name>_spec.md and write comprehensive unit tests in <dart_package_dir>/test/<module_name>_test.dart. Do not modify any lib/ files.")`
2. Wait for the Tester to report back.
3. Invoke the Coder subagent to write a stub/skeleton:
   `invoke_subagent(TypeName="tdd-dart-coder", Role="Coder", Prompt="Read the specification at <dart_package_dir>/specs/<module_name>_spec.md and the tests at <dart_package_dir>/test/<module_name>_test.dart. Create a skeleton (stub implementation) in <dart_package_dir>/lib/src/ defining all classes, properties, constructors, and methods returning dummy values or throwing UnimplementedError() so that tests compile. Do not implement the logic yet.")`
4. Wait for the Coder to report back.
5. Run `dart analyze && dart test` via `run_command` in `<dart_package_dir>/`.
   - Verify the test compiles successfully and fails on execution due to UnimplementedError or failed assertions.
   - If there are syntax, import, or static analysis errors, run the Coder to fix the skeleton compilation.

#### Phase 3: Implement & Make Pass (Green Phase)
1. Invoke the Coder subagent:
   `invoke_subagent(TypeName="tdd-dart-coder", Role="Coder", Prompt="Read <dart_package_dir>/specs/<module_name>_spec.md and <dart_package_dir>/test/<module_name>_test.dart. Implement the required classes in <dart_package_dir>/lib/src/<module_name>.dart and export them in <dart_package_dir>/lib/<package_name>.dart. Make the tests pass. Do not modify test/ files.")`
2. Wait for the Coder to report back.
3. Run `dart analyze && dart test` via `run_command` in `<dart_package_dir>/`.
   - If static analysis or tests fail, send the error logs to the Coder and ask it to correct the code.
   - If all checks and tests pass, proceed to Phase 4.

#### Phase 4: Commit
1. Run the `git-commit-workflow` skill commands:
   - `git add .`
   - `git commit -m "Implement <Roadmap Item>, add unit tests"`
2. Notify the user of successful roadmap step completion.
