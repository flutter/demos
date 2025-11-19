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
import 'package:record/record.dart';
import 'package:waveform_flutter/waveform_flutter.dart' as wf;

class AudioInput extends ChangeNotifier {
  AudioRecorder? _recorder;
  RecordConfig recordConfig = RecordConfig(
    encoder: AudioEncoder.pcm16bits,
    sampleRate: 16000,
    numChannels: 1,
    echoCancel: true,
    noiseSuppress: true,
    androidConfig: AndroidRecordConfig(
      audioSource: AndroidAudioSource.voiceCommunication,
    ),
    iosConfig: IosRecordConfig(categoryOptions: []),
  );
  bool isRecording = false;
  bool isPaused = false;
  late Stream<Uint8List> audioStream;
  Stream<wf.Amplitude>? amplitudeStream;
  StreamSubscription? _amplitudeSubscription;
  StreamController<wf.Amplitude>? _amplitudeStreamController;

  Future<void> init() async {
    _recorder = AudioRecorder();
    await checkPermission();
  }

  @override
  void dispose() {
    _recorder?.dispose();
    super.dispose();
  }

  Future<void> checkPermission() async {
    final hasPermission = await _recorder!.hasPermission();
    if (!hasPermission) {
      throw MicrophonePermissionDeniedException(
        'This app does not have microphone permissions. Please enable it.',
      );
    }
  }

  Future<Stream<Uint8List>> startRecordingStream() async {
    final devices = await _recorder!.listInputDevices();
    log(devices.toString());
    audioStream = (await _recorder!.startStream(
      recordConfig,
    )).asBroadcastStream();
    _amplitudeStreamController = StreamController<wf.Amplitude>.broadcast();
    _amplitudeSubscription = _recorder!
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
          _amplitudeStreamController?.add(
            wf.Amplitude(current: amp.current, max: amp.max),
          );
        });
    amplitudeStream = _amplitudeStreamController?.stream;
    isRecording = true;
    //log("${isRecording ? "Is" : "Not"} Recording");
    notifyListeners();
    return audioStream;
  }

  Future<void> stopRecording() async {
    await _recorder!.stop();
    isRecording = false;
    await _amplitudeSubscription?.cancel();
    await _amplitudeStreamController?.close();
    amplitudeStream = null;
    _recorder?.dispose();
    _recorder = AudioRecorder();
    //log("${isRecording ? "Is" : "Not"} Recording");
    notifyListeners();
  }

  Future<void> togglePauseRecording() async {
    isPaused ? await _recorder!.resume() : await _recorder!.pause();
    isPaused = !isPaused;
    notifyListeners();
    return;
  }
}

/// An exception thrown when microphone permission is denied or not granted.
class MicrophonePermissionDeniedException implements Exception {
  /// The optional message associated with the permission denial.
  final String? message;

  /// Creates a new [MicrophonePermissionDeniedException] with an optional [message].
  MicrophonePermissionDeniedException([this.message]);

  @override
  String toString() {
    if (message == null) {
      return 'MicrophonePermissionDeniedException';
    }
    return 'MicrophonePermissionDeniedException: $message';
  }
}
