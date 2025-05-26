import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText speechToText = SpeechToText();
  String lastWords = '';
  bool isListening = false;
  bool _initialized = false;

  // Listening timeout management
  Timer? listeningTimeout;
  int noSpeechCounter = 0;
  static const int maxNoSpeechRetries = 2;

  // Callback functions
  Function(String) onResult;
  Function() onListeningStarted;
  Function() onListeningFinished;
  Function() onNoSpeechDetected;

  SpeechToTextService({
    required this.onResult,
    required this.onListeningStarted,
    required this.onListeningFinished,
    required this.onNoSpeechDetected,
  });

  Future<void> initialize() async {
    if (_initialized) return;

    await speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          isListening = false;
        } else if (status == 'listening') {
          isListening = true;
        }
      },
    );

    _initialized = true;
  }

  Future<bool> startListening() async {
    // First check if speech recognition is already active
    if (isListening) {
      print("Speech recognition is already active, stopping first");
      await stopListening();
      // Small delay to ensure it's fully stopped
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Reset last words
    lastWords = '';

    try {
      bool available = await speechToText.initialize();

      if (available) {
        await speechToText.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 10), // Set max listening time
          pauseFor:
              const Duration(seconds: 10), // Auto-stop after 10s of silence
          partialResults: true,
        );

        isListening = true;
        onListeningStarted();

        // Start timeout to detect no speech
        _startListeningTimeout();
        return true;
      } else {
        print("The user has denied the use of speech recognition.");
        return false;
      }
    } catch (e) {
      print("Error starting speech recognition: $e");
      isListening = false;
      return false;
    }
  }

  Future<void> stopListening() async {
    // Cancel the timeout timer
    listeningTimeout?.cancel();

    try {
      await speechToText.stop();
      isListening = false;
      onListeningFinished();
    } catch (e) {
      print("Error stopping speech recognition: $e");
      isListening = false;
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    // Reset the counter whenever we hear speech
    if (result.recognizedWords.isNotEmpty) {
      noSpeechCounter = 0;
    }

    lastWords = result.recognizedWords;
    onResult(lastWords);
  }

  // Start a timer to detect no speech
  void _startListeningTimeout() {
    // Cancel any existing timer
    listeningTimeout?.cancel();

    // Start a new timer
    listeningTimeout = Timer(const Duration(seconds: 5), () {
      if (isListening && lastWords.isEmpty) {
        _handleNoSpeechDetected();
      }
    });
  }

  // Handle the case when no speech is detected
  Future<void> _handleNoSpeechDetected() async {
    await speechToText.stop();
    isListening = false;
    onNoSpeechDetected();
  }

  void dispose() {
    listeningTimeout?.cancel();
    speechToText.stop();
  }
}
