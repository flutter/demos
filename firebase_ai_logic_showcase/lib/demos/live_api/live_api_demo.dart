// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui_components/ui_components.dart';
import 'utilities/utilities.dart';
import 'firebaseai_live_api_service.dart';

class LiveAPIDemo extends ConsumerStatefulWidget {
  const LiveAPIDemo({super.key});

  @override
  ConsumerState<LiveAPIDemo> createState() => _LiveAPIDemoState();
}

/// The main state for the Live API demo.
///
/// This stateful widget orchestrates the UI and manages the state for the demo,
/// including handling user input, managing the call lifecycle, and coordinating
/// with the [LiveApiService] and I/O utilities.
class _LiveAPIDemoState extends ConsumerState<LiveAPIDemo> {
  // Service for interacting with the Gemini API via Firebase AI.
  late LiveApiService _liveApiService;

  // Utilities for handling device I/O.
  late final AudioInput _audioInput = AudioInput();
  late final AudioOutput _audioOutput = AudioOutput();
  late final VideoInput _videoInput = VideoInput();

  // Initialization flags.
  bool _videoIsInitialized = false;

  // UI State flags.
  bool _isConnecting = false; // True when setting up the Gemini session.
  bool _isCallActive = false; // True when the audio stream is active.
  bool _cameraIsActive = false; // True when sending video to Gemini.
  bool _loadingImage = false; // True when waiting for an image to be generated.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndInitializeIO();
    });
  }

  @override
  void didUpdateWidget(LiveAPIDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndInitializeIO();
  }

  Future<void> _checkAndInitializeIO() async {
    await _initializeAudio();
    await _initializeVideo();
    _liveApiService = LiveApiService(
      audioOutput: _audioOutput,
      ref: ref, // Pass the ref to the service
      onImageLoadingChange: _onImageLoadingChange,
      onImageGenerated: _onImageGenerated,
      onError: _showErrorSnackBar,
    );
  }

  @override
  void dispose() {
    _audioInput.dispose();
    _audioOutput.dispose();
    _videoInput.dispose();
    _liveApiService.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  //================================================================================
  // UI Callbacks
  //================================================================================

  void _onImageLoadingChange(bool isLoading) {
    setState(() {
      _loadingImage = isLoading;
    });
  }

  void _onImageGenerated(Uint8List imageBytes) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return GeneratedImageDialog(imageBytes: imageBytes);
      },
    );
  }

  //================================================================================
  // Call Lifecycle
  //================================================================================

  void toggleCall() async {
    _isCallActive ? await stopCall() : await startCall();
  }

  Future<void> startCall() async {
    // Initialize the camera controller here to ensure it's fresh for each call.
    // This prevents a bug where the camera preview freezes on subsequent calls.
    if (_videoIsInitialized) {
      await _videoInput.initializeCameraController();
    }

    setState(() {
      _isConnecting = true;
    });

    await _liveApiService.connect();

    setState(() {
      _isConnecting = false;
    });

    var audioInputStream = await _audioInput.startRecordingStream();
    log('Audio input stream is recording!');

    await _audioOutput.playStream();
    log('Audio output stream is playing!');

    setState(() {
      _isCallActive = true;
    });

    _liveApiService.sendMediaStream(
      audioInputStream.map((data) {
        return InlineDataPart('audio/pcm', data);
      }),
    );
  }

  Future<void> stopCall() async {
    if (_cameraIsActive) {
      stopVideoStream();
    }
    await _audioInput.stopRecording();
    await _audioOutput.stopStream();

    setState(() {
      _isConnecting = true;
    });

    await _liveApiService.close();

    setState(() {
      _isConnecting = false;
      _isCallActive = false;
    });
  }

  //================================================================================
  // I/O Initialization and Control
  //================================================================================

  Future<void> _initializeAudio() async {
    try {
      await _audioInput.init(); // Initialize Audio Input
      await _audioOutput.init(); // Initialize Audio Output
    } catch (e) {
      log("Error during audio initialization: $e");
      if (!mounted) return;

      var errorSnackBar = SnackBar(
        content: const Text('Oops! Something went wrong with the audio setup.'),
        action: SnackBarAction(label: 'Retry', onPressed: _initializeAudio),
      );
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoInput.init();
      setState(() {
        _videoIsInitialized = true;
      });
    } catch (e) {
      log("Error during video initialization: $e");
    }
  }

  void startVideoStream() {
    if (!_videoIsInitialized || !_isCallActive || _cameraIsActive) {
      return;
    }

    Stream<Uint8List> imageStream = _videoInput.startStreamingImages();

    _liveApiService.sendMediaStream(
      imageStream.map((data) {
        return InlineDataPart("image/jpeg", data);
      }),
    );

    setState(() {
      _cameraIsActive = true;
    });
  }

  void stopVideoStream() async {
    await _videoInput.stopStreamingImages();
    setState(() {
      _cameraIsActive = false;
    });
  }

  void toggleVideoStream() async {
    _cameraIsActive ? stopVideoStream() : startVideoStream();
  }

  Future<void> toggleMuteInput() async {
    await _audioInput.togglePauseRecording();
    setState(() {}); // Rebuild mute button icon
  }

  //================================================================================
  // Build Method
  //================================================================================

  @override
  Widget build(BuildContext context) {
    final audioInput = _audioInput;
    final videoInput = _videoInput;

    return ListenableBuilder(
      listenable: audioInput,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Column(
            children: [
              Expanded(
                child: LiveApiBody(
                  cameraIsActive: _cameraIsActive,
                  cameraController: videoInput.controllerInitialized
                      ? videoInput.cameraController
                      : null,
                  settingUpLiveSession: _isConnecting,
                  loadingImage: _loadingImage,
                ),
              ),
              BottomBar(
                children: [
                  FlipCameraButton(
                    onPressed: _cameraIsActive && videoInput.cameras.length > 1
                        ? videoInput.flipCamera
                        : null,
                  ),
                  VideoButton(
                    isActive: _cameraIsActive,
                    onPressed: toggleVideoStream,
                  ),
                  AudioVisualizer(
                    audioStreamIsActive: _isCallActive,
                    amplitudeStream: audioInput.amplitudeStream,
                  ),
                  MuteButton(
                    isMuted: audioInput.isPaused,
                    onPressed: _isCallActive ? toggleMuteInput : null,
                  ),
                  CallButton(isActive: _isCallActive, onPressed: toggleCall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
