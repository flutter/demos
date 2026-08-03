import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './ui_components/ui_components.dart';
import '../src/providers.dart';

class FlutterFireAILiveAPIDemo extends ConsumerStatefulWidget {
  const FlutterFireAILiveAPIDemo({super.key});

  @override
  ConsumerState<FlutterFireAILiveAPIDemo> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<FlutterFireAILiveAPIDemo> {
  // Flag(s) to prevent multiple stream initializations
  bool _audioIsInitialized = false;
  bool _videoIsInitialized = false;
  final LiveGenerativeModel
  _liveModel = FirebaseAI.agentPlatform().liveGenerativeModel(
    model: 'gemini-2.0-flash-live-preview-04-09',
    systemInstruction: Content.text(
      'You are a plant identifier. Greet the user by telling them that you '
      'are a plant identifier. Ask them to turn on their camera and show '
      'you a plant and you can help them identify plants and flowers. '
      'Your job is to help the user dentify plants and flowers. '
      'When the user asks you to identify a plant or flower, respond '
      'by telling them what it is and along with fun fact about it. '
      'If you\'re unable to identify the plant or flower, you may ask the user '
      'for more information about it or ask for a closer look.',
    ),
    liveGenerationConfig: LiveGenerationConfig(
      speechConfig: SpeechConfig(voiceName: 'fenrir'),
      responseModalities: [ResponseModalities.audio],
    ),
  );
  late LiveSession _session; // Gemini Live Session
  bool _settingUpLiveSession = false; // Session is getting set up
  bool _liveSessionIsOpen = false; // Session is open and ready to go.
  bool _audioStreamIsActive =
      false; // Session is running and with audio input & output streams active
  bool _cameraIsActive = false; // Whether sending video stream to Gemini

  @override
  void initState() {
    super.initState();
    // Load the first frame AND THEN initialize audio & video setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAudio();
      _initializeVideo();
    });
  }

  @override
  void dispose() {
    super.dispose();
    ref.read(audioInputProvider).dispose();
    ref.read(audioOutputProvider).dispose();
    ref.read(videoInputProvider).dispose();
    if (_liveSessionIsOpen) {
      unawaited(_session.close()); // Ensure session is closed on dispose
    }
  }

  /// AUDIO INPUT & OUTPUT
  Future<void> _initializeAudio() async {
    try {
      await ref.read(audioInputProvider).init(); // Initialize Audio Input
      await ref.read(audioOutputProvider).init(); // Initialize Audio Output

      setState(() {
        _audioIsInitialized = true;
      });
    } catch (e) {
      log("Error during audio initialization: $e");
      if (!mounted) return;

      var errorSnackBar = SnackBar(
        content: Text('Oops! Something went wrong with the audio setup.'),
        action: SnackBarAction(label: 'Retry', onPressed: _initializeAudio),
      );
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  void toggleAudioStream() async {
    _audioStreamIsActive ? await stopAudioStream() : await startAudioStream();
  }

  Future<void> startAudioStream() async {
    // Start the Gemini Live session
    await _toggleLiveSession();

    final audioInput = ref.read(audioInputProvider);
    final audioOutput = ref.read(audioOutputProvider);

    // Start recording audio input stream
    var audioInputStream = await audioInput.startRecordingStream();
    log('Audio input stream is recording!');

    // Start playing audio output stream
    await audioOutput.playStream();
    log('Audio output stream is playing!');

    setState(() {
      _audioStreamIsActive = true;
    });

    // Wrap input stream audio data in InlineDataPart and send to Gemini session
    _session.sendMediaStream(
      audioInputStream.map((data) {
        return InlineDataPart('audio/pcm', data);
      }),
    );
  }

  Future<void> stopAudioStream() async {
    // If sending video, stop recording & transmitting.
    if (_cameraIsActive) {
      stopVideoStream();
    }
    // Stop recording audio input
    await ref.read(audioInputProvider).stopRecording();

    // Stop playing audio output
    await ref.read(audioOutputProvider).stopStream();

    // End the Gemini live session
    await _toggleLiveSession();

    setState(() {
      _audioStreamIsActive = false;
    });
  }

  Future<void> toggleMuteInput() async {
    await ref.read(audioInputProvider).togglePauseRecording();
  }

  /// VIDEO INPUT
  Future<void> _initializeVideo() async {
    try {
      await ref.read(videoInputProvider).init();
      setState(() {
        _videoIsInitialized = true;
      });
    } catch (e) {
      log("Error during video initialization: $e");
    }
  }

  void startVideoStream() {
    if (!_videoIsInitialized || !_audioStreamIsActive || _cameraIsActive) {
      return;
    }

    Stream<Uint8List> imageStream = ref
        .read(videoInputProvider)
        .startStreamingImages();

    // Wrap video input stream image data in InlineDataPart and send to Gemini session
    _session.sendMediaStream(
      imageStream.map((data) {
        return InlineDataPart("image/jpeg", data);
      }),
    );

    setState(() {
      _cameraIsActive = true;
    });
  }

  void stopVideoStream() async {
    await ref.read(videoInputProvider).stopStreamingImages();
    setState(() {
      _cameraIsActive = false;
    });
  }

  void toggleVideoStream() async {
    _cameraIsActive ? stopVideoStream() : startVideoStream();
  }

  /// Firebase AI Logic
  Future<void> _toggleLiveSession() async {
    setState(() {
      _settingUpLiveSession = true;
    });

    if (!_liveSessionIsOpen) {
      _session = await _liveModel.connect();
      _liveSessionIsOpen = true;
      unawaited(processMessagesContinuously());
    } else {
      await _session.close();
      _liveSessionIsOpen = false;
    }

    setState(() {
      _settingUpLiveSession = false;
    });
  }

  Future<void> processMessagesContinuously() async {
    try {
      await for (final response in _session.receive()) {
        // Process the received message
        LiveServerMessage message = response.message;
        await _handleLiveServerMessage(message);
      }
      log('Live session receive stream completed.');
    } catch (e) {
      log('Error receiving live session messages: $e');
    }
  }

  Future<void> _handleLiveServerMessage(LiveServerMessage response) async {
    if (response is LiveServerContent) {
      if (response.modelTurn != null) {
        await _handleLiveServerContent(response);
      }
      if (response.turnComplete != null && response.turnComplete!) {
        await _handleTurnComplete();
      }
      if (response.interrupted != null && response.interrupted!) {
        log('Interrupted: $response');
      }
    }

    if (response is LiveServerToolCall && response.functionCalls != null) {
      await _handleLiveServerToolCall(response);
    }
  }

  Future<void> _handleLiveServerContent(LiveServerContent response) async {
    final partList = response.modelTurn?.parts;
    if (partList != null) {
      for (final part in partList) {
        switch (part) {
          case TextPart textPart:
            await _handleTextPart(textPart);
          case InlineDataPart inlineDataPart:
            await _handleInlineDataPart(inlineDataPart);
          default:
            log('Received part with type ${part.runtimeType}');
        }
      }
    }
  }

  Future<void> _handleInlineDataPart(InlineDataPart part) async {
    if (part.mimeType.startsWith('audio')) {
      // If DataPart is audio, add it to the output audio stream
      ref.read(audioOutputProvider).addDataToAudioStream(part.bytes);
    }
  }

  Future<void> _handleTextPart(TextPart part) async {
    log('Text message from Gemini: ${part.text}');
  }

  Future<void> _handleTurnComplete() async {
    log('Model is done generating. Turn complete!');
  }

  Future<void> _handleLiveServerToolCall(LiveServerToolCall response) async {
    if (response.functionCalls?.isNotEmpty ?? false) {
      log("Gemini made a function call!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioInput = ref.watch(audioInputProvider);
    final videoInput = ref.watch(videoInputProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 100,
        leading: LeafAppIcon(),
        title: AppTitle(title: 'FlutterFire AI Demo'),
      ),
      body: _cameraIsActive
          ? Center(
              child: FullCameraPreview(controller: videoInput.cameraController),
            )
          : CenterCircle(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: _settingUpLiveSession
                    ? CircularProgressIndicator()
                    : Icon(size: 54, Icons.waves),
              ),
            ),
      bottomNavigationBar: BottomBar(
        child: Row(
          children: [
            ChatButton(),
            VideoButton(
              isActive: _cameraIsActive,
              onPressed: toggleVideoStream,
            ),
            const Spacer(),
            MuteButton(
              isMuted: audioInput.isPaused,
              onPressed: _audioStreamIsActive ? toggleMuteInput : null,
            ),
            CallButton(
              isActive: _audioStreamIsActive,
              onPressed: _audioIsInitialized ? toggleAudioStream : null,
            ),
          ],
        ),
      ),
    );
  }
}
