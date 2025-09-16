import 'package:flutter/material.dart';
import 'package:pro_voice_assistant/models/assistant_state.dart';
import 'package:pro_voice_assistant/models/conversation_entry.dart';

class ConversationWidget extends StatelessWidget {
  final List<ConversationEntry> conversationHistory;
  final String? currentGeneratedContent;
  final AssistantState currentAssistantState;

  const ConversationWidget({
    Key? key,
    required this.conversationHistory,
    this.currentGeneratedContent,
    required this.currentAssistantState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conversationHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildConversationWidgets(context),
      ),
    );
  }

  List<Widget> _buildConversationWidgets(BuildContext context) {
    List<Widget> widgets = [];

    // Add all conversation history items
    for (final entry in conversationHistory) {
      if (entry.isUserMessage) {
        widgets.add(_buildUserMessage(context, entry.userMessage!));
      }

      if (entry.isAssistantMessage) {
        widgets.add(_buildAssistantMessage(context, entry.assistantMessage!));
      }
    }

    // If the assistant is currently speaking, paused or completed, show the current message
    if ((currentAssistantState == AssistantState.speaking ||
            currentAssistantState == AssistantState.paused ||
            currentAssistantState == AssistantState.completed) &&
        currentGeneratedContent != null) {
      // Check if the last assistant message is already showing this content
      bool shouldShowCurrent = true;
      if (conversationHistory.isNotEmpty &&
          conversationHistory.last.isAssistantMessage &&
          conversationHistory.last.assistantMessage ==
              currentGeneratedContent) {
        shouldShowCurrent = false;
      }

      if (shouldShowCurrent) {
        widgets.add(
            _buildCurrentAssistantMessage(context, currentGeneratedContent!));
      }
    }

    return widgets;
  }

  Widget _buildUserMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.blue[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small assistant avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/virtualAssistant.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Assistant message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAssistantMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small assistant avatar
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/virtualAssistant.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Assistant message bubble
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: currentAssistantState == AssistantState.paused
                      ? Border.all(color: Colors.yellow[700]!, width: 2)
                      : currentAssistantState == AssistantState.completed
                          ? Border.all(color: Colors.green, width: 2)
                          : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (currentAssistantState == AssistantState.speaking)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Speaking...',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (currentAssistantState == AssistantState.completed)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
