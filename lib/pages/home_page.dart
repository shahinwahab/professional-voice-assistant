import 'dart:async';
import 'package:pro_voice_assistant/widgets/feature_box.dart';
import 'package:pro_voice_assistant/services/gemini_service.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';
import 'package:pro_voice_assistant/services/auth_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pro_voice_assistant/services/secrets.dart';
import 'package:pro_voice_assistant/pages/signin_page.dart';

// Import new components
import 'package:pro_voice_assistant/models/assistant_state.dart';
import 'package:pro_voice_assistant/models/conversation_entry.dart';
import 'package:pro_voice_assistant/services/text_to_speech_service.dart';
import 'package:pro_voice_assistant/services/speech_to_text_service.dart';
import 'package:pro_voice_assistant/widgets/conversation_widget.dart';
import 'package:pro_voice_assistant/widgets/assistant_controls.dart';
import 'package:pro_voice_assistant/widgets/features_section.dart';
import 'package:pro_voice_assistant/widgets/assistant_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final GeminiService geminiService = GeminiService(apiKey: geminiAPIKey);

  // Speech services
  late TextToSpeechService _ttsService;
  late SpeechToTextService _sttService;

  // State management
  String lastWords = '';
  String lastProcessedQuery = '';
  String? generatedContent;
  String? generatedImageUrl;
  String userName = 'User'; // Default name until loaded
  bool isLoading = true;
  AssistantState assistantState = AssistantState.idle;
  bool _isManuallyPaused = false;

  // Conversation history
  List<ConversationEntry> conversationHistory = [];

  // Animation timing
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadUserData();
  }

  void _initServices() {
    // Initialize Text-to-Speech service
    _ttsService = TextToSpeechService(
      onStateChange: _handleTtsStateChange,
      onWordBoundary: _handleWordBoundary,
    );
    _ttsService.initialize();

    // Initialize Speech-to-Text service
    _sttService = SpeechToTextService(
      onResult: _handleSpeechResult,
      onListeningStarted: _handleListeningStarted,
      onListeningFinished: _handleListeningFinished,
      onNoSpeechDetected: _handleNoSpeechDetected,
    );
    _sttService.initialize();
  }

  void _handleTtsStateChange(TtsState state) {
    setState(() {
      switch (state) {
        case TtsState.playing:
          assistantState = AssistantState.speaking;
          break;
        case TtsState.stopped:
          // Only move to completed if not manually paused
          if (!_isManuallyPaused) {
            assistantState = AssistantState.completed;
          }
          break;
        case TtsState.paused:
          assistantState = AssistantState.paused;
          break;
        case TtsState.continued:
          assistantState = AssistantState.speaking;
          break;
      }
    });
  }

  void _handleWordBoundary(int wordIndex) {
    // No need to setState here as it would rebuild too frequently
  }

  void _handleSpeechResult(String text) {
    setState(() {
      lastWords = text;
    });
  }

  void _handleListeningStarted() {
    setState(() {
      assistantState = AssistantState.listening;
    });
  }

  void _handleListeningFinished() {
    // Only process if there are actual words
    if (lastWords.isNotEmpty) {
      setState(() {
        assistantState = AssistantState.processing;
      });
      processUserQuery();
    }
  }

  void _handleNoSpeechDetected() {
    String messageText;
    if (_sttService.noSpeechCounter >= SpeechToTextService.maxNoSpeechRetries) {
      // Reset counter and show a more detailed message
      _sttService.noSpeechCounter = 0;
      messageText =
          "I couldn't hear anything. Please check your microphone and try again by tapping the mic button.";
    } else {
      // Increment counter and show a simple prompt
      _sttService.noSpeechCounter++;
      messageText =
          "I didn't catch that. Please tap the mic and try speaking again.";
    }

    setState(() {
      generatedContent = messageText;
      assistantState = AssistantState.idle;
    });

    // Speak the message
    systemSpeak(messageText);
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final name = await _authService.getCurrentUserName();
      setState(() {
        userName = name;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading user data: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInPage()),
        );
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> startListening() async {
    // Reset last words
    lastWords = '';

    // If speech is paused, resume it instead of starting to listen
    if (assistantState == AssistantState.paused) {
      resumeSpeaking();
      return;
    }

    // If speech is in progress, pause it
    if (assistantState == AssistantState.speaking) {
      stopSpeaking();
      return;
    }

    // Start listening
    await _sttService.startListening();
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
  }

  Future<void> stopSpeaking() async {
    if (assistantState == AssistantState.speaking) {
      _isManuallyPaused = true;
      await _ttsService.pause();
    }
  }

  Future<void> resumeSpeaking() async {
    if (generatedContent != null &&
        generatedContent!.isNotEmpty &&
        assistantState == AssistantState.paused) {
      _isManuallyPaused = false;
      await _ttsService.resumeSpeaking();
    }
  }

  void _askNewQuestion() async {
    // Stop current speech completely
    _ttsService.stop();
    _isManuallyPaused = false;

    // Ensure speech recognition is not active
    if (_sttService.isListening) {
      await _sttService.stopListening();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Start listening for new question
    setState(() {
      assistantState = AssistantState.idle;
    });

    // Small delay before starting new listening
    await Future.delayed(const Duration(milliseconds: 500));
    startListening();
  }

  void clearConversation() {
    // Stop any ongoing speech
    _isManuallyPaused = false;
    _ttsService.stop();

    // Stop speech recognition if active
    if (_sttService.isListening) {
      _sttService.stopListening();
    }

    // Clear Gemini service conversation history
    geminiService.messages.clear();

    setState(() {
      generatedContent = null;
      generatedImageUrl = null;
      conversationHistory = [];
      lastProcessedQuery = '';
      assistantState = AssistantState.idle;
      lastWords = '';
    });
  }

  Future<void> systemSpeak(String content) async {
    if (content.isEmpty) return;

    // Clean the text for speech
    final cleanedText = _ttsService.cleanTextForSpeech(content);

    // Speak the text
    await _ttsService.speak(cleanedText);
  }

  // Process the user's speech and get a response
  Future<void> processUserQuery() async {
    if (lastWords.isEmpty) return;

    // Store the last processed query so we can display it
    final processedQuery = lastWords;

    setState(() {
      assistantState = AssistantState.processing;
      lastProcessedQuery = processedQuery;
    });

    // Add user query to conversation history
    conversationHistory.add(ConversationEntry.user(processedQuery));

    try {
      // Get response from the AI service
      final rawResponse = await geminiService.isArtPromptAPI(processedQuery);

      // All responses are text responses - clean it for display and speech
      final cleanedText = _ttsService.cleanTextForSpeech(rawResponse);

      setState(() {
        generatedImageUrl = null; // Always set to null as we don't want images
        generatedContent = cleanedText; // Store cleaned text for display
        conversationHistory.add(ConversationEntry.assistant(cleanedText));
      });

      // Speak the cleaned text
      await systemSpeak(cleanedText);
    } catch (e) {
      setState(() {
        generatedContent = "Sorry, I encountered an error. Please try again.";
        assistantState = AssistantState.idle;
      });
      print("Error processing query: $e");
    }
  }

  @override
  void dispose() {
    _sttService.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'Voice Assistant',
            style: TextStyle(color: Color(0xFFCC9930)),
          ),
        ),
        centerTitle: true,
        actions: [
          // Clear conversation button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: clearConversation,
            tooltip: 'New Conversation',
          ),
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Assistant header with avatar and status
                AssistantHeader(
                  userName: userName,
                  assistantState: assistantState,
                  isLoading: isLoading,
                  hasConversation: conversationHistory.isNotEmpty ||
                      generatedContent != null,
                  lastWords: lastWords,
                ),

                // Conversation display
                if (conversationHistory.isNotEmpty)
                  ConversationWidget(
                    conversationHistory: conversationHistory,
                    currentGeneratedContent: generatedContent,
                    currentAssistantState: assistantState,
                  ),

                // Features section (only show when no conversation is happening)
                if (conversationHistory.isEmpty &&
                    generatedContent == null &&
                    generatedImageUrl == null)
                  FeaturesSection(
                    startDelay: start,
                    delayIncrement: delay,
                  ),

                // Add padding at the bottom to prevent floating action button from covering text
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: AssistantControls(
          assistantState: assistantState,
          onStartListening: startListening,
          onStopListening: stopListening,
          onStopSpeaking: stopSpeaking,
          onAskNewQuestion: _askNewQuestion,
          onResumeSpeaking: resumeSpeaking,
        ),
      ),
    );
  }
}
