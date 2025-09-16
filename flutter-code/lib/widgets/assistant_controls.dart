import 'package:flutter/material.dart';
import 'package:pro_voice_assistant/models/assistant_state.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';

class AssistantControls extends StatelessWidget {
  final AssistantState assistantState;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final VoidCallback onStopSpeaking;
  final VoidCallback onAskNewQuestion;
  final VoidCallback onResumeSpeaking;

  const AssistantControls({
    Key? key,
    required this.assistantState,
    required this.onStartListening,
    required this.onStopListening,
    required this.onStopSpeaking,
    required this.onAskNewQuestion,
    required this.onResumeSpeaking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (assistantState) {
      case AssistantState.idle:
        return FloatingActionButton(
          backgroundColor: Pallete.featureBoxColor,
          onPressed: onStartListening,
          tooltip: 'Start Listening',
          child: const Icon(Icons.mic, color: Colors.black),
        );

      case AssistantState.listening:
        return FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: onStopListening,
          tooltip: 'Stop Listening',
          child: const Icon(Icons.stop, color: Colors.white),
        );

      case AssistantState.processing:
        return FloatingActionButton(
          backgroundColor: Colors.grey,
          onPressed: null,
          tooltip: 'Processing',
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.white,
            ),
          ),
        );

      case AssistantState.speaking:
        return FloatingActionButton(
          backgroundColor: Pallete.featureBoxColor,
          onPressed: onStopSpeaking,
          tooltip: 'Pause Speaking',
          child: const Icon(Icons.pause, color: Colors.black),
        );

      case AssistantState.completed:
        return FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: onAskNewQuestion,
          tooltip: 'New Question',
          child: const Icon(Icons.chat, color: Colors.white),
        );

      case AssistantState.paused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Button to continue conversation
            FloatingActionButton.small(
              heroTag: 'askNewQuestion',
              backgroundColor: Colors.green,
              onPressed: onAskNewQuestion,
              tooltip: 'New Question',
              child: const Icon(Icons.chat, color: Colors.white),
            ),
            const SizedBox(width: 16),
            // Button to resume speaking
            FloatingActionButton(
              heroTag: 'resumeSpeaking',
              backgroundColor: Pallete.featureBoxColor,
              onPressed: onResumeSpeaking,
              tooltip: 'Resume Speaking',
              child: const Icon(Icons.play_arrow, color: Colors.black),
            ),
          ],
        );
    }
  }
}
