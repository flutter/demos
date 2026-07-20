// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../data/firestore_repository.dart';
import '../../services/agent_service.dart';
import '../catalog/catalog.dart';
import '../theme.dart';
import '../widgets/message_bubble.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  late final Catalog _catalog;
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  AgentService? _agentService;

  final List<ChatContent> _chatMessages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isWaiting = true;

  @override
  void initState() {
    super.initState();

    // 1. Initialize GenUI Catalog & Controllers
    _catalog = commisCatalog;
    _controller = SurfaceController(catalogs: [_catalog]);
    _transport = A2uiTransportAdapter(onSend: _sendAndReceive);
    _conversation = Conversation(
      controller: _controller,
      transport: _transport,
    );

    // 4. Listen to Conversation events to drive our chat UI
    _conversation.events.listen((event) {
      if (event is ConversationContentReceived) {
        setState(() {
          _isWaiting = false;
          // Append text chunk to the last model message if applicable
          final latestMessage = _chatMessages.isNotEmpty
              ? _chatMessages.last
              : null;
          if (latestMessage is TextContent && !latestMessage.isUser) {
            latestMessage.text += ' ${event.text}';
          } else {
            _chatMessages.add(TextContent(text: event.text, isUser: false));
          }
        });
      } else if (event is ConversationSurfaceAdded) {
        setState(() {
          _isWaiting = false;
          _chatMessages.add(SurfaceContent(surfaceId: event.surfaceId));
        });
      } else if (event is ConversationWaiting) {
        setState(() {
          _isWaiting = true;
        });
      } else if (event is ConversationError) {
        setState(() {
          _isWaiting = false;
          _chatMessages.add(
            TextContent(
              text: 'An error occurred: ${event.error}',
              isUser: false,
            ),
          );
        });
      }
    });

    _initAgent();
  }

  Future<void> _initAgent() async {
    final repository = context.read<FirestoreRepository>();

    String? feeds;

    try {
      final jobs = await repository.getJobs();
      final feedFutures = jobs.map((job) => repository.getFeedMessage(job.id));
      final results = await Future.wait(feedFutures);
      feeds = results
          .map((r) => r?.trim() ?? '')
          .where((r) => r.isNotEmpty)
          .join('\n\n');
    } catch (e) {
      debugPrint('Error initializing agent: $e');
    }

    _agentService = FirebaseAILogicService(
      repository: repository,
      catalog: _catalog,
      cachedMessages: feeds,
    );

    if (feeds != null) {
      _transport.addChunk(feeds);
    }

    setState(() => _isWaiting = false);
  }

  @override
  void dispose() {
    _conversation.dispose();
    _controller.dispose();
    _transport.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendAndReceive(ChatMessage message) async {
    if (_agentService == null) {
      return;
    }

    final buffer = StringBuffer();
    if (message.text.isNotEmpty) {
      buffer.write(message.text);
    } else {
      for (final part in message.parts) {
        if (part is TextPart) {
          buffer.write(part.text);
        } else if (part.isUiInteractionPart) {
          final uiInteraction = part.asUiInteractionPart;
          if (uiInteraction != null) {
            buffer.write(uiInteraction.interaction);
          }
        }
      }
    }

    final prompt = buffer.toString();
    if (prompt.isEmpty) return;

    debugPrint('OUTBOUND:\n$prompt\n');

    // Add user message to local chat logs (if it's not a background error/interaction)
    // For visual cleanliness, if the message contains user text, display it.
    if (message.text.isNotEmpty) {
      setState(() {
        _chatMessages.add(TextContent(text: message.text, isUser: true));
      });
    }

    try {
      final responseStream = _agentService!.generateResponse(prompt);
      await for (final chunk in responseStream) {
        debugPrint('INBOUND:\n$chunk\n');
        _transport.addChunk(chunk);
      }
    } catch (e) {
      // Feed error into the transport adapter so Conversation catches it
      debugPrint('Gemini Stream Error: $e');
      _transport.addChunk('\n[Error occurred: $e]');
    }
  }

  void _handleUserSubmit() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    // Trigger the conversation flow by sending a ChatMessage
    _conversation.sendRequest(ChatMessage.user(text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommisColors.background,
      appBar: AppBar(
        backgroundColor: CommisColors.surfaceLevel1,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: CommisColors.goldAccent,
              size: 24.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              'COMMIS ASSISTANT',
              style: GoogleFonts.outfit(
                color: CommisColors.textPrimary,
                fontSize: 20.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: CommisColors.borderLowContrast, height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Chat messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, i) {
                    final msg = _chatMessages[i];
                    return switch (msg) {
                      TextContent(:final text, :final isUser) => MessageBubble(
                        text: text,
                        isUser: isUser,
                      ),
                      SurfaceContent(:final surfaceId) => Surface(
                        key: ValueKey(surfaceId),
                        surfaceContext: _controller.contextFor(surfaceId),
                      ),
                    };
                  },
                ),
              ),

              // Divider
              const Divider(color: CommisColors.borderLowContrast, height: 1.0),

              // Input bar
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  color: CommisColors.surfaceLevel1,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: CommisColors.background,
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: CommisColors.borderLowContrast,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: _inputController,
                            enabled: !_isWaiting,
                            style: GoogleFonts.sourceSans3(
                              color: _isWaiting
                                  ? CommisColors.textSecondary.withAlpha(80)
                                  : CommisColors.textPrimary,
                              fontSize: 15.0,
                            ),
                            decoration: InputDecoration(
                              hintText: _isWaiting
                                  ? 'Commis is thinking...'
                                  : 'Ask Commis anything...',
                              hintStyle: GoogleFonts.sourceSans3(
                                color: CommisColors.textSecondary.withAlpha(
                                  120,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _isWaiting
                                ? null
                                : (_) => _handleUserSubmit(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      IconButton(
                        icon: const Icon(Icons.send_rounded),
                        color: _isWaiting
                            ? CommisColors.goldAccent.withAlpha(80)
                            : CommisColors.goldAccent,
                        onPressed: _isWaiting ? null : _handleUserSubmit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isWaiting)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: CommisColors.goldAccent,
                backgroundColor: Colors.transparent,
                minHeight: 2.0,
              ),
            ),
        ],
      ),
    );
  }
}

sealed class ChatContent {}

class TextContent extends ChatContent {
  String text;
  final bool isUser;

  TextContent({required this.text, required this.isUser});
}

class SurfaceContent extends ChatContent {
  final String surfaceId;

  SurfaceContent({required this.surfaceId});
}
