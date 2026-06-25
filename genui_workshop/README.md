# genui_workshop

## Step 1: Set up Firebase

### Create a Firebase project
1.  Sign into the [Firebase console](https://console.firebase.google.com/)
    using your Google Account.

1.  Click the button to create a new project, and then enter a project name
    (for example, `GenUI Workshop`).<br>

1.  Click **Continue**.

1.  If prompted, review and accept the Firebase terms, and then click
    **Continue**.

1.  Click **Create project**, wait for your project to provision, and then click
    **Continue**.

### Enable Firebase AI Logic

To enable Firebase AI Logic in your Firebase project:

1.  In the Firebase console, go to **AI Services** >
    [**AI Logic**](https://console.firebase.google.com/project/_/ailogic/).

1.  Click **Get started**.

1.  Choose to use the _Gemini Developer API_ by clicking
    **Get started with this API**.

1.  Click **Enable API** and confirm.

## Step 2: Activate Cloud Shell

Cloud Shell space is persistent between projects so make sure you are creating things in proper project directories.

## Step 3: Creating the Flutter project

Cloud shell needs to link to the stored version of Flutter so we need the following command before running `flutter`.

```shell
git config --global --add safe.directory /google/flutter
```

We'll be starting with an empty project and adding code as we go. Warning that this might take a little while on Cloud Shell.

```shell
flutter create --empty genui_workshop
```

Next we can attach our local code to the previously created project with `flutterfire`. We only need the web target.

```shell
dart pub global activate flutterfire_cli
export PATH="$PATH":"$HOME/.pub-cache/bin"

cd genui_workshop
flutterfire configure
```
Select the project you just created;
deselect all but web

```shell
flutter pub add genui firebase_core firebase_ai json_schema_builder
```

Let's run the app. 

Cloud shell doesn't allow `flutter run -d chrome` by default so we will test it by building the web target and starting a server.
```shell
flutter build web
python -m http.server 8080 --directory build/web
```

## Step 4: Setup GenUI scaffolding.

Create `lib/genui_utils.dart`
```dart
sealed class ConversationItem {}

class TextItem extends ConversationItem {
  final String text;
  final bool isUser;
  TextItem({required this.text, this.isUser = false});
}
```

Create `lib/message_bubble.dart`.
```dart
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bubbleColor = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    final textColor = isUser
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    gradient: isUser
                        ? LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withAlpha(200),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

```

Paste the following to `main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui_workshop/message_bubble.dart';
import 'package:genui_workshop/genui_utils.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Today',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ConversationItem> _items = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.1-flash-lite',
    );
    _chatSession = model.startChat();
    _chatSession.sendMessage(Content.text(systemInstruction));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _addMessage() async {
    final text = _textController.text;

    if (text.trim().isEmpty) {
      return;
    }
    _textController.clear();

    setState(() {
      _items.add(TextItem(text: text, isUser: true));
    });

    _scrollToBottom();

    final response = await _chatSession.sendMessage(Content.text(text));

    if (response.text?.isNotEmpty ?? false) {
      setState(() {
        _items.add(TextItem(text: response.text!, isUser: false));
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in _items)
                  switch (item) {
                    TextItem() => MessageBubble(
                      text: item.text,
                      isUser: item.isUser,
                    ),
                  },
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _addMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addMessage,
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```


Add the system instruction to `genui_utils.dart`.
```dart
 const systemInstruction = '''
  ## PERSONA
  You are a meteorologist.

  ## GOAL
  Work with me to produce of weather forecasts.

  ## RULES

  Do not offer opinions unless I ask for them.

  ## PROCESS
  ### Planning
  *   Ask me for a location to check the weather.
  *   Follow up and ask for a date if not provided.
  *   Synthesize a list of weather forecasts from the provided information.
  *   Where available, you will use tool calls to retreive the info (not implemented yet)
  *   Advise if you are pulling the data from a real source or making it up.
  *   Ask clarifying questions if you need to.
  *   Respond to my suggestions for changes to date or location, if I have any.
''';
```

Run the app.
It runs and responds with weather information, but no generative UI yet.

## Integrate GenUI package
Add the following to `genui_utils.dart`
```dart
class SurfaceItem extends ConversationItem {
  final String surfaceId;
  SurfaceItem({required this.surfaceId});
}

```

In `main.dart`, add a case for the `SurfaceItem` type to the ListView `build` method:
```dart
Expanded(
  child: ListView(
    controller: _scrollController,
    padding: const EdgeInsets.all(16),
    children: [
      for (final item in _items)
        switch (item) {
          TextItem() => MessageBubble(
            text: item.text,
            isUser: item.isUser,
          ),
          // New!
          SurfaceItem() => Surface(
            surfaceContext: _controller.contextFor(
              item.surfaceId,
            ),
          ),
        },
    ],
  ),
),
```


At the top of lib/main.dart, import the genui library:
```dart
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;
```


Add the following lifecycle controllers and adapters to `main.dart`
```dart
class _MyHomePageState extends State<MyHomePage> {
  // ... existing members
  late final ChatSession _chatSession;

  // Add GenUI controllers
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  late final Catalog catalog;
```

Run the app.

Update `_addMessage` and `sendAndReceive` like in code lab.

```dart
  Future<void> _addMessage() async {
    final text = _textController.text;

    if (text.trim().isEmpty) {
      return;
    }

    _textController.clear();

    setState(() {
      _items.add(TextItem(text: text, isUser: true));
    });

    _scrollToBottom();

    // Send the user's input through GenUI instead of directly to Firebase.
    await _conversation.sendRequest(ChatMessage.user(text));
  }
```

```dart
  Future<void> _sendAndReceive(ChatMessage msg) async {
    final buffer = StringBuffer();

    // Reconstruct the message part fragments
    for (final part in msg.parts) {
      if (part.isUiInteractionPart) {
        buffer.write(part.asUiInteractionPart!.interaction);
        print(part.asUiInteractionPart!.interaction);
      } else if (part is genui.TextPart) {
        buffer.write(part.text);
      }
    }

    if (buffer.isEmpty) {
      return;
    }

    final text = buffer.toString();

    // Send the string to Firebase AI Logic.
    final response = await _chatSession.sendMessage(Content.text(text));

    if (response.text?.isNotEmpty ?? false) {
      // Feed the response back into GenUI's transportation layer
      _transport.addChunk(response.text!);
    }
  }
```

### Wire up A2UI

Add to the end of initState.
```dart
    // remove this line
    //  _chatSession.sendMessage(Content.text(systemInstruction));

    // Initialize the GenUI Catalog.
    // The genui package provides a default set of primitive widgets (like text
    // and basic buttons) out of the box using this class.
    catalog = BasicCatalogItems.asCatalog().copyWith(
//      newItems: [weatherInput, weatherCard],
    );

    // Create a SurfaceController to manage the state of generated surfaces.
    _controller = SurfaceController(catalogs: [catalog]);

    // Create a transport adapter that will process messages to and from the
    // agent, looking for A2UI messages.
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);

    // Link the transport and SurfaceController together in a Conversation,
    // which provides your app a unified API for interacting with the agent.
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    // Listen to GenUI stream events to update the UI
    _conversation.events.listen((event) {
      setState(() {
        switch (event) {
          case ConversationSurfaceAdded added:
            _items.add(SurfaceItem(surfaceId: added.surfaceId));
            _scrollToBottom();
          case ConversationSurfaceRemoved removed:
            _items.removeWhere(
              (item) =>
                  item is SurfaceItem && item.surfaceId == removed.surfaceId,
            );
          case ConversationContentReceived content:
            _items.add(TextItem(text: content.text, isUser: false));
            _scrollToBottom();
          case ConversationError error:
            debugPrint('GenUI Error: ${error.error}');
          default:
        }
      });
    });

    // Create the system prompt for the agent, which will include this app's
    // system instruction as well as the schema for the catalog.
    final promptBuilder = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: [systemInstruction],
    );

    // Send the prompt into the Conversation, which will subsequently route it
    // to Firebase using the transport mechanism.
    _conversation.sendRequest(
      ChatMessage.system(promptBuilder.systemPromptJoined()),
    );
```

We could explore doing some progress indicator UI here or not.

## Make weather input widget
The components it picks is random and can't be submitted sometimes

Create a `lib/catalog` directory. One file per item with the schema included.

Add the following to `lib/catalog/weather_input.dart`
```dart
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final simpleWeatherSchema = S.object(
  properties: {
    'location': S.string(description: 'The location to check the weather.'),
    'date': S.string(description: 'The date to check the weather.'),
  },
);

// Example raw action
//{version: v0.9, action: {name: submit_weather_request, sourceComponentId: submitButton,
//timestamp: 2026-05-26T22:10:19.087, context: {}, surfaceId: weather_input_surface}}
final weatherInput = CatalogItem(
  name: 'WeatherInput',
  dataSchema: simpleWeatherSchema,
  widgetBuilder: (itemContext) {
    final json = itemContext.data as Map<String, Object?>;
    final data = SimpleWeatherData.fromJson(json);
    return WeatherInput(
      data: data,
      onFetchRequest: (loc, date) async {
        final JsonMap resolvedContext = await resolveContext(
          itemContext.dataContext,
          {'location': loc, 'date': date.toString()},
        );
        itemContext.dispatchEvent(
          UserActionEvent(
            name: 'submit_weather_request',
            sourceComponentId: 'submitButton',
            timestamp: DateTime.now(),
            context: resolvedContext
          ),
        );
      },
    );
  },
);

class SimpleWeatherData {
  String location;
  DateTime date;

  SimpleWeatherData({required this.location, required this.date});

  factory SimpleWeatherData.defaultValues() {
    return SimpleWeatherData(location: 'Baltimore', date: DateTime.now());
  }

  factory SimpleWeatherData.fromJson(Map<String, Object?> json) {
    if (json.isNotEmpty) {
      return SimpleWeatherData(
        location: json['location'] as String,
        date: DateTime.parse(json['date'] as String),
      );
    } else {

    return SimpleWeatherData(location: 'Baltimore', date: DateTime.now());
    }
  }
}

class WeatherInput extends StatefulWidget {
  final SimpleWeatherData data;
  final void Function(String, DateTime) onFetchRequest;

  const WeatherInput({
    super.key,
    required this.data,
    required this.onFetchRequest,
  });

  @override
  State<WeatherInput> createState() => _WeatherInputState();
}

class _WeatherInputState extends State<WeatherInput> {
  late TextEditingController _controller;
  DateTime? selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().copyWith(month: 1, day: 1),
      lastDate: DateTime.now().copyWith(month: 12, day: 31),
    );

    setState(() {
      selectedDate = pickedDate;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Location", style: TextStyle(fontWeight: FontWeight.bold) ),
              const SizedBox(height: 8),
              TextField(decoration: InputDecoration(border: OutlineInputBorder()), controller: _controller,),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {

            widget.onFetchRequest(_controller.text, selectedDate!);
                  },
                  child: const Text("Get Forecast", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Add `weatherInput` as a new item in the basic catalog by importing it and adding it to `newItems` in `lib/main.dart`:

```dart
import 'package:genui_workshop/catalog/weather_input.dart';
// ...
    catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [weatherInput],
    );
```

Change the system prompt to point it to the catalog item.
Add this to end of the system instruction prompt:

```dart

  ## USER INTERFACE
  * To request the location to retreive weather, create an instance of the WeatherInput
  catalog item.
```

Create a file called `lib/catalog/weather_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:genui_workshop/genui_utils.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'dart:io';

import 'dart:convert';
import 'fake_forecast.dart';

final forecastSchema = S.object(
  properties: {
    'area_name': S.string(),
    //"flags": S.object(),
    'current_condition': S.object(
      properties: {
        "temp_C": S.number(),
        "temp_F": S.number(),
        "humidity": S.number(),
        "observation_time": S.string(),
      },
    ),
    'weatherDesc': S.string(),
    'weatherIconUrl': S.string(),
  },
);

final weatherCard = CatalogItem(
  name: 'WeatherCard',
  dataSchema: forecastSchema,
  widgetBuilder: (itemContext) {
    return WeatherCard(data: itemContext.data as Map<String, Object?>);
  },
);

class WeatherCard extends StatelessWidget {
  final Map<String, Object?> data;
  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentCondition = data["current_condition"] as Map<String, Object?>;
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: .end,
                children: [
                  Text(
                    "Observed at ${currentCondition["observation_time"]}",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Header: Icon and City Name
              Row(
                children: [
                  Image.network(
                    data["weatherIconUrl"].toString(),
                    errorBuilder: (context, err, trace) {
                        return Icon(Icons.wb_sunny, size: 32,);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    data["area_name"].toString(),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Temperature Display
              Row(
                children: [
                  Text(
                    currentCondition["temp_C"]!.toString(),
                    style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "°C",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Low Temp row
              Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    currentCondition['temp_F'].toString(),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "°F",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather Condition
              Text("${data['weatherDesc']}", style: TextStyle(fontSize: 22)),
            ],
          ),
        ),
      ),
    );
  }
}
```

Add the `weatherCard` item to your catalog inside `lib/main.dart`:

```dart
import 'package:genui_workshop/catalog/weather_card.dart';
// ...
    catalog = BasicCatalogItems.asCatalog().copyWith(
      newItems: [weatherInput, weatherCard],
    );
```

Create a file called `lib/catalog/fake_forecast.dart`
```dart
var fakeForecast = {
  'area_name': 'Baltimore (Mount Clare)',
  'current_condition': {
    'temp_C': 22,
    'temp_F': 72,
    'humidity': 61,
    'observation_time': '02:25 PM',
  },
  'weatherDesc': ' Sunny',
  'weatherIconUrl':
      'https://cdn.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png',
};
```

Run the app.

## Learn more

For more information and detailed references on the technologies used in this workshop, check out the following resources:

- **Flutter**: Discover guides, tutorials, and widget references at the [Official Flutter Documentation](https://docs.flutter.dev).
- **Firebase AI Logic**: Learn how to securely integrate generative AI models directly into your web and mobile apps on the [Firebase AI Logic Documentation](https://firebase.google.com/docs/ai-logic).
- **A2UI Protocol**: Understand the Agent-to-User Interface protocol specification and ecosystem at the [A2UI Official Site](https://a2ui.org).
- [**GenUI SDK for Flutter**](https://docs.flutter.dev/ai/genui)
