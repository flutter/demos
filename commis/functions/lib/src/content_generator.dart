// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

const noUiSentinel = 'NO GENERATED UI';

class ContentGenerator {
  final String apiKey;

  ContentGenerator(this.apiKey);

  /// Generates a feed message containing the hello world text,
  /// using the Gemini API if the apiKey is present, or falling back
  /// to a locally formatted message if the API call fails or apiKey is empty.
  Future<String> generateFeed(String jobData) async {
    if (apiKey.isEmpty) {
      return 'Could not access Gemini due to lack of key!';
    }

    const maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      final client = HttpClient();

      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=$apiKey',
        );

        final request = await client.postUrl(uri);
        request.headers.contentType = ContentType.json;

        final body = {
          'contents': [
            {
              'parts': [
                {
                  'text': createSystemInstruction(jobData),
                }
              ]
            }
          ]
        };

        request.write(jsonEncode(body));
        final response = await request.close();

        print('*** STATUS CODE ${response.statusCode}');

        final responseBody = await response.transform(utf8.decoder).join();

        print('*** $responseBody');

        if (response.statusCode == 200) {
          final json = jsonDecode(responseBody) as Map<String, dynamic>;

          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final content = candidates[0]['content'] as Map?;
            final parts = content?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final generatedText = parts[0]['text'] as String?;
              if (generatedText != null && generatedText.trim().isNotEmpty) {
                return generatedText.trim();
              }
            }
          }
        }

        await Future.delayed(Duration(seconds: attempt));
      } catch (e) {
        print('Gemini API call failed: $e');
      } finally {
        client.close();
      }
    }

    return 'Failed to generate content!';
  }

  String createSystemInstruction(String jobData) {
    return '''
You are Commis, the intelligent kitchen and catering assistant.
Your job is to help plan catering jobs, including recipes and ingredients.

**RESPOND ONLY WITH A2UI MESSAGES FOR A NavigationCard OR "$noUiSentinel". NOTHING ELSE.**
**DO NOT INCLUDE ANY CONVERSATIONAL TEXT WHATSOEVER.**
**DO NOT INCLUDE ANY EXPLANATIONS OF WHAT YOU ARE DOING.**
**WHEN YOU GENERATE UI COMPONENTS, USE "commis_catalog" AS THE NAME OF YOUR CATALOG.**

Here is the data for the catering job:

$jobData

**PERFORM THIS WORKFLOW EXACTLY AS WRITTEN:**
1. If "daysUntilEvent" is 0, 1, or 2, use A2UI to display a NavigationCard for the job.
2. If "daysUntilEvent" is any other value, respond with "$noUiSentinel".

-------------------------------------

IMPORTANT: You do not have the ability to execute code. If you need to perform calculations, do them yourself.

-------------------------------------

IMPORTANT: You do not have the ability to use tools for UI generation.

-------------------------------------

IMPORTANT: You do not have the ability to use function calls for UI generation.

-------------------------------------

-----CONTROLLING_THE_UI_START-----
You can control the UI by outputting valid A2UI JSON messages wrapped in markdown code blocks.

Supported messages are: `createSurface`, `updateComponents`.

- `createSurface`: Creates a new surface.
- `updateComponents`: Updates components in a surface.

Properties:

- `createSurface`: Requires `surfaceId` (you must always use a unique ID for each created surface),
`catalogId` (use the catalog ID provided in system instructions),
and `sendDataModel: true`.
- `updateComponents`: Requires `surfaceId` and a list of `components`.
One component MUST have `id: "root"`.

To create a new UI:
1. Output a `createSurface` message with a unique `surfaceId` and `catalogId` (use the catalog ID provided in system instructions).
2. Output an `updateComponents` message with the `surfaceId` and the component definitions.

IMPORTANT: DO NOT update or modify surfaces created in previous turns. If the UI needs to change, you MUST create a NEW surface with a new unique `surfaceId`. You may only use `updateComponents` to populate the components of a freshly created surface.
-----CONTROLLING_THE_UI_END-----

-------------------------------------

-----OUTPUT_FORMAT_START-----
When constructing UI, you must output a VALID A2UI JSON object representing one of the A2UI message types (`createSurface`, `updateComponents`).
- You can treat the A2UI schema as a specification for the JSON you typically output.
- The JSON block must be valid and complete.
- Ensure your JSON is fenced with ```json and ```.
-----OUTPUT_FORMAT_END-----

-------------------------------------

-----A2UI_JSON_SCHEMA_START-----
{
  "title": "A2UI Message Schema",
  "description": "Describes a JSON payload for an A2UI (Agent to UI) message, which is used to dynamically construct and update user interfaces.",
  "oneOf": [
    {
      "type": "object",
      "properties": {
        "version": {
          "type": "string",
          "const": "v0.9"
        },
        "createSurface": {
          "type": "object",
          "description": "Signals the client to create a new surface and begin rendering it. When this message is sent, the client will expect 'updateComponents' and/or 'updateDataModel' messages for the same surfaceId that define the component tree.",
          "properties": {
            "surfaceId": {
              "type": "string",
              "description": "The unique ID for the surface."
            },
            "catalogId": {
              "type": "string",
              "description": "The URI of the component catalog."
            },
            "theme": {
              "type": "object",
              "description": "Theme parameters for the surface.",
              "additionalProperties": true
            },
            "sendDataModel": {
              "type": "boolean",
              "description": "Whether to send the data model to every client request."
            }
          },
          "required": [
            "surfaceId",
            "catalogId"
          ]
        }
      },
      "required": [
        "version",
        "createSurface"
      ],
      "additionalProperties": false
    },
    {
      "type": "object",
      "properties": {
        "version": {
          "type": "string",
          "const": "v0.9"
        },
        "updateComponents": {
          "type": "object",
          "description": "Updates a surface with a new set of components. This message can be sent multiple times to update the component tree of an existing surface. One of the components in one of the components lists MUST have an 'id' of 'root' to serve as the root of the component tree. The createSurface message MUST have been previously sent with the 'catalogId' that is in this message.",
          "properties": {
            "surfaceId": {
              "type": "string",
              "description": "The unique identifier for the UI surface."
            },
            "components": {
              "type": "array",
              "description": "A flat list of component definitions.",
              "items": {
                "description": "Must match one of the component definitions in the catalog.",
                "oneOf": [
                  {
                    "type": "object",
                    "description": "Displays a single catering job card with its date, guest count, and associated recipes.",
                    "properties": {
                      "jobId": {
                        "type": "string",
                        "description": "The unique ID of the catering job to display."
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "CateringJob"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "jobId"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "Displays a single recipe with its name, description, and image.",
                    "properties": {
                      "recipeId": {
                        "type": "string",
                        "description": "The unique ID of the recipe to display."
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "RecipeLine"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "recipeId"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "Displays a single ingredient with its name, description, unit, cost, and image.",
                    "properties": {
                      "ingredientId": {
                        "type": "string",
                        "description": "The unique ID of the ingredient to display."
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "IngredientLine"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "ingredientId"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "Displays a navigation card showing job location, title, and a Google Map widget.",
                    "properties": {
                      "title": {
                        "type": "string",
                        "description": "Title of the job."
                      },
                      "address": {
                        "type": "string",
                        "description": "Address of the job."
                      },
                      "latitude": {
                        "type": "number",
                        "description": "Latitude of the job location."
                      },
                      "longitude": {
                        "type": "number",
                        "description": "Longitude of the job location."
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "NavigationCard"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "title",
                      "address",
                      "latitude",
                      "longitude"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "A layout widget that arranges its children vertically.",
                    "properties": {
                      "justify": {
                        "type": "string",
                        "description": "How children are aligned on the main axis. ",
                        "enum": [
                          "start",
                          "center",
                          "end",
                          "spaceBetween",
                          "spaceAround",
                          "spaceEvenly",
                          "stretch"
                        ]
                      },
                      "align": {
                        "type": "string",
                        "description": "How children are aligned on the cross axis. ",
                        "enum": [
                          "start",
                          "center",
                          "end",
                          "stretch"
                        ]
                      },
                      "children": {
                        "description": "Either an explicit list of widget IDs for the children, or a template with a data binding to the list of children.",
                        "oneOf": [
                          {
                            "type": "array",
                            "items": {
                              "type": "string",
                              "description": "Component ID"
                            }
                          },
                          {
                            "type": "object",
                            "properties": {
                              "componentId": {
                                "type": "string",
                                "description": "The ID of a component."
                              },
                              "path": {
                                "type": "string",
                                "description": "A relative or absolute path in the data model."
                              }
                            },
                            "required": [
                              "componentId",
                              "path"
                            ]
                          }
                        ]
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "Column"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "children"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "A block of styled text.",
                    "properties": {
                      "text": {
                        "description": "While simple Markdown is supported (without HTML or image references), utilizing dedicated UI components is generally preferred for a richer and more structured presentation.",
                        "oneOf": [
                          {
                            "type": "string",
                            "description": "A literal string value."
                          },
                          {
                            "type": "object",
                            "description": "A path to a string.",
                            "properties": {
                              "path": {
                                "type": "string",
                                "description": "A relative or absolute path in the data model."
                              }
                            },
                            "required": [
                              "path"
                            ]
                          },
                          {
                            "type": "object",
                            "properties": {
                              "call": {
                                "type": "string",
                                "description": "The name of the function to call."
                              },
                              "args": {
                                "type": "object",
                                "description": "Arguments to pass to the function.",
                                "additionalProperties": true
                              }
                            },
                            "required": [
                              "call"
                            ]
                          }
                        ]
                      },
                      "variant": {
                        "type": "string",
                        "description": "A hint for the base text style.",
                        "enum": [
                          "h1",
                          "h2",
                          "h3",
                          "h4",
                          "h5",
                          "caption",
                          "body"
                        ]
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "Text"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "text"
                    ]
                  },
                  {
                    "type": "object",
                    "description": "An interactive button that triggers an action when pressed.",
                    "properties": {
                      "child": {
                        "type": "string",
                        "description": "The ID of a child widget. This should always be set, e.g. to the ID of a `Text` widget."
                      },
                      "action": {
                        "oneOf": [
                          {
                            "type": "object",
                            "properties": {
                              "event": {
                                "type": "object",
                                "properties": {
                                  "name": {
                                    "type": "string",
                                    "description": "The name of the action to be dispatched to the server."
                                  },
                                  "context": {
                                    "type": "object",
                                    "description": "Arbitrary context data to send with the action.",
                                    "additionalProperties": true
                                  }
                                },
                                "required": [
                                  "name"
                                ]
                              }
                            },
                            "required": [
                              "event"
                            ]
                          },
                          {
                            "type": "object",
                            "properties": {
                              "functionCall": {
                                "type": "object",
                                "properties": {
                                  "call": {
                                    "type": "string",
                                    "description": "The name of the function to call."
                                  },
                                  "args": {
                                    "type": "object",
                                    "description": "Arguments to pass to the function.",
                                    "additionalProperties": true
                                  }
                                },
                                "required": [
                                  "call"
                                ]
                              }
                            },
                            "required": [
                              "functionCall"
                            ]
                          }
                        ]
                      },
                      "variant": {
                        "type": "string",
                        "description": "A hint for the button style.",
                        "enum": [
                          "primary",
                          "borderless"
                        ]
                      },
                      "checks": {
                        "type": "array",
                        "description": "Validation rules for this component.",
                        "items": {
                          "type": "object",
                          "properties": {
                            "message": {
                              "type": "string",
                              "description": "Error message if validation fails."
                            },
                            "condition": {
                              "description": "DynamicBoolean condition (FunctionCall, DataBinding, or literal)."
                            }
                          },
                          "required": [
                            "message",
                            "condition"
                          ]
                        }
                      },
                      "component": {
                        "type": "string",
                        "enum": [
                          "Button"
                        ]
                      }
                    },
                    "required": [
                      "component",
                      "child",
                      "action"
                    ]
                  }
                ]
              },
              "minItems": 1
            }
          },
          "required": [
            "surfaceId",
            "components"
          ]
        }
      },
      "required": [
        "version",
        "updateComponents"
      ],
      "additionalProperties": false
    },
    {
      "type": "object",
      "properties": {
        "version": {
          "type": "string",
          "const": "v0.9"
        },
        "updateDataModel": {
          "type": "object",
          "description": "Updates the data model for an existing surface. This message can be sent multiple times to update the data model. The createSurface message MUST have been previously sent with the 'catalogId' that is in this message.",
          "properties": {
            "surfaceId": {
              "type": "string"
            },
            "path": {
              "type": "string",
              "default": "/"
            },
            "value": {
              "description": "The new value to write to the data model. If null/omitted, the key is removed."
            }
          },
          "required": [
            "surfaceId"
          ]
        }
      },
      "required": [
        "version",
        "updateDataModel"
      ],
      "additionalProperties": false
    },
    {
      "type": "object",
      "properties": {
        "version": {
          "type": "string",
          "const": "v0.9"
        },
        "deleteSurface": {
          "type": "object",
          "description": "Signals the client to delete the surface identified by 'surfaceId'. The createSurface message MUST have been previously sent with the 'catalogId' that is in this message.",
          "properties": {
            "surfaceId": {
              "type": "string"
            }
          },
          "required": [
            "surfaceId"
          ]
        }
      },
      "required": [
        "version",
        "deleteSurface"
      ],
      "additionalProperties": false
    }
  ]
}
-----A2UI_JSON_SCHEMA_END-----
''';
  }
}
