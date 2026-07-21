# Frontend Implementation Best Practices

This document provides concrete code patterns and best practices for assembling the Flutter agent client. These guidelines address common implementation challenges, security configuration, typography, and styling.

---

## 1. macOS and iOS Network Access & Security

### macOS Sandbox Outbound Connections
When building and testing native macOS Flutter applications, the app runs within a secure sandbox environment by default. If the app needs to fetch assets (like Google Fonts) or communicate with local or remote APIs, it must be granted explicit outbound network permissions.

#### Implementation Pattern
Locate the entitlements files inside the macOS runner directory:
*   `frontend/macos/Runner/DebugProfile.entitlements`
*   `frontend/macos/Runner/Release.entitlements`

Ensure that the key `com.apple.security.network.client` is defined and set to `true` within the `<dict>` block:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

### iOS App Transport Security (ATS)
Unlike macOS, iOS does not restrict outbound client network calls via sandbox entitlements files. However, Apple's **App Transport Security (ATS)** blocks insecure HTTP connections by default. If the application needs to make plaintext HTTP calls during development (e.g., connecting to a local backend agent server running on `http://127.0.0.1:8000` or `http://localhost:8000`), an exception must be configured.

#### Implementation Pattern
Locate the `Info.plist` file inside the iOS runner directory:
*   `frontend/ios/Runner/Info.plist`

Add the `NSAppTransportSecurity` dictionary with `NSAllowsLocalNetworking` set to `true` to allow local loopback and local network HTTP connections:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```

---

## 2. Rich Markdown Rendering

Agent response logs contain nested formatting, bold titles, lists, and code blocks. Plain text widgets are insufficient for displaying this nicely. Use `flutter_markdown` with customized typography rules that leverage the Outfit/Inter font system to maintain a premium feel.

> [!IMPORTANT]
> **Stream-Safe Markdown Formatting:** Make sure that any text field or streaming response that could include markdown formatting is properly formatted and "pretty printed" in real time using `MarkdownBody` instead of standard `Text` widgets, even while the message is incomplete and streaming.

### Implementation Pattern
Use `MarkdownBody` for rendering single message blocks and wrap it in a customized `MarkdownStyleSheet`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildMarkdownMessage(BuildContext context, String text, Color textColor) {
  return MarkdownBody(
    data: text,
    selectable: true,
    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: GoogleFonts.inter(
        fontSize: 14,
        height: 1.45,
        color: textColor,
      ),
      strong: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      listBullet: GoogleFonts.inter(
        fontSize: 14,
        color: textColor,
      ),
    ),
  );
}
```

---

## 3. Dart Import Ordering & Formatting

To ensure code cleanliness, maintain structure, and comply with standard style rules, imports must be structured according to the `directives_ordering` rule.

### 1. Enable Linter Rule
Ensure that the `directives_ordering` rule is enabled in the project's [analysis_options.yaml](frontend/analysis_options.yaml):

```yaml
linter:
  rules:
    directives_ordering: true
```

### 2. Automated Import Organizing & Formatting
Instead of manually ordering imports, use the Dart SDK's built-in tools to automate this process. Run the following command inside the `frontend/` directory to automatically sort all imports and resolve auto-fixable lint issues:

```bash
dart fix --apply
```

To format all files according to standard style guidelines, run:

```bash
dart format .
```

---

## 4. Sealed Classes & Exhaustive Pattern Matching for Lists

Lists of messages or UI items from an agent run should be represented using Dart's `sealed` classes. Sealed classes restrict the inheritance hierarchy to the current library, enabling the analyzer to verify that `switch` statements and expressions are exhaustive (handling all possible types without needing a fallback/default clause).

### Implementation Pattern

1. **Define the Sealed Model Hierarchy**:
   Define a sealed base class representing conversation items, and declare concrete subclasses for each specific data type (e.g., text, tool output, system event, surface widgets):

   ```dart
   import 'package:flutter/widgets.dart';

   sealed class ConversationItem {}

   class TextItem extends ConversationItem {
     final String sender;
     final String text;

     TextItem({required this.sender, required this.text});
   }

   class ImageItem extends ConversationItem {
     final String url;

     ImageItem({required this.url});
   }
   ```

2. **Render Using Exhaustive Switch Expressions**:
   When building lists of items in a `ListView.builder`, map the items using a switch expression. This allows the compiler to enforce compile-time safety; if a new subclass of `ConversationItem` is added later, the compiler will fail to build until it is handled.

   ```dart
   Widget buildConversationList(List<ConversationItem> items) {
     return ListView.builder(
       itemCount: items.length,
       itemBuilder: (context, index) {
         final item = items[index];

         return switch (item) {
           TextItem(sender: final sender, text: final text) =>
             BuildTextMessageBubble(sender: sender, text: text),
           ImageItem(url: final url) =>
             BuildImageMessageBubble(url: url),
         };
       },
     );
   }
   ```

---

## 5. Scroll Position Anchoring (Guarding Viewport Yanking)

When rendering live message feeds, logs, or agent streaming output, the chat window should auto-scroll to the bottom only if the user is already actively looking at the bottom. If the user scrolls up manually to review history, incoming data must not yank their viewport back to the bottom.

### Implementation Pattern

1. **Calculate Scroll Position**:
   Track if the scroll position is currently at or near the bottom before laying out new items. Use a small threshold (such as `40` pixels) to account for layout variations.
2. **Conditional Animation**:
   Trigger the scroll-to-bottom callback only if the active session changed (which warrants a complete view reset) or if the user is already at the bottom and new content is added.

---

## 6. Timer Lifecycle and Resource Cleanup

If the frontend performs periodic background tasks (such as polling a health endpoint, status checks, or refreshing data), these timers must be managed safely to prevent memory leaks and exceptions when widgets are unmounted from the tree.

### Implementation Pattern

1. **Keep a Timer Handle**:
   Store the active `Timer` reference inside the state.
2. **Initialize in `initState`**:
   Start the periodic loop during the widget initialization phase.
3. **Cancel in `dispose`**:
   Cancel the timer in the `dispose` method. Always check if the state is still `mounted` before executing calls from background asynchronous triggers.

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class StatusMonitor extends StatefulWidget {
  const StatusMonitor({super.key});

  @override
  State<StatusMonitor> createState() => _StatusMonitorState();
}

class _StatusMonitorState extends State<StatusMonitor> {
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    // Periodically run background check
    _statusTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _runHealthCheck();
      }
    });
  }

  @override
  void dispose() {
    // Prevent memory leak by canceling active timers
    _statusTimer?.cancel();
    super.dispose();
  }

  void _runHealthCheck() {
    // Perform API call
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
```

---

## 7. Web & Cross-Platform Compatibility (Avoiding `dart:io` Pitfalls)

To ensure the client runs flawlessly on all target platforms (especially Flutter Web / Chrome), code must be structured to avoid platform-specific libraries that throw runtime exceptions in browsers.

### Avoid `dart:io` Imports and APIs
*   **HttpClient**: Do not import or use `HttpClient` or `Platform` from `dart:io`. Web browsers do not support these native socket-based operations, causing immediate runtime crashes like `Unsupported operation: Platform._version` or `Unsupported operation: HttpClient`.
*   **Cross-Platform Alternatives**: Always use standard cross-platform packages:
    *   Use `package:http` (e.g., `http.Client`) for network operations and SSE streams.
    *   Use `package:url_launcher` for opening links.
    *   Use `kIsWeb` from `package:flutter/foundation.dart` for checking if running on Web.

### Safe Platform Checks
If platform-specific logic is required, check `kIsWeb` first. Never access properties of the `Platform` class from `dart:io` on web targets:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform; // WARNING: Do not import/reference if building for web!

bool get isWebOrDesktop {
  if (kIsWeb) return true;
  // This is safe because Platform is only accessed when kIsWeb is false
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
```

*Best Practice:* Whenever possible, use UI responsiveness thresholds (like `LayoutBuilder` width constraints) to adapt screens, rather than hardcoding platform checks.

---

## 8. Server-Sent Events (SSE) Streaming vs. Completed Message Handling

When listening to a Server-Sent Events (SSE) stream from the ADK server, the client receives both partial chunk events (representing incremental text generation) and final completed events. To prevent duplicate, fragmented, or partial message bubbles from cluttering the conversation history, follow these guidelines:

### 1. Separate Stream States
*   **Partial Event Chunk (`event.partial == true`):** The text in these events represents active streaming data. Do **NOT** add these events to the permanent session event history list. Instead, accumulate the incoming characters inside temporary state variables (e.g., `activeStreamingResponse` and `activeStreamingAuthor`) in your state manager.
*   **Complete Event Chunk (`event.partial == false`):** Once a final event chunk is received, append it to the permanent session event history list and clear the temporary streaming state accumulators.

### 2. Implementation Pattern
Inside the stream receiver block in your state provider, handle the parsed events like so:

```dart
await for (final event in eventStream) {
  if (event.partial) {
    // Accumulate streaming text in temporary state variables
    _activeStreamingAuthor = event.author;
    _activeStreamingResponse = (_activeStreamingResponse ?? '') + (event.contentText ?? '');
  } else {
    // Stream chunk finished: Clear accumulator
    _activeStreamingResponse = null;
    _activeStreamingAuthor = null;

    // Append the completed event to conversation history list
    final updatedEvents = List<Event>.from(_activeSession!.events)..add(event);
    _activeSession = _activeSession!.copyWith(events: updatedEvents);

    // Apply state deltas if present
    if (event.actions.stateDelta.isNotEmpty) {
      _mergeStateDelta(event.actions.stateDelta);
    }
  }
  notifyListeners();
}
```

---

## 9. Casing Resiliency in JSON Deserialization (ADK Framework Discrepancy)

The ADK framework-level endpoints return camelCase keys (such as `invocationId`, `turnComplete`, `functionCall`) in `/run_sse` chunked streams, but return snake_case keys (such as `invocation_id`, `turn_complete`, `function_call`) in REST history responses. The parser must check for both casings to support all ADK-based agents.

### Implementation Pattern

When parsing fields that differ between streams and history, check both keys:

```dart
final fc = part['functionCall'] ?? part['function_call'];
final id = json['id'] ?? json['id'];
final invocationId = json['invocationId'] ?? json['invocation_id'];
```

---

## 10. Generic Tool Log Extraction (Built-in Grounding vs. Explicit Function Calls)

To ensure that the client can display the tool execution history of any ADK-based agent (including routing decisions, planning operations, or web searches), the frontend should parse all tool invocations generically rather than hardcoding checks for specific tool names (e.g. `google_search`).

### 1. Define a Generic `ToolCall` Model

```dart
class ToolCall {
  final String name;
  final Map<String, dynamic> arguments;

  ToolCall({required this.name, required this.arguments});

  String get displayString {
    if (name == 'google_search') {
      final q = arguments['query'] ??
          arguments['search_query'] ??
          arguments['searchQuery'] ??
          arguments['q'] ??
          '';
      return 'Google Search: "$q"';
    }
    // Format other tools nicely, e.g. "plan_generator(request: ...)"
    final argsStr = arguments.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
    return '$name($argsStr)';
  }
}
```

### 2. Implementation Pattern

In the `Event` deserializer, extract both internal Gemini grounding queries and explicit function calls from parts into the `toolCalls` list:

```dart
final List<ToolCall> calls = [];

// 1. Extract from grounding metadata (Gemini built-in search tool)
final gm = json['groundingMetadata'] ?? json['grounding_metadata'];
if (gm != null && gm is Map) {
  final wsq = gm['webSearchQueries'] ?? gm['web_search_queries'];
  if (wsq != null && wsq is List) {
    for (final q in wsq) {
      if (q != null) {
        calls.add(ToolCall(
          name: 'google_search',
          arguments: {'query': q.toString()},
        ));
      }
    }
  }
}

// 2. Extract from parts (for explicit/custom tool calls)
for (final part in partsList) {
  if (part is Map) {
    final fc = part['functionCall'] ?? part['function_call'];
    if (fc != null && fc is Map) {
      final name = fc['name'] as String? ?? 'unknown_tool';
      final args = fc['args'] != null && fc['args'] is Map
          ? Map<String, dynamic>.from(fc['args'] as Map)
          : <String, dynamic>{};
      calls.add(ToolCall(name: name, arguments: args));
    }
  }
}
```

