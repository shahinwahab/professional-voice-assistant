class ConversationEntry {
  final String? userMessage;
  final String? assistantMessage;

  ConversationEntry({this.userMessage, this.assistantMessage}) {
    // At least one of userMessage or assistantMessage must be non-null
    assert(userMessage != null || assistantMessage != null);
  }

  bool get isUserMessage => userMessage != null;
  bool get isAssistantMessage => assistantMessage != null;

  // Create a user message entry
  factory ConversationEntry.user(String message) {
    return ConversationEntry(userMessage: message);
  }

  // Create an assistant message entry
  factory ConversationEntry.assistant(String message) {
    return ConversationEntry(assistantMessage: message);
  }

  // Convert to Map representation (same as used in original code)
  Map<String, String> toMap() {
    final map = <String, String>{};
    if (userMessage != null) map['user'] = userMessage!;
    if (assistantMessage != null) map['assistant'] = assistantMessage!;
    return map;
  }

  // Create from Map representation
  factory ConversationEntry.fromMap(Map<String, String> map) {
    return ConversationEntry(
      userMessage: map['user'],
      assistantMessage: map['assistant'],
    );
  }
}
