import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pro_voice_assistant/theme/pallete.dart';
import 'package:pro_voice_assistant/models/assistant_state.dart';

class AssistantHeader extends StatelessWidget {
  final String userName;
  final AssistantState assistantState;
  final bool isLoading;
  final bool hasConversation;
  final String? lastWords;

  const AssistantHeader({
    Key? key,
    required this.userName,
    required this.assistantState,
    required this.isLoading,
    required this.hasConversation,
    this.lastWords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Virtual assistant picture
        ZoomIn(
          child: Stack(
            children: [
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: Pallete.assistantCircleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                height: 123,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/virtualAssistant.png'),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Assistant state indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            assistantState.displayText,
            style: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // Paused state indicator and Ask New Question button
        if (assistantState == AssistantState.paused) _buildPausedIndicator(),

        // Last user speech text display during listening
        if (lastWords != null &&
            lastWords!.isNotEmpty &&
            assistantState == AssistantState.listening)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"$lastWords"',
              style: const TextStyle(color: Colors.white),
            ),
          ),

        // Show greeting if no conversation history yet
        if (!hasConversation)
          FadeInRight(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 40,
              ).copyWith(top: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.borderColor),
                borderRadius:
                    BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  isLoading ? 'Loading...' : 'Welcome, $userName',
                  style: const TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPausedIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pause_circle_outline,
            color: Colors.white70,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Speech paused',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
