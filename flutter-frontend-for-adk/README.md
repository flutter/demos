# Flutter Frontend for ADK Agents (Custom Skill)

This repository contains a skill intended for use with [Antigravity](https://antigravity.google). It will guide the agent through the discovery, architecture, design, and implementation of a Flutter-based frontend for an Agent Development Kit (ADK) agent written in Python.

> [!NOTE]
> This repository is a learning resource and an open-source sample. Use it with an experimental project as a way of learning how to use Antigravity to get things done with Flutter.

---

## Capabilities

The `flutter-frontend-for-adk` skill orchestrates a structured, multi-phase workflow to construct a responsive Flutter client that interfaces with an ADK Python agent:

1. **Workspace & Agent Discovery:** Maps the agent's purpose, sub-agent hierarchy, API endpoints, event streams, and human-in-the-loop triggers.
2. **Frontend Usage & Behavior:** Defines target platforms (mobile, web, desktop), user experience flows, and screen requirements.
3. **Frontend Architecture:** Establishes directory structure, state management using the `provider` package, and manual JSON serialization models.
4. **Frontend Design & Layout:** Configures visual styles, responsive column layouts, interactive states, and micro-animations.
5. **Scaffolding & Implementation:** Scaffolds the Flutter project, implements the API service (handling REST and Server-Sent Events/SSE streams), and builds the views.
6. **Workspace Integration:** Integrates frontend execution commands into workspace build tools (e.g., Makefiles, script runners) and updates version control settings.

---

## Installation

To make this skill available to Antigravity, you can install it either globally or locally within a specific workspace.

### Global Installation

To make the skill available across all your projects, copy this repository into your global Antigravity customizations directory:

```bash
mkdir -p ~/.gemini/config/skills/flutter-frontend-for-adk
cp -r . ~/.gemini/config/skills/flutter-frontend-for-adk
```

### Local Project Installation

To make the skill available only within a specific project, copy this repository into the `.agents/skills` directory at the root of that project:

```bash
mkdir -p /path/to/your/project/.agents/skills/flutter-frontend-for-adk
cp -r . /path/to/your/project/.agents/skills/flutter-frontend-for-adk
```

Once copied, Antigravity will automatically discover the skill via its `SKILL.md` definition.

---

## Step-by-Step Usage Example

This section outlines how to use the skill to replace an existing web frontend with a Flutter client, using the official `deep_search` ADK sample agent as an example.

### 1. Clone the ADK Samples Repository
Clone the official repository containing the Agent Development Kit samples to your local machine:

```bash
git clone https://github.com/google/adk-samples.git
cd adk-samples
```

### 2. Open the Target Sample
Navigate to the Python version of the `deep_search` sample and open it in your workspace:

```bash
cd python/deep_search
```

Ensure this directory is open in your IDE workspace where Antigravity is active.

### 3. Remove the Existing Frontend
Prompt Antigravity to remove the React-based frontend that is bundled with the sample. This ensures a clean slate for the new Flutter application.

You can use a prompt such as:
> "Please remove the React frontend that ships with this sample, along with any mention of it in associated documentation, configuration files, and build scripts."

Antigravity will delete the React source files, remove web-related dependencies, and clean up workspace references.

### 4. Generate the Flutter Frontend
Once the workspace is cleaned, instruct Antigravity to use the installed custom skill to build a new Flutter frontend.

You can use a prompt such as:
> "Please use the `flutter-frontend-for-adk` skill to create a new, Flutter-based frontend for the agent."

Antigravity will activate the skill and proceed through the six phases described in the [SKILL.md](SKILL.md) file, prompting you for input and approval at the end of each phase before continuing to the next.
