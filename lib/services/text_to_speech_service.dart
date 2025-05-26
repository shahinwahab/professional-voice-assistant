import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

enum TtsState { playing, stopped, paused, continued }

class TextToSpeechService {
  final FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState.stopped;

  // Speech segments tracking
  int currentWordIndex = 0;
  List<String> speechSegments = [];

  // Callback functions
  final void Function(TtsState) onStateChange;
  final void Function(int) onWordBoundary;

  TextToSpeechService(
      {required this.onStateChange, required this.onWordBoundary});

  Future<void> initialize() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(0.8);

    // Set platform-specific speech rate
    if (!kIsWeb && Platform.isAndroid) {
      // Lower speech rate for Android to fix the "talks too fast" issue
      await flutterTts.setSpeechRate(0.42); // Lower value for Android
    } else {
      // Keep normal speech rate for web and other platforms
      await flutterTts.setSpeechRate(1.0);
    }

    // Disable auto-restart features of TTS
    if (!kIsWeb) {
      try {
        await flutterTts.setSilence(
            1); // Add silence between sentences to prevent auto-restart
      } catch (e) {
        print("Error setting TTS parameters: $e");
      }
    }

    // Set up word boundary callback if platform supports it
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      flutterTts.setProgressHandler((text, start, end, word) {
        currentWordIndex = speechSegments.indexWhere(
          (segment) => segment.contains(word),
        );
        onWordBoundary(currentWordIndex);
      });
    }

    // Listen for TTS state changes
    flutterTts.setStartHandler(() {
      ttsState = TtsState.playing;
      onStateChange(ttsState);
    });

    flutterTts.setCompletionHandler(() {
      ttsState = TtsState.stopped;
      onStateChange(ttsState);
      currentWordIndex = 0; // Reset index when complete
    });

    flutterTts.setErrorHandler((error) {
      ttsState = TtsState.stopped;
      onStateChange(ttsState);
    });

    flutterTts.setPauseHandler(() {
      ttsState = TtsState.paused;
      onStateChange(ttsState);
    });

    flutterTts.setContinueHandler(() {
      ttsState = TtsState.continued;
      onStateChange(ttsState);
    });

    // The setSharedInstance method is not available on web
    if (!kIsWeb) {
      await flutterTts.setSharedInstance(true);
    }
  }

  // Split text into manageable segments
  void prepareTextForSpeech(String text) {
    speechSegments = _splitTextIntoSpeakableSegments(text);
    currentWordIndex = 0;
  }

  List<String> _splitTextIntoSpeakableSegments(String text) {
    // Split by sentences and other logical breaks
    var segments = text.split(RegExp(r'(?<=[.!?])\s+'));

    // Further split any long segments
    List<String> result = [];
    for (var segment in segments) {
      if (segment.length > 100) {
        // If segment is too long
        var words = segment.split(' ');
        var currentSegment = '';

        for (var word in words) {
          if (currentSegment.length + word.length > 100) {
            result.add(currentSegment.trim());
            currentSegment = word + ' ';
          } else {
            currentSegment += word + ' ';
          }
        }

        if (currentSegment.isNotEmpty) {
          result.add(currentSegment.trim());
        }
      } else {
        result.add(segment);
      }
    }

    return result;
  }

  Future<void> speak(String content) async {
    if (content.isEmpty) return;

    // First ensure we're stopped
    await flutterTts.stop();

    // Split the text into segments for better tracking
    prepareTextForSpeech(content);

    // Actually speak
    await flutterTts.speak(content);

    // Android workaround: Set up a timer to check if speech has completed
    if (!kIsWeb && Platform.isAndroid) {
      // Estimate speech duration (roughly 90ms per character)
      int estimatedDuration = (content.length * 90).clamp(1500, 60000);

      // Set a timer that will check if we're still in speaking state after the estimated duration
      Timer(Duration(milliseconds: estimatedDuration), () {
        // Only trigger if we're still in playing state (not paused)
        if (ttsState == TtsState.playing) {
          ttsState = TtsState.stopped;
          onStateChange(ttsState);
          currentWordIndex = 0;
        }
      });
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }

  Future<void> pause() async {
    await flutterTts.pause();
  }

  String getRemainingText() {
    if (currentWordIndex < 0 || currentWordIndex >= speechSegments.length) {
      return '';
    }

    // Join the remaining segments
    return speechSegments.sublist(currentWordIndex).join(' ');
  }

  Future<void> resumeSpeaking() async {
    if (ttsState == TtsState.paused) {
      if (await flutterTts.isLanguageAvailable("en-US")) {
        // On supported platforms, try to resume
        try {
          await flutterTts.setLanguage("en-US");
          bool result = await flutterTts.isLanguageInstalled("en-US") ?? false;
          if (result) {
            await flutterTts.speak(getRemainingText());
          }
        } catch (e) {
          print("Error resuming speech: $e");
          // Fallback to speaking remaining text
          await flutterTts.speak(getRemainingText());
        }
      } else {
        // Fallback for unsupported platforms
        await flutterTts.speak(getRemainingText());
      }
    }
  }

  // Simple cleaning of text to just remove asterisks
  String cleanTextForSpeech(String text) {
    if (text.isEmpty) {
      return '';
    }

    // Just remove all asterisks from the text
    return text.replaceAll('*', '');
  }

  void dispose() {
    flutterTts.stop();
  }
}
