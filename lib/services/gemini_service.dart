import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;
  final List<Map<String, String>> messages = [];

  GeminiService({required this.apiKey});

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      // Skip the image check and directly process as chat
      return await chatWithGemini(prompt);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatWithGemini(String prompt) async {
    try {
      // Add the user message to our history
      messages.add({
        'role': 'user',
        'content': prompt,
      });

      // Create a model and generate content
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);

      // Format the chat history for Gemini
      final List<Content> chatHistory = [];

      for (var message in messages) {
        if (message['role'] == 'user') {
          chatHistory.add(Content.text(message['content'] ?? ''));
        }
      }

      // If chat history is empty (shouldn't happen), just use the prompt
      if (chatHistory.isEmpty) {
        chatHistory.add(Content.text(prompt));
      }

      // Get response from Gemini
      final response = await model.generateContent(chatHistory);
      final responseText = response.text?.trim() ?? 'No response from Gemini';

      // Add the assistant's response to our history
      messages.add({
        'role': 'assistant',
        'content': responseText,
      });

      return responseText;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
